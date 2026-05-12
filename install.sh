#!/usr/bin/env bash
# install.sh — Trust Wallet Agent Kit installer
# One-line install:  curl -fsSL <INSTALL_URL> | sh

set -euo pipefail
IFS=$'\n\t'

# ─── Constants ───────────────────────────────────────────────────────────────
SCRIPT_VERSION="0.1.0"
PACKAGE_NAME="@trustwallet/cli"
MIN_NODE_MAJOR=22
MIN_NODE_MINOR=14

# ─── Flags & env vars ────────────────────────────────────────────────────────
NO_ONBOARD="${TWAK_NO_ONBOARD:-0}"
VERSION="${TWAK_VERSION:-latest}"

# ─── Colour handling ─────────────────────────────────────────────────────────
if [[ -z "${NO_COLOR:-}" ]] && [[ -t 1 ]]; then
  C_DIM=$'\033[2m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
  C_BOLD=$'\033[1m'
  C_RESET=$'\033[0m'
else
  C_DIM=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_BOLD=''; C_RESET=''
fi

# ─── UI helpers ──────────────────────────────────────────────────────────────
ui_info()    { printf "%s·%s %s\n"  "$C_DIM"    "$C_RESET" "$*"; }
ui_success() { printf "%s✓%s %s\n"  "$C_GREEN"  "$C_RESET" "$*"; }
ui_warn()    { printf "%s!%s %s\n"  "$C_YELLOW" "$C_RESET" "$*" >&2; }
ui_error()   { printf "%s✗%s %s\n"  "$C_RED"    "$C_RESET" "$*" >&2; }

print_banner() {
  printf "\n%s⛓  Trust Wallet Agent Kit — Installer%s\n\n" "$C_BOLD" "$C_RESET"
}

# ─── Argument parsing ────────────────────────────────────────────────────────
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --no-onboard)
        NO_ONBOARD=1; shift ;;
      --version)
        if [[ $# -lt 2 ]]; then
          ui_error "--version requires a value"
          exit 1
        fi
        VERSION="$2"; shift 2 ;;
      -h|--help)
        cat <<EOF
Usage: install.sh [--no-onboard] [--version <v>]

Flags:
  --no-onboard       Install CLI, skip 'twak setup'
  --version <v>      Pin to a specific @trustwallet/cli version (default: latest)
  -h, --help         Show this help

Environment:
  TWAK_NO_ONBOARD=1      Same as --no-onboard
  TWAK_VERSION=<v>       Same as --version <v>
  NO_PROMPT=1            Non-interactive mode (passed to 'twak setup')
  NO_COLOR=1             Disable ANSI colours
  TWAK_INSTALL_DEBUG=1   Enable 'set -x' for debugging
EOF
        exit 0 ;;
      *)
        ui_error "Unknown argument: $1"
        printf "  Run 'install.sh --help' for usage.\n" >&2
        exit 1 ;;
    esac
  done
}

# ─── Platform detection ──────────────────────────────────────────────────────
detect_platform() {
  case "$(uname -s 2>/dev/null)" in
    Darwin)
      OS="macos" ;;
    Linux)
      if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
        OS="linux-wsl"
      else
        OS="linux"
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*)
      ui_error "Native Windows is not supported. Use WSL."
      exit 3 ;;
    *)
      ui_error "Unsupported OS: $(uname -s). Supported: macOS, Linux, WSL."
      exit 3 ;;
  esac

  ARCH="$(uname -m 2>/dev/null)"
  case "$OS" in
    macos)     PLATFORM_LABEL="macOS $ARCH" ;;
    linux-wsl) PLATFORM_LABEL="Linux $ARCH (WSL: $WSL_DISTRO_NAME)" ;;
    linux)     PLATFORM_LABEL="Linux $ARCH" ;;
  esac
  printf "%s·%s %-10s %s\n" "$C_DIM" "$C_RESET" "Platform" "$PLATFORM_LABEL"
}

# ─── Node check ──────────────────────────────────────────────────────────────
check_node() {
  if ! command -v node >/dev/null 2>&1; then
    ui_error "Node ${MIN_NODE_MAJOR}.${MIN_NODE_MINOR}+ required (not installed)."
    cat <<EOF >&2

  Install Node:
    macOS:  brew install node
    Linux:  https://nodejs.org or your package manager
    Other:  https://nodejs.org

  Then re-run:
    curl -fsSL <INSTALL_URL> | sh
EOF
    exit 4
  fi

  local v major minor
  v="$(node --version 2>/dev/null | sed 's/^v//')"
  major="$(printf '%s' "$v" | cut -d. -f1)"
  minor="$(printf '%s' "$v" | cut -d. -f2)"

  if [[ "$major" -lt "$MIN_NODE_MAJOR" ]] || \
     { [[ "$major" -eq "$MIN_NODE_MAJOR" ]] && [[ "$minor" -lt "$MIN_NODE_MINOR" ]]; }; then
    ui_error "Node ${MIN_NODE_MAJOR}.${MIN_NODE_MINOR}+ required (you have v${v})."
    printf "  Update via your version manager, then re-run.\n" >&2
    exit 4
  fi
  printf "%s·%s %-10s %s %s✓%s\n" "$C_DIM" "$C_RESET" "Node" "v$v" "$C_GREEN" "$C_RESET"
}

