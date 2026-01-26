# write-post installer for Windows PowerShell

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

# Installation function
function Install-Tool {
    param($Tool, $Scope)
    
    switch ($Tool) {
        "claude" {
            if ($Scope -eq "global") {
                $TargetDir = "$env:USERPROFILE\.claude\skills\write-post"
            } else {
                $TargetDir = ".claude\skills\write-post"
            }
            New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
            
            # Download SKILL.md with error handling
            try {
                Invoke-WebRequest -Uri "$RepoUrl/.claude/skills/write-post/SKILL.md" -OutFile "$TargetDir\SKILL.md" -ErrorAction Stop
            } catch {
                Write-Host "ERROR: Failed to download SKILL.md for Claude Code" -ForegroundColor Red
                exit 1
            }
            
            # Create references directory
            New-Item -ItemType Directory -Force -Path "$TargetDir\references" | Out-Null
            
            # Download template with warning on failure
            try {
                Invoke-WebRequest -Uri "$RepoUrl/.claude/skills/write-post/references/case-study-template.md" -OutFile "$TargetDir\references\case-study-template.md" -ErrorAction Stop
            } catch {
                Write-Host "WARNING: Failed to download references\case-study-template.md (Phase 3 template won't work)" -ForegroundColor Yellow
            }
            
            Write-Host "✓ Claude Code: $TargetDir\SKILL.md + references\" -ForegroundColor Green
        }
        "opencode" {
            if ($Scope -eq "global") {
                $TargetDir = "$env:USERPROFILE\.config\opencode\skills\write-post"
            } else {
                $TargetDir = ".opencode\skills\write-post"
            }
            New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
            
            # Download SKILL.md with error handling
            try {
                Invoke-WebRequest -Uri "$RepoUrl/.claude/skills/write-post/SKILL.md" -OutFile "$TargetDir\SKILL.md" -ErrorAction Stop
            } catch {
                Write-Host "ERROR: Failed to download SKILL.md for OpenCode" -ForegroundColor Red
                exit 1
            }
            
            # Create references directory
            New-Item -ItemType Directory -Force -Path "$TargetDir\references" | Out-Null
            
            # Download template with warning on failure
            try {
                Invoke-WebRequest -Uri "$RepoUrl/.claude/skills/write-post/references/case-study-template.md" -OutFile "$TargetDir\references\case-study-template.md" -ErrorAction Stop
            } catch {
                Write-Host "WARNING: Failed to download references\case-study-template.md (Phase 3 template won't work)" -ForegroundColor Yellow
            }
            
            Write-Host "✓ OpenCode: $TargetDir\SKILL.md + references\" -ForegroundColor Green
        }
        "codex" {
            if ($Scope -eq "global") {
                $TargetDir = "$env:USERPROFILE\.codex\skills\write-post"
            } else {
                $TargetDir = ".codex\skills\write-post"
            }
            New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
            
            # Download SKILL.md with error handling
            try {
                Invoke-WebRequest -Uri "$RepoUrl/.claude/skills/write-post/SKILL.md" -OutFile "$TargetDir\SKILL.md" -ErrorAction Stop
            } catch {
                Write-Host "ERROR: Failed to download SKILL.md for Codex CLI" -ForegroundColor Red
                exit 1
            }
            
            # Create references directory
            New-Item -ItemType Directory -Force -Path "$TargetDir\references" | Out-Null
            
            # Download template with warning on failure
            try {
                Invoke-WebRequest -Uri "$RepoUrl/.claude/skills/write-post/references/case-study-template.md" -OutFile "$TargetDir\references\case-study-template.md" -ErrorAction Stop
            } catch {
                Write-Host "WARNING: Failed to download references\case-study-template.md (Phase 3 template won't work)" -ForegroundColor Yellow
            }
            
            Write-Host "✓ Codex CLI: $TargetDir\SKILL.md + references\" -ForegroundColor Green
        }
        "gemini" {
            if ($Scope -eq "global") {
                $TargetDir = "$env:USERPROFILE\.gemini\skills\write-post"
            } else {
                $TargetDir = ".gemini\skills\write-post"
            }
            New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
            
            # Download SKILL.md with error handling
            try {
                Invoke-WebRequest -Uri "$RepoUrl/.claude/skills/write-post/SKILL.md" -OutFile "$TargetDir\SKILL.md" -ErrorAction Stop
            } catch {
                Write-Host "ERROR: Failed to download SKILL.md for Gemini CLI" -ForegroundColor Red
                exit 1
            }
            
            # Create references directory
            New-Item -ItemType Directory -Force -Path "$TargetDir\references" | Out-Null
            
            # Download template with warning on failure
            try {
                Invoke-WebRequest -Uri "$RepoUrl/.claude/skills/write-post/references/case-study-template.md" -OutFile "$TargetDir\references\case-study-template.md" -ErrorAction Stop
            } catch {
                Write-Host "WARNING: Failed to download references\case-study-template.md (Phase 3 template won't work)" -ForegroundColor Yellow
            }
            
            Write-Host "✓ Gemini CLI: $TargetDir\SKILL.md + references\" -ForegroundColor Green
        }
        "antigravity" {
            if ($Scope -eq "global") {
                $TargetDir = "$env:USERPROFILE\.gemini\antigravity\skills\write-post"
            } else {
                $TargetDir = ".agent\skills\write-post"
            }
            New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
            
            # Download SKILL.md with error handling
            try {
                Invoke-WebRequest -Uri "$RepoUrl/.claude/skills/write-post/SKILL.md" -OutFile "$TargetDir\SKILL.md" -ErrorAction Stop
            } catch {
                Write-Host "ERROR: Failed to download SKILL.md for Antigravity" -ForegroundColor Red
                exit 1
            }
            
            # Create references directory
            New-Item -ItemType Directory -Force -Path "$TargetDir\references" | Out-Null
            
            # Download template with warning on failure
            try {
                Invoke-WebRequest -Uri "$RepoUrl/.claude/skills/write-post/references/case-study-template.md" -OutFile "$TargetDir\references\case-study-template.md" -ErrorAction Stop
            } catch {
                Write-Host "WARNING: Failed to download references\case-study-template.md (Phase 3 template won't work)" -ForegroundColor Yellow
            }
            
            Write-Host "✓ Antigravity: $TargetDir\SKILL.md + references\" -ForegroundColor Green
        }
    }
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
