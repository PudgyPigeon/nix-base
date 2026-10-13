#!/usr/bin/env bash
set -euo pipefail

# Required dependencies
for cmd in nvim rg file; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is not installed or not in PATH." >&2
    exit 1
  fi
done

echo "==> Gathering Neovim plugin paths..."
PLUGIN_PATHS=$(nvim --headless -c 'lua io.write(table.concat(vim.api.nvim_list_runtime_paths(), "\n"))' -c 'q' \
  | grep -E '/nix/store/' \
  | grep -vE 'neovim-[0-9].*/share/nvim/runtime' || true)

if [ -z "$PLUGIN_PATHS" ]; then
  echo "No Nix store plugins detected in Neovim runtimepath."
  exit 0
fi

# Define audit categories and regex rules
REGEX_EXEC='(os\.execute|io\.popen|vim\.fn\.system|vim\.fn\.jobstart|vim\.loop\.spawn|vim\.uv\.spawn)'
REGEX_DYN_CODE='(loadstring|load\(|dofile\(|package\.loadlib)'
REGEX_NET_SOCKET='(require\(["\x27]socket|require\(["\x27]ssl|vim\.loop\.new_tcp|vim\.uv\.new_tcp|curl|wget|fetch)'
REGEX_SECRETS_ENV='os\.getenv\(["\x27](AWS_|SSH_|GITHUB_|GH_|OPENAI_|ANTHROPIC_|TOKEN|SECRET|KEY|PASSWORD|PASS)'
REGEX_SENSITIVE_FILES='(\.ssh/|\.gnupg/|\.aws/|\.env|\.netrc|keychains?|id_rsa|id_ed25519)'
REGEX_OBFUSCATION='(\\x[0-9a-fA-F]{2}){4,}|(\\[0-9]{3}){4,}|(from_base64|base64_decode|b64decode|atob)'
REGEX_PERSISTENCE='(vim\.loop\.new_timer|vim\.uv\.new_timer|vim\.defer_fn)'

TOTAL_FLAGGED=0

scan_category() {
  local path="$1"
  local label="$2"
  local regex="$3"
  local results
  results=$(rg --no-heading --line-number --color=always -E "$regex" "$path" 2>/dev/null || true)
  if [ -n "$results" ]; then
    echo -e "    \033[1;33m[!] $label:\033[0m"
    echo "$results" | head -n 4 | sed 's/^/      /'
    local count
    count=$(echo "$results" | wc -l)
    [ "$count" -gt 4 ] && echo "      ... ($((count - 4)) more occurrences)"
    return 0
  fi
  return 1
}

echo "==> Auditing installed plugins..."
echo "============================================================"

while IFS= read -r path; do
  [ -d "$path" ] || continue
  plugin_name=$(basename "$path" | sed -E 's/^[a-z0-9]{32}-//')
  has_issue=0

  # Temp capture to decide whether to print plugin header
  header_printed=0
  print_header() {
    if [ "$header_printed" -eq 0 ]; then
      echo -e "\033[1;31mPlugin: $plugin_name\033[0m"
      echo "  Path: $path"
      header_printed=1
      has_issue=1
    fi
  }

  # 1. Obfuscated / Precompiled Bytecode check (e.g. \x1bLua)
  bytecode_files=$(rg --files "$path" 2>/dev/null | xargs file -b --mime-type 2>/dev/null | grep -E 'application/x-executable|application/x-sharedlib' || true)
  raw_luac=$(find "$path" -type f \( -name "*.luac" -o -name "*.pyc" \) 2>/dev/null || true)
  if [ -n "$bytecode_files" ] || [ -n "$raw_luac" ]; then
    print_header
    echo -e "    \033[1;35m[CRITICAL] Compiled binaries/bytecode found:\033[0m"
    [ -n "$raw_luac" ] && echo "$raw_luac" | sed 's/^/      /'
    [ -n "$bytecode_files" ] && echo "$bytecode_files" | sed 's/^/      /'
  fi

  # 2. String obfuscation & hex packing
  if scan_category "$path" "String Obfuscation / Base64" "$REGEX_OBFUSCATION"; then
    print_header
  fi

  # 3. Environment variable probing (Secret Scraping)
  if scan_category "$path" "Secret / Credential Env Access" "$REGEX_SECRETS_ENV"; then
    print_header
  fi

  # 4. Sensitive filesystem reads
  if scan_category "$path" "Sensitive Directory Access (~/.ssh, .env)" "$REGEX_SENSITIVE_FILES"; then
    print_header
  fi

  # 5. Shell execution & subprocesses
  if scan_category "$path" "Process Spawning / Shell Execution" "$REGEX_EXEC"; then
    print_header
  fi

  # 6. Dynamic code execution (eval)
  if scan_category "$path" "Dynamic Evaluation (load/dofile)" "$REGEX_DYN_CODE"; then
    print_header
  fi

  # 7. Raw Network / Sockets
  if scan_category "$path" "Network Connections / Sockets" "$REGEX_NET_SOCKET"; then
    print_header
  fi

  if [ "$has_issue" -eq 1 ]; then
    echo "------------------------------------------------------------"
    TOTAL_FLAGGED=$((TOTAL_FLAGGED + 1))
  fi

done <<< "$PLUGIN_PATHS"

if [ "$TOTAL_FLAGGED" -eq 0 ]; then
  echo -e "\033[1;32m✓ All plugins cleared all heuristic checks.\033[0m"
else
  echo -e "\033[1;33mAudit finished: $TOTAL_FLAGGED plugin(s) flagged for manual verification.\033[0m"
fi