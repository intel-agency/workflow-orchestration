#!/usr/bin/env pwsh

param(
    [string]$File,
    [string]$Prompt,
    [string]$Attach,
    [string]$Username,
    [string]$Password,
    [string]$Dir,
    [ValidateSet("DEBUG","INFO","WARN","ERROR")]
    [string]$LogLevel = "INFO",
    [switch]$PrintLogs
)

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

# Embed basic auth credentials into the attach URL if provided
# http://host:port  ->  http://user:pass@host:port
$attachUrl = $Attach
if ($attachUrl -and $Username -and $Password)
{
    $uri = [System.Uri]$attachUrl
    $attachUrl = "$($uri.Scheme)://${Username}:${Password}@$($uri.Authority)$($uri.PathAndQuery)"
} elseif (($Username -or $Password) -and -not $attachUrl)
{
    Write-Error "-Username/-Password require -Attach <url>"
    exit 1
}

$opencodeArgs = @(
    "run",
    "--model", "zai-coding-plan/glm-5",
    "--agent", "orchestrator",
    "--log-level", $LogLevel
)

if ($attachUrl)
{ $opencodeArgs += "--attach", $attachUrl 
}
if ($Dir)
{ $opencodeArgs += "--dir",    $Dir       
}
if ($PrintLogs)
{ $opencodeArgs += "--print-logs"         
}

$opencodeArgs += $prompt

opencode @opencodeArgs
