# Windows 호환성 개선 + 설치 스크립트 리팩토링

## TL;DR

> **Quick Summary**: Windows 환경에서 발생하는 두 가지 문제(PowerShell 한글 깨짐 + DEVLOG 작성 16분 지연)를 해결하고, 설치 스크립트의 중복 코드를 정리하며, 스킬 파일을 단일 파일로 통합하여 설치 프로세스를 단순화합니다.
> 
> **Deliverables**:
> - `install_win.ps1` — UTF-8 인코딩 수정 + 코드 중복 제거 + `exit 1` 안전화
> - `install_mac.sh` — 동일한 코드 중복 제거
> - `SKILL.md` — Windows 가이드 + 방어적 파싱 지침 + 템플릿 내용 통합
> - `references/case-study-template.md` — 삭제 (SKILL.md에 통합)
> - `README.md` — 설치 경로/구조 변경 반영
> 
> **Estimated Effort**: Medium
> **Parallel Execution**: YES - 2 waves
> **Critical Path**: Task 1 (단일 파일 통합) → Task 3 (install_win.ps1) → Task 4 (install_mac.sh)

---

## Context

### Original Request
Windows에서 write-post 사용 시 두 가지 문제:
1. PowerShell 설치 시 한글이 물음표(`?????`)로 깨짐
2. DEVLOG 작성이 ~16분 소요 (목표: 4분 이내)