# ─── npm check ───────────────────────────────────────────────────────────────
check_npm() {
  if ! command -v npm >/dev/null 2>&1; then
    ui_error "npm is required but not on PATH. Reinstall Node or fix PATH."
    exit 5
  fi
  local v
  v="$(npm --version 2>/dev/null)"
  printf "%s·%s %-10s %s %s✓%s\n" "$C_DIM" "$C_RESET" "npm" "v$v" "$C_GREEN" "$C_RESET"
}

# ─── Install ─────────────────────────────────────────────────────────────────
install_cli() {
  # If twak is already installed at the requested version, skip the npm install.
  # Resolve the target: 'npm view PKG@latest version' returns the actual latest
  # version number; 'npm view PKG@0.10.0 version' echoes back "0.10.0".
  local target current
  target="$(npm view "${PACKAGE_NAME}@${VERSION}" version 2>/dev/null || true)"
  if command -v twak >/dev/null 2>&1; then
    current="$(twak --version 2>/dev/null | head -n1 || true)"
    if [[ -n "$target" ]] && [[ "$current" == "$target" ]]; then
      printf "\n%s·%s Already installed: %s@%s — skipping install.\n" \
        "$C_DIM" "$C_RESET" "$PACKAGE_NAME" "$current"
      return 0
    fi
  fi

  printf "\n%s·%s Installing %s@%s...\n" "$C_DIM" "$C_RESET" "$PACKAGE_NAME" "$VERSION"

  local out exit_code
  set +e
  out="$(npm install -g "${PACKAGE_NAME}@${VERSION}" 2>&1)"
  exit_code=$?
  set -e

  printf '%s\n' "$out" | sed 's/^/    /'

  if [[ "$exit_code" -ne 0 ]]; then
    if printf '%s' "$out" | grep -qiE "EACCES|permission denied"; then
      ui_error "Install failed — permissions issue with the global npm prefix."
      cat <<EOF >&2

  Common fixes:
    1. Use a Node version manager (nvm/fnm/volta) — recommended
    2. Set NPM_CONFIG_PREFIX to a user-owned directory
    3. Re-run with sudo (system-wide install)
EOF
    else
      ui_error "npm install failed (exit $exit_code)."
    fi
    exit 6
  fi
}

# ─── Post-install verify ─────────────────────────────────────────────────────
verify_install() {
  if ! command -v twak >/dev/null 2>&1; then
    local npm_prefix
    npm_prefix="$(npm prefix -g 2>/dev/null || echo "<unknown>")"
    ui_error "Install succeeded but 'twak' not on PATH."
    printf "  Your npm bin directory (%s/bin) may not be on PATH.\n" "$npm_prefix" >&2
    printf "  Add it to your shell rc and re-open the shell.\n" >&2
    exit 7
  fi
  local v path
  v="$(twak --version 2>/dev/null | head -n1)"
  path="$(command -v twak)"
  printf "%s·%s %-10s %s installed at %s\n" "$C_DIM" "$C_RESET" "twak" "v$v" "$path"
}

# ─── Exec setup ──────────────────────────────────────────────────────────────
exec_setup() {
  if [[ "$NO_ONBOARD" == "1" ]]; then
    printf "\n"
    ui_success "Installed. To finish setup later:"
    printf "    twak setup\n\n"
    exit 0
  fi
  printf "\n%s·%s Continuing to setup...\n\n" "$C_DIM" "$C_RESET"

  # Until 'twak setup' (spec 2) ships, gracefully no-op if the subcommand is missing.
  if ! twak setup --help >/dev/null 2>&1; then
    ui_info "'twak setup' not yet available — install complete."
    printf "    Re-run this installer once 'twak setup' ships, or run it manually then.\n\n"
    exit 0
  fi

  if [[ -e /dev/tty ]]; then
    exec twak setup </dev/tty
  else
    exec twak setup
  fi
}

# ─── main ────────────────────────────────────────────────────────────────────
main() {
  if [[ "${TWAK_INSTALL_DEBUG:-}" == "1" ]]; then
    set -x
  fi
  parse_args "$@"
  print_banner
  detect_platform
  check_node
  check_npm
  install_cli
  verify_install
  exec_setup
}

main "$@"
