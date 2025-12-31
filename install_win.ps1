# ai-post-write installer for Windows PowerShell

$RepoUrl = "https://raw.githubusercontent.com/daht-mad/ai-post-write/main"

Write-Host "설치 위치를 선택하세요:"
Write-Host "1) 전역 설치 (모든 프로젝트에서 사용)"
Write-Host "2) 프로젝트 설치 (현재 폴더에서만 사용)"
$choice = Read-Host "선택 (1/2)"

if ($choice -eq "1") {
    $TargetDir = "$env:USERPROFILE\.claude\commands"
    $Scope = "전역"
} else {
    $TargetDir = ".claude\commands"
    $Scope = "프로젝트"
}

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
Invoke-WebRequest -Uri "$RepoUrl/.claude/commands/write-post.md" -OutFile "$TargetDir\write-post.md"

Write-Host ""
Write-Host "ai-post-write $Scope 설치 완료!" -ForegroundColor Green
Write-Host "사용법: /write-post"
