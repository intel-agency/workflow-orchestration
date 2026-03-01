#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 -f <file> | -p <prompt>" >&2
    exit 1
}

prompt=""

while getopts ":f:p:" opt; do
    case $opt in
        f) prompt=$(cat "$OPTARG") ;;
        p) prompt="$OPTARG" ;;
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

echo "Starting opencode at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
set +e
stdbuf -oL -eL timeout 10m opencode run \
    --model zai-coding-plan/glm-5 \
    --agent orchestrator \
    --print-logs \
    --log-level DEBUG \
    "$prompt" 2>&1
OPENCODE_EXIT=$?
set -e

if [[ ${OPENCODE_EXIT} -eq 124 ]]; then
    echo "::warning::opencode run timed out after 10 minutes; continuing workflow"
    exit 0
fi

exit ${OPENCODE_EXIT}
