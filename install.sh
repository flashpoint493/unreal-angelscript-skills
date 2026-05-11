#!/usr/bin/env bash
# Unreal AngelScript skill installer (Linux / macOS).
#
# Downloads a released skill archive from GitHub and installs it into the
# AI agent directory of your choice (or every detected agent directory).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/flashpoint493/unreal-angelscript-skills/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/flashpoint493/unreal-angelscript-skills/main/install.sh | bash -s -- --agent codebuddy
#   curl -fsSL https://raw.githubusercontent.com/flashpoint493/unreal-angelscript-skills/main/install.sh | bash -s -- --agent all --version 0.1.0
#
# Environment variables (lower precedence than CLI flags):
#   UEAS_VERSION    Release version to install (default: latest)
#   UEAS_AGENT      Target agent: codebuddy | claude | cursor | windsurf | cline |
#                                 roo | trae | Claude | opencode | agents | spec | all | auto
#                   (default: auto — detect existing agent dirs in current project,
#                   fall back to interactive prompt)
#   UEAS_SCOPE      project | user   (default: project — install under "$PWD")
#   UEAS_REPO       owner/name slug (default: flashpoint493/unreal-angelscript-skills)
#   UEAS_INSTALL_DIR  Override the install root entirely (skips agent fan-out)

set -euo pipefail

REPO_DEFAULT="flashpoint493/unreal-angelscript-skills"
SKILL_NAME="unreal-angelscript"

UEAS_REPO="${UEAS_REPO:-${REPO_DEFAULT}}"
UEAS_VERSION="${UEAS_VERSION:-}"
UEAS_AGENT="${UEAS_AGENT:-auto}"
UEAS_SCOPE="${UEAS_SCOPE:-project}"
UEAS_INSTALL_DIR="${UEAS_INSTALL_DIR:-}"

# All agents we support (directory names relative to the install root).
ALL_AGENTS=(codebuddy claude cursor windsurf cline roo trae Claude opencode agents)

# ── Logging ───────────────────────────────────────────────────────────────────
step() { printf "  \033[36m●\033[0m %s\n" "$1" >&2; }
ok()   { printf "  \033[32m✓\033[0m %s\n" "$1" >&2; }
warn() { printf "  \033[33m!\033[0m %s\n" "$1" >&2; }
fail() { printf "  \033[31m✗\033[0m %s\n" "$1" >&2; exit 1; }

# ── Arg parsing ───────────────────────────────────────────────────────────────
while [ $# -gt 0 ]; do
  case "$1" in
    --version)       UEAS_VERSION="${2:-}"; shift 2 ;;
    --agent)         UEAS_AGENT="${2:-}";   shift 2 ;;
    --scope)         UEAS_SCOPE="${2:-}";   shift 2 ;;
    --install-dir)   UEAS_INSTALL_DIR="${2:-}"; shift 2 ;;
    --repo)          UEAS_REPO="${2:-}";    shift 2 ;;
    -h|--help)
      sed -n '2,30p' "$0"
      exit 0
      ;;
    *) fail "Unknown argument: $1" ;;
  esac
done

# ── Dependency checks ─────────────────────────────────────────────────────────
require() { command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"; }
require curl
require unzip

HAVE_JQ=0
if command -v jq >/dev/null 2>&1; then HAVE_JQ=1; fi

# ── Resolve install root ──────────────────────────────────────────────────────
if [ -n "${UEAS_INSTALL_DIR}" ]; then
  ROOT="${UEAS_INSTALL_DIR}"
elif [ "${UEAS_SCOPE}" = "user" ]; then
  ROOT="${HOME}"
else
  ROOT="$(pwd)"
fi
mkdir -p "${ROOT}"
step "Install root: ${ROOT}"

# ── Resolve version ───────────────────────────────────────────────────────────
api_url="https://api.github.com/repos/${UEAS_REPO}/releases/latest"
if [ -z "${UEAS_VERSION}" ]; then
  step "Querying latest release from ${UEAS_REPO}"
  resp="$(curl -fsSL -H 'Accept: application/vnd.github+json' "${api_url}" 2>/dev/null || true)"
  if [ -z "${resp}" ]; then
    fail "Could not reach GitHub API. Set UEAS_VERSION manually."
  fi
  if [ "${HAVE_JQ}" -eq 1 ]; then
    tag="$(printf '%s' "${resp}" | jq -r '.tag_name // empty')"
  else
    tag="$(printf '%s' "${resp}" | grep -oE '"tag_name"\s*:\s*"[^"]+"' | head -1 | sed -E 's/.*"([^"]+)"$/\1/')"
  fi
  [ -n "${tag}" ] || fail "Could not determine latest tag."
  UEAS_VERSION="${tag#v}"
