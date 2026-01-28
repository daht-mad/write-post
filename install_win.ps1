# write-post installer for Windows PowerShell

# UTF-8 encoding for Korean text display
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$RepoUrl = "https://raw.githubusercontent.com/daht-mad/write-post/main"

# Tool selection menu
[Console]::Write("어떤 도구에 설치할까요?`n")
[Console]::Write("1) Claude Code`n")
[Console]::Write("2) OpenCode`n")
[Console]::Write("3) Codex CLI`n")
[Console]::Write("4) Gemini CLI`n")
[Console]::Write("5) Antigravity`n")
[Console]::Write("6) 전체`n")
[Console]::Write("선택 (1-6, 쉼표로 구분 가능): ")
$toolChoice = [Console]::ReadLine()

# Scope selection
[Console]::Write("`n설치 위치를 선택하세요:`n")
[Console]::Write("1) 전역 설치 (모든 프로젝트에서 사용)`n")
[Console]::Write("2) 프로젝트 설치 (현재 폴더에서만 사용)`n")
[Console]::Write("선택 (1/2): ")
$scopeChoice = [Console]::ReadLine()

if ($scopeChoice -eq "1") {
    $Scope = "global"
    $ScopeLabel = "전역"
} else {
    $Scope = "project"
    $ScopeLabel = "프로젝트"
}

# Parse tool choices
$tools = @()
if ($toolChoice -eq "6") {
    $tools = @("claude", "opencode", "codex", "gemini", "antigravity")
} else {
    $choices = $toolChoice -split ","
    foreach ($choice in $choices) {
        $choice = $choice.Trim()
        switch ($choice) {
            "1" { $tools += "claude" }
            "2" { $tools += "opencode" }
            "3" { $tools += "codex" }
            "4" { $tools += "gemini" }
            "5" { $tools += "antigravity" }
        }
    }
}

# Tool path mappings
$ToolPaths = @{
    "claude" = @{ 
        Global = "$env:USERPROFILE\.claude\skills\write-post"
        Project = ".claude\skills\write-post"
        Label = "Claude Code"
    }
    "opencode" = @{ 
        Global = "$env:USERPROFILE\.config\opencode\skills\write-post"
        Project = ".opencode\skills\write-post"
        Label = "OpenCode"
    }
    "codex" = @{ 
        Global = "$env:USERPROFILE\.codex\skills\write-post"
        Project = ".codex\skills\write-post"
        Label = "Codex CLI"
    }
    "gemini" = @{ 
        Global = "$env:USERPROFILE\.gemini\skills\write-post"
        Project = ".gemini\skills\write-post"
        Label = "Gemini CLI"
    }
    "antigravity" = @{ 
        Global = "$env:USERPROFILE\.gemini\antigravity\skills\write-post"
        Project = ".agent\skills\write-post"
        Label = "Antigravity"
    }
}

# Installation function
function Install-Tool {
    param($Tool, $Scope)
    
    $paths = $ToolPaths[$Tool]
    if (-not $paths) {
        Write-Host "ERROR: Unknown tool '$Tool'" -ForegroundColor Red
        throw "Unknown tool: $Tool"
    }
    
    $TargetDir = if ($Scope -eq "global") { $paths.Global } else { $paths.Project }
    
    if (Test-Path $TargetDir) {
        Remove-Item -Recurse -Force $TargetDir
    }
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
    
    try {
        Invoke-WebRequest -Uri "$RepoUrl/.claude/skills/write-post/SKILL.md" -OutFile "$TargetDir\SKILL.md" -ErrorAction Stop
    } catch {
        Write-Host "ERROR: Failed to download SKILL.md for $($paths.Label)" -ForegroundColor Red
        throw "Download failed for $($paths.Label)"
    }
    
    Write-Host "✓ $($paths.Label): $TargetDir\SKILL.md" -ForegroundColor Green
}

# Install selected tools
Write-Host ""
foreach ($tool in $tools) {
    Install-Tool -Tool $tool -Scope $Scope
}

# Cleanup: Remove old installation paths
if ($Scope -eq "global") {
    $oldPath = "$env:USERPROFILE\.claude\commands\write-post.md"
    if (Test-Path $oldPath) {
        Remove-Item $oldPath
        Write-Host "  (Cleaned up old file: $oldPath)" -ForegroundColor Gray
    }
} else {
    $oldPath = ".claude\commands\write-post.md"
    if (Test-Path $oldPath) {
        Remove-Item $oldPath
        Write-Host "  (Cleaned up old file: $oldPath)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "write-post $ScopeLabel 설치 완료!" -ForegroundColor Green
Write-Host "설치된 도구: $($tools -join ', ')"
Write-Host "사용법: /write-post"