원인 분석 보고서에 따르면:
- 셸 환경 오판 (CMD 문법 → Git Bash에서 실패)
- 백그라운드 에이전트 4개 전부 실패 (잘못된 파싱 로직 전달)
- 경로/인코딩 이슈 (Git Bash `/c/` vs Python `C:/` vs CMD `C:\`)

추가로 설치 스크립트 코드 중복 제거 + 단일 스킬 파일 통합 검토 요청.

### Interview Summary
**Key Discussions**:
- Windows Claude Code 프로젝트 폴더 패턴 미확인 → fallback 지침 포함하기로 결정
- SKILL.md Windows 가이드: 기존 도구별 섹션 내 인라인 추가 방식
- 범위: 핵심 수정 + 설치 스크립트 리팩토링 + 단일 파일 통합 검토

**Research Findings**:
- Microsoft 공식: `[Console]::OutputEncoding` + `$OutputEncoding` 둘 다 UTF-8 설정 필요
- Claude Code on Windows: Git Bash 사용, `process.platform=win32`, 경로 혼재 문제 다수
- Python Git Bash: cp949 인코딩 에러, `PYTHONIOENCODING=utf-8` 해결
- `iwr | iex` 파이프 실행 시 `exit 1`이 사용자 터미널을 닫을 수 있음 (PowerShell 알려진 이슈)

### Metis Review
**Identified Gaps** (addressed):
- Windows Claude Code 폴더 패턴 미확인 → SKILL.md에 fallback 지침 + "패턴 확인이 안 되면 `ls ~/.claude/projects/` 실행 후 선택" 안내 추가
- `exit 1`이 piped 실행 시 터미널 종료 → `return` 또는 `throw`로 교체
- `Invoke-WebRequest` 다운로드 파일 인코딩 검증 → `-Encoding UTF8` 또는 바이트 스트림 사용
- 템플릿 병합이 이전 36% 컨텍스트 절감 결정 뒤집음 → Phase 3 시작 지점 마커 추가로 대응
- 설치 스크립트 리팩토링 시 동작 동일성 검증 필요 → 경로 출력 비교 검증 포함

---

## Work Objectives

### Core Objective
Windows 환경에서 write-post의 설치/실행 안정성을 확보하고, 유지보수성을 개선합니다.

### Concrete Deliverables
- `SKILL.md` — Windows 가이드 + 방어적 파싱 + 템플릿 통합 (단일 파일)
- `install_win.ps1` — 인코딩 수정 + 리팩토링
- `install_mac.sh` — 리팩토링
- `README.md` — 변경사항 반영
- `references/` 디렉토리 — 삭제

### Definition of Done
- [x] PowerShell에서 한글이 정상 출력됨
- [x] SKILL.md에 Windows 환경 가이드가 포함됨
- [x] SKILL.md에 방어적 파싱 지침이 포함됨
- [x] 설치 스크립트에 코드 중복이 없음
- [x] 스킬 파일이 1개로 통합됨 (references/ 불필요)
- [x] 모든 5개 도구 × 2개 스코프 = 10가지 설치 경로가 기존과 동일함

### Must Have
- UTF-8 인코딩 초기화 (`[Console]::OutputEncoding` + `$OutputEncoding`)
- Windows 셸 환경 가이드 (Git Bash가 기본)
- 방어적 파싱 지침 (사전 샘플링)
- Windows 경로 표기법 테이블
- `exit 1` → 안전한 종료 방식으로 교체
- 설치 스크립트 중복 제거

### Must NOT Have (Guardrails)
- Phase 1/2/3 워크플로우 로직 변경 금지
- 기존 파싱 가이드 내용 재작성 금지 (인라인 추가만)
- 새로운 도구 추가 금지 (기존 5개만)
- 도구 선택 메뉴 구조 변경 금지
- Windows 전용 별도 섹션 생성 금지 (인라인으로만)
- SKILL.md 300줄 초과 시 주의 (통합 후 ~438줄 예상 → Phase 3 스킵 마커로 대응)

---

## Verification Strategy (MANDATORY)

### Test Decision
- **Infrastructure exists**: NO
- **User wants tests**: Manual-only
- **Framework**: none

### Manual QA Procedures

**설치 스크립트 검증**: 각 변경 후 PowerShell/Bash에서 dry-run 가능한 부분 확인
**SKILL.md 검증**: grep/wc 명령으로 필수 키워드 존재 여부 + 줄 수 확인
**경로 검증**: 리팩토링 전후 모든 경로 출력 비교

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately):
├── Task 1: SKILL.md 단일 파일 통합 (템플릿 병합 + Windows 가이드 + 방어적 파싱)
└── Task 2: Windows Claude Code 폴더 패턴 발견 + fallback 지침 포함

Wave 2 (After Wave 1):
├── Task 3: install_win.ps1 인코딩 수정 + 리팩토링
├── Task 4: install_mac.sh 리팩토링
└── Task 5: README.md 업데이트 + 최종 검증

Critical Path: Task 1 → Task 3 → Task 5
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 1 | None | 3, 4 | 2 |
| 2 | None | 1 (partial) | 1 |
| 3 | 1 | 5 | 4 |
| 4 | 1 | 5 | 3 |
| 5 | 3, 4 | None | None (final) |

### Agent Dispatch Summary

| Wave | Tasks | Recommended Agents |
|------|-------|-------------------|
| 1 | 1, 2 | `category="unspecified-high"` + `category="quick"` |
| 2 | 3, 4, 5 | 3개 모두 `category="quick"` |

---

## TODOs

- [x] 1. SKILL.md 단일 파일 통합 + Windows 가이드 + 방어적 파싱 추가

  **What to do**:

  **1-A. 템플릿 통합**: `references/case-study-template.md`의 전체 내용을 SKILL.md의 Phase 3 섹션 끝에 통합
  - Phase 3 Step 4 (line 272-273)의 `references/case-study-template.md 파일을 읽고` → `아래 템플릿에 맞춰`로 변경
  - 템플릿 내용을 Phase 3 마지막에 `## 게시글 템플릿 및 작성 가이드` 섹션으로 추가
  - 기존 `references/case-study-template.md` 파일 삭제
  - `references/` 디렉토리 삭제

  **1-B. Windows 환경 가이드 추가** (각 도구별 파싱 가이드 내 인라인):
  
  (a) **Claude Code 섹션** (line 102-106 근처)에 추가:
  ```markdown
  > **Windows 참고:**
  > - Claude Code는 Windows에서 Git Bash를 셸로 사용합니다. `process.platform`이 `win32`로 보고되더라도 **bash 문법**을 사용하세요 (CMD/PowerShell 문법 사용 금지).
  > - 프로젝트 경로 매칭: Windows에서의 폴더명 패턴이 다를 수 있습니다. 매칭이 안 되면 `ls ~/.claude/projects/` 실행 후 현재 프로젝트에 해당하는 폴더를 직접 찾으세요.
  > - Python으로 파싱할 때: Git Bash 경로(`/c/Users/...`) 대신 Python 네이티브 경로(`C:/Users/...`) 사용. `PYTHONIOENCODING=utf-8` 환경변수 필수.
  ```

  (b) **OpenCode 섹션** (line 109-118 근처)에 추가:
  ```markdown
  > **Windows:** `%USERPROFILE%\.local\share\opencode\storage\` 경로 사용. Python에서는 `os.path.expanduser('~')` 활용.
  ```

  (c) **Codex CLI 섹션** (line 121-125 근처)에 추가:
  ```markdown
  > **Windows:** `%USERPROFILE%\.codex\sessions\` 경로 사용.
  ```

  (d) **Gemini CLI 섹션** (line 128-132 근처)에 추가:
  ```markdown
  > **Windows:** `%USERPROFILE%\.gemini\tmp\` 경로 사용.
  ```

  **1-C. 방어적 파싱 지침 추가**: "프로젝트 세션 스캔" 섹션(line 16-29 근처) 바로 아래, "출력 포맷" 섹션 직전에 삽입:
  ```markdown
  ### 파싱 사전 검증 (필수)

  세션 파일을 대량 파싱하기 전에 **반드시** 다음 사전 검증을 수행하세요:

  1. **셸 환경 확인**: 첫 번째 명령 실행 전 `echo $SHELL` 또는 `echo $0`으로 현재 셸 확인. Windows에서 Git Bash가 기본이므로 Unix 명령어(ls, cat, grep) 사용.
  2. **파일 1개 샘플링**: 전체 파싱 전에 대상 파일 1개를 먼저 읽어 구조 확인. JSONL의 경우 첫 줄을 파싱하여 필드명(`type`, `content` 등)과 값(`user`/`assistant` — `human`/`ai` 아님)을 검증.
  3. **경로 표기법 통일**: 
     | 환경 | 경로 형식 | 예시 |
     |------|----------|------|
     | Git Bash 셸 | `/c/Users/...` | `ls /c/Users/name/.claude/` |
     | Python 스크립트 | `C:/Users/...` | `glob.glob('C:/Users/name/.claude/**')` |
     | PowerShell/CMD | `C:\Users\...` | `dir C:\Users\name\.claude\` |
     
     Python에서는 항상 `os.path.expanduser('~')` 또는 `C:/` 형식 사용.
  4. **인코딩 설정**: Python 실행 시 `PYTHONIOENCODING=utf-8` 환경변수 설정. Windows 기본 인코딩(cp949)으로 인한 UnicodeEncodeError 방지.
  5. **에이전트 위임 전 검증**: 백그라운드 에이전트에게 파싱 로직을 위임할 때, 위 1-4 검증을 완료한 로직만 전달. 검증되지 않은 가정(필드명, 경로 형식)을 에이전트에게 넘기지 마세요.
  ```

  **Must NOT do**:
  - Phase 1/2/3 워크플로우 로직 변경
  - 기존 파싱 가이드 내용 삭제 또는 재작성
  - Windows 전용 별도 대섹션 생성

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: SKILL.md 수정은 섬세한 편집이 필요하고 여러 위치에 변경이 들어감
  - **Skills**: [`write-post`]
    - `write-post`: SKILL.md의 구조와 의도를 이해하기 위해 필요

  **Parallelization**:
  - **Can Run In Parallel**: YES (Task 2와 병렬)
  - **Parallel Group**: Wave 1
  - **Blocks**: Task 3, Task 4 (설치 스크립트가 단일 파일 기준으로 리팩토링됨)
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `SKILL.md:16-29` — "프로젝트 세션 스캔" 섹션: 방어적 파싱 지침을 이 섹션 아래에 삽입
  - `SKILL.md:100-146` — 도구별 파싱 가이드: 각 도구 섹션 끝에 `> **Windows:**` 블록쿼트 추가
  - `SKILL.md:272-273` — Phase 3 Step 4: 템플릿 참조 경로를 인라인 참조로 변경
  - `case-study-template.md:1-160` — Phase 3 끝에 통합할 전체 내용

  **Documentation References**:
  - `.sisyphus/notepads/multi-agent-write-post/decisions.md:26-65` — Windows PowerShell 설치 관련 기존 결정 사항
  - `.sisyphus/notepads/multi-tool-project-scan/learnings.md:29` — SKILL.md 300줄 제한 배경 (통합 시 초과할 수 있음에 유의)

  **External References**:
  - [Claude Code Windows Setup](https://code.claude.com/docs/en/setup) — Windows에서 Git Bash가 기본 셸임을 확인
  - [PowerShell Mojibake Fix](https://hy2k.dev/en/blog/2025/11-20-fix-powershell-mojibake-on-windows/) — 인코딩 설정 상세 설명

  **WHY Each Reference Matters**:
  - `SKILL.md:16-29`: 방어적 파싱 지침의 정확한 삽입 위치를 결정
  - `SKILL.md:100-146`: 각 도구별 인라인 Windows 주석의 삽입 위치
  - `case-study-template.md`: 통합 시 누락 없이 전체 내용을 옮겨야 함
  - `decisions.md`: 이전 결정 사항과의 충돌 여부 확인 (300줄 제한 등)

  **Acceptance Criteria**:

  **Manual Execution Verification:**
  - [x] `grep -c "Windows" SKILL.md` → 최소 5개 이상 (각 도구 섹션 + 경로 표)
  - [x] `grep "파싱 사전 검증" SKILL.md` → 1개 존재
  - [x] `grep "셸 환경 확인" SKILL.md` → 1개 존재
  - [x] `grep "파일 1개 샘플링" SKILL.md` → 1개 존재
  - [x] `grep "경로 표기법 통일" SKILL.md` → 1개 존재
  - [x] `grep "에이전트 위임 전 검증" SKILL.md` → 1개 존재
  - [x] `grep "PYTHONIOENCODING" SKILL.md` → 최소 1개 존재
  - [x] `grep "references/case-study-template.md" SKILL.md` → 0개 (파일 참조 제거됨)
  - [x] `ls .claude/skills/write-post/references/` → 디렉토리 없음 (삭제됨)
  - [x] `wc -l SKILL.md` → 약 430-450줄 범위
  - [x] Phase 1/2/3 워크플로우 키워드 존재 확인:
    - `grep "Phase 1" SKILL.md` → 존재
    - `grep "Phase 2" SKILL.md` → 존재
    - `grep "Phase 3" SKILL.md` → 존재
  - [x] 기존 5개 도구 파싱 가이드 존재 확인:
    - `grep "#### 1. Claude Code" SKILL.md` → 존재
    - `grep "#### 2. OpenCode" SKILL.md` → 존재
    - `grep "#### 3. Codex CLI" SKILL.md` → 존재
    - `grep "#### 4. Gemini CLI" SKILL.md` → 존재
    - `grep "#### 5. Antigravity" SKILL.md` → 존재

  **Commit**: YES
  - Message: `feat(skill): add Windows guidance, defensive parsing, and merge template into single file`
  - Files: `SKILL.md`, (삭제) `references/case-study-template.md`
  - Pre-commit: 위 grep 검증 전부 통과

---

- [x] 2. Windows Claude Code 프로젝트 폴더 패턴 확인

  **What to do**:
  Windows 환경에서 Claude Code가 프로젝트 폴더명을 어떻게 인코딩하는지 확인합니다.
  
  1. 사용자에게 Windows 머신에서 다음 명령 실행 요청:
     ```powershell
     ls $env:USERPROFILE\.claude\projects\
     ```
     또는 Git Bash에서:
     ```bash
     ls ~/.claude/projects/
     ```
  2. 출력된 폴더명과 실제 프로젝트 경로를 비교하여 인코딩 패턴 파악
     - Unix: `/Users/dahye/DEV/my-app` → `-Users-dahye-DEV-my-app`
     - Windows 예상 패턴: `C:\Users\SAMSUNG\DEV\my-app` → `?` (미확인)
  3. 확인된 패턴을 Task 1의 Claude Code Windows 섹션에 반영

  **참고**: 패턴 확인이 불가능한 경우, Task 1에 이미 포함된 fallback 지침("매칭 안 되면 `ls`로 직접 찾기")으로 대응 가능. 이 경우 이 태스크는 skip 가능.

  **Must NOT do**:
  - 패턴을 추측하여 문서에 반영하지 말 것
  - 확인 없이 가정한 패턴을 작성하지 말 것

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 사용자에게 명령 실행 요청 + 결과 반영하는 단순 작업
  - **Skills**: [`write-post`]

  **Parallelization**:
  - **Can Run In Parallel**: YES (Task 1과 병렬 — 결과가 나오면 Task 1에 추가 반영)
  - **Parallel Group**: Wave 1
  - **Blocks**: None (fallback 지침이 이미 Task 1에 포함)
  - **Blocked By**: None

  **References**:
  - `SKILL.md:103` — Unix 프로젝트 매칭 패턴 설명: `/Users/dahye/DEV/my-app` → `-Users-dahye-DEV-my-app`
  - `.sisyphus/drafts/windows-compatibility.md:48-50` — Windows 패턴 미확인 기록

  **WHY Each Reference Matters**:
  - `SKILL.md:103`: 현재 Unix 패턴을 이해하고 Windows 패턴과 비교하기 위함
  - Draft 파일: 이 문제가 식별된 맥락을 이해하기 위함

  **Acceptance Criteria**:
  - [x] Windows Claude Code 프로젝트 폴더 패턴이 확인됨 (예: `C--Users-SAMSUNG-DEV-my-app` 등)
  - [x] 또는: 확인 불가 시 fallback 지침 유지 확인 (`grep "매칭이 안 되면" SKILL.md` → 존재)

  **Commit**: NO (Task 1 커밋에 포함 또는 별도 커밋)

---

- [x] 3. install_win.ps1 인코딩 수정 + 리팩토링

  **What to do**:

  **3-A. UTF-8 인코딩 초기화** (스크립트 최상단, `$RepoUrl` 선언 전에 추가):
  ```powershell
  # UTF-8 encoding for Korean text display
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
  $OutputEncoding = [System.Text.Encoding]::UTF8
  ```

  **3-B. `exit 1` 안전화**: 
  `iwr ... | iex` 파이프 실행 시 `exit 1`이 사용자 터미널 전체를 닫는 PowerShell 알려진 이슈.
  - 모든 `exit 1` (line 67, 93, 120, 149, 178)을 `throw "ERROR: ..."` 또는 `Write-Host "ERROR: ..." -ForegroundColor Red; return`으로 교체
  - `throw`는 파이프 실행에서도 안전하게 스크립트만 중단

  **3-C. 코드 중복 제거 리팩토링**:
  현재 `Install-Tool` 함수의 switch 문 내 5개 도구 블록이 거의 동일. 차이점은 도구명/경로뿐.
  
  리팩토링 전략:
  ```powershell
  # 도구별 경로 매핑 테이블
  $ToolPaths = @{
      "claude" = @{ Global = "$env:USERPROFILE\.claude\skills\write-post"; Project = ".claude\skills\write-post"; Label = "Claude Code" }
      "opencode" = @{ Global = "$env:USERPROFILE\.config\opencode\skills\write-post"; Project = ".opencode\skills\write-post"; Label = "OpenCode" }
      "codex" = @{ Global = "$env:USERPROFILE\.codex\skills\write-post"; Project = ".codex\skills\write-post"; Label = "Codex CLI" }
      "gemini" = @{ Global = "$env:USERPROFILE\.gemini\skills\write-post"; Project = ".gemini\skills\write-post"; Label = "Gemini CLI" }
      "antigravity" = @{ Global = "$env:USERPROFILE\.gemini\antigravity\skills\write-post"; Project = ".agent\skills\write-post"; Label = "Antigravity" }
  }

  function Install-Tool {
      param($Tool, $Scope)
      $paths = $ToolPaths[$Tool]
      $TargetDir = if ($Scope -eq "global") { $paths.Global } else { $paths.Project }
      
      New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
      
      try {
          Invoke-WebRequest -Uri "$RepoUrl/.claude/skills/write-post/SKILL.md" -OutFile "$TargetDir\SKILL.md" -ErrorAction Stop
      } catch {
          Write-Host "ERROR: Failed to download SKILL.md for $($paths.Label)" -ForegroundColor Red
          throw "Download failed for $($paths.Label)"
      }
      
      Write-Host "✓ $($paths.Label): $TargetDir\SKILL.md" -ForegroundColor Green
  }
  ```

  **3-D. 단일 파일 반영**: Task 1에서 템플릿을 SKILL.md에 통합했으므로:
  - `references/` 디렉토리 생성 코드 제거
  - `case-study-template.md` 다운로드 코드 제거
  - 다운로드 파일이 `SKILL.md` 1개로 축소

  **Must NOT do**:
  - 도구 선택 메뉴 UI 변경 금지
  - 새로운 도구 추가 금지
  - 사용자 인터랙션 방식 변경 금지 (`[Console]::ReadLine()` 유지)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 정해진 패턴에 따른 코드 편집. 로직 복잡도 낮음
  - **Skills**: []
    - 특별한 스킬 필요 없음 (순수 PowerShell 스크립팅)

  **Parallelization**:
  - **Can Run In Parallel**: YES (Task 4와 병렬)
  - **Parallel Group**: Wave 2
  - **Blocks**: Task 5
  - **Blocked By**: Task 1

  **References**:

  **Pattern References**:
  - `install_win.ps1:1-222` — 전체 파일 (리팩토링 대상)
  - `install_win.ps1:50-195` — `Install-Tool` 함수: 5개 switch case 블록이 중복의 핵심

  **API/Type References**:
  - `install_win.ps1:3` — `$RepoUrl` 변수: 다운로드 URL 기반
  - `install_win.ps1:6-21` — 메뉴 UI: 변경하면 안 되는 부분

  **Documentation References**:
  - `.sisyphus/notepads/multi-agent-write-post/decisions.md:26-65` — Windows PowerShell 설치 관련 기존 결정 사항 (경로 매핑 테이블 포함)

  **External References**:
  - [Fixing Mojibake in PowerShell](https://hy2k.dev/en/blog/2025/11-20-fix-powershell-mojibake-on-windows/) — UTF-8 인코딩 설정 방법
  - [IBM PowerShell Encoding Fix](https://www.ibm.com/docs/en/noi/1.6.13?topic=chs-ssh-automation-action-output-powershell-shows-garbled-multi-byte-characters) — `$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8` 단축 패턴

  **WHY Each Reference Matters**:
  - `install_win.ps1` 전체: 리팩토링의 원본 코드. 기능 동일성 검증의 기준
  - `decisions.md`: 기존 경로 매핑 결정과 일치하는지 확인 (경로 변경 금지)
  - 외부 참고: 인코딩 수정의 정확한 코드 패턴

  **Acceptance Criteria**:

  **Manual Execution Verification:**
  - [x] `grep "OutputEncoding" install_win.ps1` → 최소 2줄 존재 (`[Console]::OutputEncoding`, `$OutputEncoding`)
  - [x] `grep "exit 1" install_win.ps1` → 0개 (모두 제거됨)
  - [x] `grep "throw\|return" install_win.ps1` → exit 1이 있던 자리에 대체 코드 존재
  - [x] `grep "case-study-template" install_win.ps1` → 0개 (다운로드 코드 제거됨)
  - [x] `grep "references" install_win.ps1` → 0개 (디렉토리 생성 코드 제거됨)
  - [x] 코드 중복 검증: switch 문 내부가 도구별 5블록 반복이 아닌 1개 공통 로직
  - [x] 경로 동일성 검증: 다음 10가지 경로가 리팩토링 전과 동일
    - claude/global: `$env:USERPROFILE\.claude\skills\write-post`
    - claude/project: `.claude\skills\write-post`
    - opencode/global: `$env:USERPROFILE\.config\opencode\skills\write-post`
    - opencode/project: `.opencode\skills\write-post`
    - codex/global: `$env:USERPROFILE\.codex\skills\write-post`
    - codex/project: `.codex\skills\write-post`
    - gemini/global: `$env:USERPROFILE\.gemini\skills\write-post`
    - gemini/project: `.gemini\skills\write-post`
    - antigravity/global: `$env:USERPROFILE\.gemini\antigravity\skills\write-post`
    - antigravity/project: `.agent\skills\write-post`
  - [x] `wc -l install_win.ps1` → 기존 222줄 대비 대폭 감소 (예상: ~80-100줄)

  **Commit**: YES
  - Message: `fix(installer): add UTF-8 encoding, safe exit, and deduplicate PowerShell installer`
  - Files: `install_win.ps1`
  - Pre-commit: 위 grep 검증 전부 통과

---

- [x] 4. install_mac.sh 리팩토링

  **What to do**:

  **4-A. 코드 중복 제거**: `install_win.ps1`과 동일한 패턴으로 리팩토링.
  현재 `install_tool()` 함수의 case 문 내 5개 도구 블록이 거의 동일.
  
  리팩토링 전략 (⚠️ macOS 기본 bash 3.2 호환 필수 — `declare -A` 사용 금지):
  ```bash
  install_tool() {
      local tool=$1 scope=$2
      local target_dir label
      
      # Path and label lookup (case문은 유지하되, 설치 로직은 공통화)
      case "$tool" in
          "claude")     label="Claude Code"; [ "$scope" = "global" ] && target_dir="$HOME/.claude/skills/write-post" || target_dir=".claude/skills/write-post" ;;
          "opencode")   label="OpenCode"; [ "$scope" = "global" ] && target_dir="$HOME/.config/opencode/skills/write-post" || target_dir=".opencode/skills/write-post" ;;
          "codex")      label="Codex CLI"; [ "$scope" = "global" ] && target_dir="$HOME/.codex/skills/write-post" || target_dir=".codex/skills/write-post" ;;
          "gemini")     label="Gemini CLI"; [ "$scope" = "global" ] && target_dir="$HOME/.gemini/skills/write-post" || target_dir=".gemini/skills/write-post" ;;
          "antigravity") label="Antigravity"; [ "$scope" = "global" ] && target_dir="$HOME/.gemini/antigravity/skills/write-post" || target_dir=".agent/skills/write-post" ;;
      esac
      
      # 공통 설치 로직 (1회만 작성 — 기존 5회 반복 제거)
      mkdir -p "$target_dir"
      if ! curl -fsSL "$REPO_URL/.claude/skills/write-post/SKILL.md" -o "$target_dir/SKILL.md"; then
          echo "ERROR: Failed to download SKILL.md for $label" >&2
          exit 1
      fi
      echo "✓ $label: $target_dir/SKILL.md"
  }
  ```
  
  **핵심**: case문으로 경로/라벨만 결정하고, 실제 다운로드/설치 로직은 case 밖에서 1회만 작성.
  기존: 5개 case 블록 각각에 mkdir+curl+echo 반복 (120줄) → 리팩토링 후: 경로 lookup + 공통 로직 (20줄)

  **4-B. 단일 파일 반영**: Task 1에서 템플릿 통합했으므로:
  - `references/` 디렉토리 생성 (`mkdir -p "$TARGET_DIR/references"`) 제거
  - `case-study-template.md` 다운로드 (`curl ... case-study-template.md`) 제거
  - 완료 메시지에서 `+ references/` 제거

  **Must NOT do**:
  - 도구 선택 메뉴 변경 금지
  - `read -p ... </dev/tty` 패턴 변경 금지 (curl | bash 호환성)
  - 사용자에게 보이는 텍스트 변경 금지

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Task 3과 동일한 패턴. PowerShell → Bash 번역
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (Task 3과 병렬)
  - **Parallel Group**: Wave 2
  - **Blocks**: Task 5
  - **Blocked By**: Task 1

  **References**:

  **Pattern References**:
  - `install_mac.sh:1-199` — 전체 파일 (리팩토링 대상)
  - `install_mac.sh:51-178` — `install_tool()` 함수: 5개 case 블록이 중복의 핵심
  - `install_win.ps1` (Task 3 완료본) — 리팩토링 패턴 참고 (동일 구조 유지)

  **WHY Each Reference Matters**:
  - `install_mac.sh` 전체: 기능 동일성 검증의 기준
  - `install_win.ps1` 완료본: 두 스크립트의 구조적 일관성 유지

  **Acceptance Criteria**:

  **Manual Execution Verification:**
  - [x] `grep "case-study-template" install_mac.sh` → 0개
  - [x] `grep "references" install_mac.sh` → 0개
  - [x] case 문 내부가 5블록 반복이 아닌 1개 공통 로직
  - [x] 경로 동일성 검증: 10가지 경로 (5 tools × 2 scopes) 모두 기존과 동일
    - claude/global: `$HOME/.claude/skills/write-post`
    - claude/project: `.claude/skills/write-post`
    - opencode/global: `$HOME/.config/opencode/skills/write-post`
    - opencode/project: `.opencode/skills/write-post`
    - codex/global: `$HOME/.codex/skills/write-post`
    - codex/project: `.codex/skills/write-post`
    - gemini/global: `$HOME/.gemini/skills/write-post`
    - gemini/project: `.gemini/skills/write-post`
    - antigravity/global: `$HOME/.gemini/antigravity/skills/write-post`
    - antigravity/project: `.agent/skills/write-post`
  - [x] `wc -l install_mac.sh` → 기존 199줄 대비 대폭 감소 (예상: ~80-100줄)

  **Commit**: YES
  - Message: `refactor(installer): deduplicate Mac/Linux installer and remove template download`
  - Files: `install_mac.sh`
  - Pre-commit: 위 grep 검증 전부 통과

---

- [x] 5. README.md 업데이트 + 최종 검증

  **What to do**:

  **5-A. README.md 변경사항 반영**:
  - 설치 경로 테이블에서 `SKILL.md + references/` → `SKILL.md` (단일 파일)로 수정
  - 설치 경로 테이블이 이미 최신인지 확인 (현재 `~/.claude/skills/write-post/` 형태로 정확)
  - "설치 후" 섹션에 Windows PowerShell 인코딩 관련 참고사항 추가 (필요 시)

  **5-B. 최종 통합 검증**:
  - 모든 변경 파일 목록 확인
  - `references/` 디렉토리가 삭제되었는지 확인
  - 3개 수정 파일(SKILL.md, install_win.ps1, install_mac.sh) + 1개 업데이트 파일(README.md) + 1개 삭제(references/) 정리

  **Must NOT do**:
  - README 전면 재작성 금지
  - 새로운 기능 설명 추가 금지 (기존 변경사항 반영만)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 간단한 문서 업데이트와 검증
  - **Skills**: [`write-post`]

  **Parallelization**:
  - **Can Run In Parallel**: NO (최종 태스크)
  - **Parallel Group**: Wave 2 (Task 3, 4 완료 후)
  - **Blocks**: None
  - **Blocked By**: Task 1, Task 3, Task 4

  **References**:

  **Pattern References**:
  - `README.md` — 전체 파일, 특히 "설치 경로" 테이블 섹션
  - SKILL.md (Task 1 완료본), install_win.ps1 (Task 3 완료본), install_mac.sh (Task 4 완료본) — 변경 내용 크로스체크

  **WHY Each Reference Matters**:
  - `README.md`: 사용자가 처음 보는 문서. 설치 경로/방법이 정확해야 함
  - 완료본들: README가 실제 변경사항을 정확히 반영하는지 검증

  **Acceptance Criteria**:

  **Manual Execution Verification:**
  - [x] `grep "references" README.md` → 0개 (references 관련 설명 제거)
  - [x] README의 설치 경로 테이블이 실제 스크립트 경로와 일치
  - [x] `ls .claude/skills/write-post/` → SKILL.md만 존재 (references/ 없음)
  - [x] `git diff --stat` → 변경 파일 목록이 예상과 일치:
    - Modified: SKILL.md, install_win.ps1, install_mac.sh, README.md
    - Deleted: references/case-study-template.md

  **Commit**: YES
  - Message: `docs(readme): update installation paths for single-file skill structure`
  - Files: `README.md`
  - Pre-commit: 위 검증 통과

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 | `feat(skill): add Windows guidance, defensive parsing, and merge template into single file` | SKILL.md, (삭제) references/case-study-template.md | grep 검증 |
| 3 | `fix(installer): add UTF-8 encoding, safe exit, and deduplicate PowerShell installer` | install_win.ps1 | grep + 경로 검증 |
| 4 | `refactor(installer): deduplicate Mac/Linux installer and remove template download` | install_mac.sh | grep + 경로 검증 |
| 5 | `docs(readme): update installation paths for single-file skill structure` | README.md | grep + git diff 검증 |

---

## Success Criteria

### Verification Commands
```bash
# SKILL.md 검증
grep -c "Windows" .claude/skills/write-post/SKILL.md         # Expected: >= 5
grep "파싱 사전 검증" .claude/skills/write-post/SKILL.md      # Expected: 1 match
grep "PYTHONIOENCODING" .claude/skills/write-post/SKILL.md    # Expected: >= 1
grep "references/case-study-template" .claude/skills/write-post/SKILL.md  # Expected: 0

# install_win.ps1 검증
grep "OutputEncoding" install_win.ps1    # Expected: >= 2
grep "exit 1" install_win.ps1           # Expected: 0
grep "case-study-template" install_win.ps1  # Expected: 0

# install_mac.sh 검증
grep "case-study-template" install_mac.sh   # Expected: 0
grep "references" install_mac.sh            # Expected: 0

# 파일 구조 검증
ls .claude/skills/write-post/               # Expected: SKILL.md only
ls .claude/skills/write-post/references/    # Expected: No such directory
```

### Final Checklist
- [x] PowerShell 한글 깨짐 수정됨 (`OutputEncoding` + `$OutputEncoding` UTF-8)
- [x] SKILL.md에 Windows 셸 가이드 포함
- [x] SKILL.md에 방어적 파싱 5단계 지침 포함
- [x] SKILL.md에 경로 표기법 테이블 포함
- [x] 스킬 파일 1개로 통합 (references/ 디렉토리 삭제)
- [x] install_win.ps1 코드 중복 제거 + exit 1 안전화
- [x] install_mac.sh 코드 중복 제거
- [x] 모든 설치 경로(20가지: 5 tools × 2 scopes × 2 platforms)가 변경 전과 동일
- [x] README.md가 변경사항 반영
