#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 -f <file> | -p <prompt> [-a <url>] [-u <user>] [-P <pass>] [-d <dir>] [-l <log-level>] [-L]" >&2
    echo "  -f <file>       Read prompt from file" >&2
    echo "  -p <prompt>     Use prompt string directly" >&2
    echo "  -a <url>        Attach to a running opencode server (e.g. http://localhost:4096)" >&2
    echo "  -u <user>       Basic auth username (used with -a)" >&2
    echo "  -P <pass>       Basic auth password (used with -a)" >&2
    echo "  -d <dir>        Working directory on the server (used with -a)" >&2
    echo "  -l <log-level>  opencode log level (DEBUG|INFO|WARN|ERROR), default: INFO" >&2
    echo "  -L              Enable --print-logs (disabled by default)" >&2
    exit 1
}

prompt=""
attach_url=""
auth_user=""
auth_pass=""
work_dir=""
log_level="INFO"
print_logs=""

while getopts ":f:p:a:u:P:d:l:L" opt; do
    case $opt in
        f) prompt=$(cat "$OPTARG") ;;
        p) prompt="$OPTARG" ;;
        a) attach_url="$OPTARG" ;;
        u) auth_user="$OPTARG" ;;
        P) auth_pass="$OPTARG" ;;
        d) work_dir="$OPTARG" ;;
        l) log_level="$OPTARG" ;;
        L) print_logs="--print-logs" ;;
        *) usage ;;
    esac
done

if [ -z "$prompt" ]; then
    usage
fi

if [[ -z "${ZHIPU_API_KEY:-}" ]]; then
    echo "::error::ZHIPU_API_KEY is not set" >&2
    exit 1
fi

# Embed basic auth credentials into the attach URL if provided
# http://host:port  →  http://user:pass@host:port
if [[ -n "$attach_url" && -n "$auth_user" && -n "$auth_pass" ]]; then
    scheme="${attach_url%%://*}"
    rest="${attach_url#*://}"
    attach_url="${scheme}://${auth_user}:${auth_pass}@${rest}"
elif [[ -n "$auth_user" || -n "$auth_pass" ]] && [[ -z "$attach_url" ]]; then
    echo "::error::-u/-P require -a <url>" >&2
    exit 1
fi

# Build opencode args — optional flags only included when set
opencode_args=(
    run
    --model zai-coding-plan/glm-5
    --agent orchestrator
    --log-level "$log_level"
)
[[ -n "$attach_url" ]] && opencode_args+=(--attach "$attach_url")
[[ -n "$work_dir"   ]] && opencode_args+=(--dir    "$work_dir")
[[ -n "$print_logs" ]] && opencode_args+=("$print_logs")
opencode_args+=("$prompt")

echo "Starting opencode at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
set +e
stdbuf -oL -eL timeout 10m opencode "${opencode_args[@]}" 2>&1
OPENCODE_EXIT=$?
set -e

if [[ ${OPENCODE_EXIT} -eq 124 ]]; then
    echo "::warning::opencode run timed out after 10 minutes; continuing workflow"
    exit 0
fi

exit ${OPENCODE_EXIT}
