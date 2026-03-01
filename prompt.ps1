#!/usr/bin/env pwsh

param(
    [string]$File,
    [string]$Prompt
)

$remote_dir = "/home/nam20485/src/github/nam20485/dynamic_workflows/profile-genie-india58-a" #/src/github/nam20485/OdbDesign"

# Resolve the prompt from either a file or a string argument
if ($File)
{
    $prompt = Get-Content -Raw -Path $File
} elseif ($Prompt)
{
    $prompt = $Prompt
} else
{
    Write-Error "Either -File <path> or -Prompt <string> must be specified."
    exit 1
}

opencode run --attach http://localhost:4096 `
    --dir $remote_dir `
    --model glm-4.5-AirX `
    --agent Orchestrator `
    $prompt
