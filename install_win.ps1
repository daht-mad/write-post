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

# Frontmatter for non-Claude tools
$frontmatter = @"
---
name: write-post
description: DEVLOG 생성부터 AI 활용 사례 게시글 작성까지 한 번에 진행합니다. AI 코딩 도구의 대화 세션을 자동으로 파싱하여 개발 로그를 만들고, 비개발자 대상 사례글까지 작성합니다.
---

"@

# Installation function
function Install-Tool {
    param($Tool, $Scope)
    
    switch ($Tool) {
        "claude" {
            if ($Scope -eq "global") {
                $TargetDir = "$env:USERPROFILE\.claude\commands"
            } else {
                $TargetDir = ".claude\commands"
            }
            New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
            Invoke-WebRequest -Uri "$RepoUrl/.claude/commands/write-post.md" -OutFile "$TargetDir\write-post.md"
            Write-Host "✓ Claude Code: $TargetDir\write-post.md" -ForegroundColor Green
        }
        "opencode" {
            if ($Scope -eq "global") {
                $TargetDir = "$env:USERPROFILE\.config\opencode\skills\write-post"
            } else {
                $TargetDir = ".opencode\skills\write-post"
            }
            New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
            $content = (Invoke-WebRequest -Uri "$RepoUrl/.claude/commands/write-post.md").Content
            ($frontmatter + $content) | Out-File -FilePath "$TargetDir\SKILL.md" -Encoding UTF8
            Write-Host "✓ OpenCode: $TargetDir\SKILL.md" -ForegroundColor Green
        }
        "codex" {
            if ($Scope -eq "global") {
                $TargetDir = "$env:USERPROFILE\.codex\skills\write-post"
            } else {
                $TargetDir = ".codex\skills\write-post"
            }
            New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
            $content = (Invoke-WebRequest -Uri "$RepoUrl/.claude/commands/write-post.md").Content
            ($frontmatter + $content) | Out-File -FilePath "$TargetDir\SKILL.md" -Encoding UTF8
            Write-Host "✓ Codex CLI: $TargetDir\SKILL.md" -ForegroundColor Green
        }
        "gemini" {
            if ($Scope -eq "global") {
                $TargetDir = "$env:USERPROFILE\.gemini\skills\write-post"
            } else {
                $TargetDir = ".gemini\skills\write-post"
            }
            New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
            $content = (Invoke-WebRequest -Uri "$RepoUrl/.claude/commands/write-post.md").Content
            ($frontmatter + $content) | Out-File -FilePath "$TargetDir\SKILL.md" -Encoding UTF8
            Write-Host "✓ Gemini CLI: $TargetDir\SKILL.md" -ForegroundColor Green
        }
        "antigravity" {
            if ($Scope -eq "global") {
                $TargetDir = "$env:USERPROFILE\.gemini\antigravity\skills\write-post"
            } else {
                $TargetDir = ".agent\skills\write-post"
            }
            New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
            $content = (Invoke-WebRequest -Uri "$RepoUrl/.claude/commands/write-post.md").Content
            ($frontmatter + $content) | Out-File -FilePath "$TargetDir\SKILL.md" -Encoding UTF8
            Write-Host "✓ Antigravity: $TargetDir\SKILL.md" -ForegroundColor Green
        }
    }
}

# Install selected tools
Write-Host ""
foreach ($tool in $tools) {
    Install-Tool -Tool $tool -Scope $Scope
}

Write-Host ""
Write-Host "write-post $ScopeLabel 설치 완료!" -ForegroundColor Green
Write-Host "설치된 도구: $($tools -join ', ')"
Write-Host "사용법: /write-post"