fi
TAG="v${UEAS_VERSION#v}"
ok "Target version: ${TAG}"

# ── Resolve agent list ────────────────────────────────────────────────────────
declare -a AGENTS=()

detect_agents() {
  local found=()
  for a in "${ALL_AGENTS[@]}"; do
    if [ -d "${ROOT}/.${a}" ]; then
      found+=("${a}")
    fi
  done
  printf '%s\n' "${found[@]}"
}

case "${UEAS_AGENT}" in
  all)
    AGENTS=("${ALL_AGENTS[@]}")
    ;;
  spec)
    # Generic AGENTS.md spec-style: install under skills/ at the install root.
    AGENTS=("__spec__")
    ;;
  auto)
    while IFS= read -r line; do
      [ -n "${line}" ] && AGENTS+=("${line}")
    done < <(detect_agents)
    if [ "${#AGENTS[@]}" -eq 0 ]; then
      warn "No existing agent directories found under ${ROOT}."
      if [ -t 0 ] && [ -t 1 ]; then
        printf "  Choose target [codebuddy/claude/cursor/windsurf/cline/roo/trae/Claude/opencode/agents/spec/all]: " >&2
        read -r choice
        UEAS_AGENT="${choice:-spec}"
        # Re-run resolution with chosen value
        case "${UEAS_AGENT}" in
          all)  AGENTS=("${ALL_AGENTS[@]}") ;;
          spec) AGENTS=("__spec__") ;;
          *)    AGENTS=("${UEAS_AGENT}") ;;
        esac
      else
        AGENTS=("__spec__")
        warn "Non-interactive run: defaulting to generic 'skills/' layout."
      fi
    else
      ok "Auto-detected agents: ${AGENTS[*]}"
    fi
    ;;
  *)
    AGENTS=("${UEAS_AGENT}")
    ;;
esac

# ── Download archive ──────────────────────────────────────────────────────────
asset="unreal-angelscript-skill-${UEAS_VERSION#v}.zip"
url="https://github.com/${UEAS_REPO}/releases/download/${TAG}/${asset}"

tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

step "Downloading ${asset}"
if ! curl -fsSL --retry 3 --connect-timeout 10 -o "${tmp}/${asset}" "${url}"; then
  fail "Download failed: ${url}"
fi
ok "Downloaded $(du -h "${tmp}/${asset}" | cut -f1)"

step "Extracting"
unzip -q "${tmp}/${asset}" -d "${tmp}/unpacked"
src="${tmp}/unpacked/${SKILL_NAME}"
[ -d "${src}" ] || fail "Archive layout unexpected: ${SKILL_NAME}/ not found inside zip."

# ── Install to each chosen target ─────────────────────────────────────────────
install_to() {
  local agent="$1"
  local dest
  if [ "${agent}" = "__spec__" ]; then
    dest="${ROOT}/skills/${SKILL_NAME}"
  else
    dest="${ROOT}/.${agent}/skills/${SKILL_NAME}"
  fi
  if [ -d "${dest}" ]; then
    warn "Replacing existing ${dest}"
    rm -rf "${dest}"
  fi
  mkdir -p "$(dirname "${dest}")"
  cp -R "${src}" "${dest}"
  ok "Installed → ${dest}"
}

for a in "${AGENTS[@]}"; do
  install_to "${a}"
done

ok "Done. Skill '${SKILL_NAME}' ${TAG} is ready."
