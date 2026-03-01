#!/usr/bin/env bash

remote_dir="/home/nam20485/src/github/nam20485/dynamic_workflows/profile-genie-india58-a" #/src/github/nam20485/OdbDesign

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

opencode run --attach http://localhost:4096 \
    --dir "$remote_dir" \
    --model glm-4.5-AirX \
    --agent Orchestrator \
    "$prompt"
