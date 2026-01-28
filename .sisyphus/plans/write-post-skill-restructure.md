# write-post 스킬 구조적 개선 (skill-creator 가이드라인 적용)

## Context

### Original Request
skill-creator 스킬의 가이드라인을 적용하여 write-post 스킬을 구조적으로 개선. 모놀리식 단일 파일에서 Progressive Disclosure 패턴의 디렉토리 구조로 전환.

### Interview Summary
**Key Discussions**:
- 배포 모델: 디렉토리 구조 전환 (SKILL.md + references/) 선택
- Claude Code 경로: `.claude/commands/` → `.claude/skills/write-post/` 전환
- Phase 3 분리: 템플릿 + 작성 가이드만 references/로 분리 (프로세스는 SKILL.md 유지)

**Research Findings**:
- skill-creator 가이드라인: SKILL.md <500줄, Progressive Disclosure via references/, YAML frontmatter 필수
- Claude Code `.claude/skills/` 검증 완료: `~/.claude/skills/skill-creator/` 실제 존재, references/ 디렉토리 지원 확인
- 현재 write-post.md: 392줄 (모놀리식), frontmatter 없음

### Metis Review
**Identified Gaps** (addressed):
- 이전 버전 설치 사용자 호환성 → `.claude/commands/write-post.md`에 리다이렉트 stub 유지
- 설치 스크립트 부분 다운로드 실패 → 에러 처리 추가
- 이전 설치 정리 로직 → 프로젝트/전역 양쪽 모두 cleanup
- 콘텐츠 손실 방지 → 분할 후 diff 검증 태스크 포함
- frontmatter 통합 → 모든 도구가 동일한 SKILL.md 사용 (frontmatter 주입 불필요)

---

## Work Objectives

### Core Objective
write-post 스킬을 skill-creator 가이드라인에 맞게 디렉토리 구조로 전환하고, Progressive Disclosure 패턴을 적용하여 context 효율성을 개선한다.

### Concrete Deliverables
- `.claude/skills/write-post/SKILL.md` - 핵심 워크플로우 (~250줄)
- `.claude/skills/write-post/references/case-study-template.md` - 사례글 템플릿 + 작성 가이드 (~140줄)
- `.claude/commands/write-post.md` - 이전 경로 리다이렉트 stub
- `install_mac.sh` - 디렉토리 구조 다운로드 + 경로 변경
- `install_win.ps1` - 디렉토리 구조 다운로드 + 경로 변경
- `README.md` - 새 경로 반영

### Definition of Done
- [x] `/write-post` 커맨드가 Claude Code에서 동일하게 동작
- [x] SKILL.md가 300줄 이하
- [x] Phase 3 초안 작성 시 references/case-study-template.md 참조 지침 포함
- [x] 설치 스크립트가 2개 파일을 다운로드
- [x] 이전 경로에 리다이렉트 stub 존재

### Must Have
- YAML frontmatter (name, description)
- Progressive Disclosure: SKILL.md + references/ 분리
- 모든 도구에서 동일한 SKILL.md 사용 (frontmatter 주입 불필요)
- 이전 설치 사용자를 위한 cleanup 로직
- 콘텐츠 무손실 (분할 전후 내용 동일)

### Must NOT Have (Guardrails)
- Phase 1/2/3 워크플로우 로직 변경 (파일 간 이동만, 내용 수정 금지)
- YAML frontmatter name/description 텍스트 변경
- 설치 스크립트 구조 리팩토링 (다운로드 경로만 변경)
- README 섹션 재작성 (경로 업데이트만)
- 스킬 디렉토리 내 불필요한 파일 추가 (README, CHANGELOG 등)
- references/ 내 파일 2개 이상 생성 (case-study-template.md만)

---

## Verification Strategy (MANDATORY)

### Test Decision
- **Infrastructure exists**: NO (마크다운 스킬 파일)
- **User wants tests**: Manual-only
- **Framework**: 없음

### Manual QA
- Claude Code에서 `/write-post` 커맨드 실행 가능 여부 확인
- SKILL.md + references/ 내용이 기존 write-post.md와 동일한지 diff 검증
- 설치 스크립트 bash -n / PowerShell 문법 검증

---

## Task Flow

```
Task 1 (SKILL.md + references/ 생성)
    ↓
Task 2 (콘텐츠 무손실 검증)
    ↓
Task 3 (이전 경로 리다이렉트 stub)
    ↓
Task 4 (install_mac.sh 업데이트) ←→ Task 5 (install_win.ps1 업데이트) [병렬]
    ↓
Task 6 (README.md 업데이트)
    ↓
Task 7 (End-to-end 검증)
```

## Parallelization

| Group | Tasks | Reason |
|-------|-------|--------|
| A | 4, 5 | 독립적인 플랫폼별 설치 스크립트 |

| Task | Depends On | Reason |
|------|------------|--------|
| 2 | 1 | 분할 파일 생성 후 검증 |
| 3 | 1 | SKILL.md 경로 확정 후 stub 작성 |
| 4, 5 | 1, 3 | 다운로드 대상 파일과 경로 확정 후 |
| 6 | 1, 4, 5 | 전체 변경사항 반영 |
| 7 | ALL | 최종 검증 |

---

## TODOs

- [x] 1. SKILL.md + references/case-study-template.md 생성

  **What to do**:

  현재 `.claude/commands/write-post.md` (392줄)를 두 파일로 분할:

  ### 1-1. `.claude/skills/write-post/SKILL.md` 생성 (~250줄)

  **구조**:
  ```markdown
  ---
  name: write-post
  description: DEVLOG 생성부터 AI 활용 사례 게시글 작성까지 한 번에 진행합니다. AI 코딩 도구의 대화 세션을 자동으로 파싱하여 개발 로그를 만들고, 비개발자 대상 사례글까지 작성합니다.
  ---

  # AI 활용 사례 게시글 작성
  (기존 lines 1-3 유지)

  # Phase 1: DEVLOG 생성
  (기존 lines 13-158 전체 유지: 환경 감지 + 출력 포맷 + 세션 파싱 + 정리 규칙)

  # Phase 2: DEVLOG 확인
  (기존 lines 162-189 전체 유지)

  # Phase 3: AI 활용 사례 게시글 작성
  (기존 lines 192-253 유지: 프로세스 개요 + 질문 순서 + 제목 선정)
  (4단계 부분만 수정: 기존 "아래 템플릿에 맞춰" → "`references/case-study-template.md` 파일을 읽고 템플릿에 맞춰")
  ```

  **핵심 변경점**:
  - YAML frontmatter 추가 (5줄)
  - 기존 lines 1-253 내용 그대로 유지
  - line 249 (4단계) 수정: 템플릿 참조를 references/ 파일로 변경
  - 기존 lines 255-392 (템플릿 + 가이드 + 마무리) 제거 → references/로 이동
  - "사용법" 섹션 (lines 5-9) 제거 (Claude가 이미 알고 있는 정보 — skill-creator "Concise is Key" 원칙)

  ### 1-2. `.claude/skills/write-post/references/case-study-template.md` 생성 (~140줄)

  **구조**:
  ```markdown
  # AI 활용 사례 게시글 작성 가이드

  ## 목차
  - 게시글 템플릿
  - 작성 시 주의사항
  - 마무리 안내

  ## 게시글 템플릿
  (기존 lines 257-350 그대로)

  ## 작성 시 주의사항
  (기존 lines 354-365 그대로)

  ## 마무리 안내
  (기존 lines 369-392 그대로)
  ```

  **Must NOT do**:
  - 템플릿이나 가이드 내용 수정 (verbatim 이동만)
  - SKILL.md에 Phase 3 질문 프로세스 삭제
  - references/ 내 추가 파일 생성

  **Parallelizable**: NO (모든 태스크의 기반)

  **References**:
  - `.claude/commands/write-post.md` - 현재 전체 내용 (392줄). 이 파일을 분할의 원본으로 사용
  - `~/.claude/skills/skill-creator/SKILL.md` - YAML frontmatter 형식 참조
  - `~/.claude/skills/skill-creator/references/` - references/ 디렉토리 구조 참조
  - skill-creator SKILL.md의 Progressive Disclosure 섹션 - 패턴 참조

  **Acceptance Criteria**:
  - [ ] `.claude/skills/write-post/SKILL.md` 파일이 생성됨
  - [ ] SKILL.md에 YAML frontmatter(name, description) 포함
  - [ ] SKILL.md가 300줄 이하
  - [ ] Phase 1 전체 (환경 감지 + 출력 포맷 + 세션 파싱 + 정리 규칙)가 SKILL.md에 포함
  - [ ] Phase 2 전체가 SKILL.md에 포함
  - [ ] Phase 3 프로세스 (1-5단계)가 SKILL.md에 포함
  - [ ] 4단계에서 `references/case-study-template.md` 참조 지침 포함
  - [ ] `.claude/skills/write-post/references/case-study-template.md` 파일이 생성됨
  - [ ] 게시글 템플릿 전체가 references 파일에 포함
  - [ ] 작성 시 주의사항 10개 항목이 references 파일에 포함
  - [ ] 마무리 안내 (이미지 추천 + 업로드)가 references 파일에 포함

  **Commit**: NO (Task 2 검증 후 함께 커밋)

---

- [x] 2. 콘텐츠 무손실 검증

  **What to do**:

  분할된 두 파일의 내용이 원본과 동일한지 검증:

  1. SKILL.md에서 frontmatter를 제거한 본문 추출
  2. references/case-study-template.md에서 TOC 헤더를 제거한 본문 추출
  3. 두 본문을 합친 것과 원본 `.claude/commands/write-post.md`를 비교
  4. 차이점이 있다면 의도된 변경(frontmatter 추가, 사용법 섹션 제거, 4단계 references 참조 변경)만인지 확인

  **검증 명령어**:
  ```bash
  # 원본과 신규 파일의 주요 섹션 존재 여부 확인
  grep -c "환경 감지\|Phase 1\|Phase 2\|Phase 3\|게시글 템플릿\|작성 시 주의사항\|마무리 안내" .claude/skills/write-post/SKILL.md .claude/skills/write-post/references/case-study-template.md

  # SKILL.md 줄 수 확인 (300줄 이하)
  wc -l .claude/skills/write-post/SKILL.md

  # 원본의 핵심 키워드가 누락되지 않았는지 확인
  for keyword in "환경 감지" "Claude Code" "OpenCode" "Codex CLI" "Gemini CLI" "Antigravity" "DEVLOG" "게시글 템플릿" "이미지 추천"; do
    grep -l "$keyword" .claude/skills/write-post/SKILL.md .claude/skills/write-post/references/case-study-template.md
  done
  ```

  **Must NOT do**:
  - 검증 실패 시 내용 수정 (Task 1 수정 요청으로 돌아가기)

  **Parallelizable**: NO (Task 1 완료 후)

  **References**:
  - `.claude/commands/write-post.md` - 원본 (비교 대상)
  - `.claude/skills/write-post/SKILL.md` - 분할 결과물 1
  - `.claude/skills/write-post/references/case-study-template.md` - 분할 결과물 2

  **Acceptance Criteria**:
  - [ ] 원본의 모든 핵심 키워드가 분할 파일 중 하나에 존재
  - [ ] SKILL.md가 300줄 이하
  - [ ] 의도된 변경(frontmatter 추가, 사용법 제거, 4단계 수정)만 차이로 확인됨
  - [ ] Phase 1의 5개 도구 세션 파싱 지침이 모두 SKILL.md에 존재
  - [ ] Phase 3의 8개 질문 항목이 모두 SKILL.md에 존재

  **Commit**: YES (Task 1과 함께)
  - Message: `refactor(skill): restructure write-post as skill directory with Progressive Disclosure`
  - Files: `.claude/skills/write-post/SKILL.md`, `.claude/skills/write-post/references/case-study-template.md`

---

- [x] 3. 이전 경로 리다이렉트 stub 생성

  **What to do**:

  기존 `.claude/commands/write-post.md` 파일을 리다이렉트 안내로 교체:

  ```markdown
  # ⚠️ write-post 스킬이 이동했습니다

  이 파일은 더 이상 사용되지 않습니다. 새로운 위치에서 스킬을 사용해주세요.

  ## 새 위치
  `.claude/skills/write-post/SKILL.md`

  ## 마이그레이션
  1. 이 파일 삭제
  2. 설치 스크립트를 다시 실행하여 새 버전 설치

  ```bash
  # Mac/Linux
  curl -fsSL https://raw.githubusercontent.com/daht-mad/write-post/main/install_mac.sh | bash

  # Windows PowerShell
  iwr -useb https://raw.githubusercontent.com/daht-mad/write-post/main/install_win.ps1 | iex
  ```
  ```

  **Must NOT do**:
  - 기존 파일 완전 삭제 (이전 설치 사용자가 404 에러를 받게 됨)

  **Parallelizable**: NO (Task 1 완료 후)

  **References**:
  - `.claude/commands/write-post.md` - 현재 파일 (덮어쓸 대상)

  **Acceptance Criteria**:
  - [ ] `.claude/commands/write-post.md`가 리다이렉트 안내로 교체됨
  - [ ] 새 위치 경로가 정확히 명시됨
  - [ ] 재설치 명령어가 포함됨

  **Commit**: YES (Task 2 커밋에 포함)
  - Message: Task 2 커밋에 포함
  - Files: `.claude/commands/write-post.md`

---

- [x] 4. install_mac.sh 업데이트

  **What to do**:

  설치 스크립트를 디렉토리 구조 다운로드로 변경:

  **변경 사항**:

  1. **다운로드 소스 URL 변경**:
     - 기존: `$REPO_URL/.claude/commands/write-post.md`
     - 신규: `$REPO_URL/.claude/skills/write-post/SKILL.md` + `$REPO_URL/.claude/skills/write-post/references/case-study-template.md`

  2. **Claude Code 설치 경로 변경**:
     - 전역: `~/.claude/commands/` → `~/.claude/skills/write-post/`
     - 프로젝트: `.claude/commands/` → `.claude/skills/write-post/`

  3. **모든 도구 통합 로직**:
     - 모든 도구가 동일한 SKILL.md 사용 (frontmatter 이미 포함)
     - `sed` 기반 frontmatter 주입 로직 제거
     - 파일명 통일: 모든 도구에서 `SKILL.md`

  4. **references/ 디렉토리 생성**:
     - `mkdir -p "$TARGET_DIR/references"`
     - `case-study-template.md` 다운로드

  5. **이전 설치 cleanup 로직 추가**:
     - Claude Code: `~/.claude/commands/write-post.md` 삭제 (전역)
     - Claude Code: `.claude/commands/write-post.md` 삭제 (프로젝트)

  6. **에러 처리**:
     - SKILL.md 다운로드 실패 시 전체 설치 중단
     - references/ 다운로드 실패 시 경고 표시 후 계속 진행 (Phase 1/2는 작동 가능)

  **도구별 설치 경로** (업데이트):

  | 도구 | 전역 | 프로젝트 |
  |------|------|---------|
  | Claude Code | `~/.claude/skills/write-post/` | `.claude/skills/write-post/` |
  | OpenCode | `~/.config/opencode/skills/write-post/` | `.opencode/skills/write-post/` |
  | Codex CLI | `~/.codex/skills/write-post/` | `.codex/skills/write-post/` |
  | Gemini CLI | `~/.gemini/skills/write-post/` | `.gemini/skills/write-post/` |
  | Antigravity | `~/.gemini/antigravity/skills/write-post/` | `.agent/skills/write-post/` |

  **Must NOT do**:
  - 설치 스크립트 전체 구조 리팩토링
  - `curl | bash` 패턴 깨뜨리기
  - 새로운 bash 기능 추가 (호환성)

  **Parallelizable**: YES (Task 5와 병렬)

  **References**:
  - `install_mac.sh` - 현재 스크립트 (141줄)

  **Acceptance Criteria**:
  - [ ] 모든 도구에서 SKILL.md를 직접 다운로드 (frontmatter 주입 없음)
  - [ ] references/case-study-template.md가 함께 다운로드됨
  - [ ] Claude Code 경로가 `skills/write-post/`로 변경됨
  - [ ] 이전 `commands/write-post.md` 정리 로직 포함
  - [ ] `bash -n install_mac.sh` 문법 검증 통과
  - [ ] 설치 완료 메시지에 새 경로 표시

  **Commit**: YES
  - Message: `feat(install): update installation for skill directory structure`
  - Files: `install_mac.sh`

---

- [x] 5. install_win.ps1 업데이트

  **What to do**:

  Task 4와 동일한 변경을 PowerShell로 구현:

  **Windows 경로 매핑** (업데이트):

  | 도구 | 전역 | 프로젝트 |
  |------|------|---------|
  | Claude Code | `$env:USERPROFILE\.claude\skills\write-post\` | `.claude\skills\write-post\` |
  | OpenCode | `$env:USERPROFILE\.config\opencode\skills\write-post\` | `.opencode\skills\write-post\` |
  | Codex CLI | `$env:USERPROFILE\.codex\skills\write-post\` | `.codex\skills\write-post\` |
  | Gemini CLI | `$env:USERPROFILE\.gemini\skills\write-post\` | `.gemini\skills\write-post\` |
  | Antigravity | `$env:USERPROFILE\.gemini\antigravity\skills\write-post\` | `.agent\skills\write-post\` |

  **핵심 변경**:
  - `Invoke-WebRequest`로 2개 파일 다운로드
  - frontmatter 주입 string concat 로직 제거 (SKILL.md에 이미 포함)
  - `New-Item -ItemType Directory` 로 `references\` 생성
  - 이전 경로 cleanup: `Remove-Item` 으로 이전 파일 삭제
  - `Join-Path` 사용 (경로 구분자 안전)

  **Must NOT do**:
  - `iwr | iex` 패턴 깨뜨리기
  - Unix 경로 사용

  **Parallelizable**: YES (Task 4와 병렬)

  **References**:
  - `install_win.ps1` - 현재 스크립트 (129줄)

  **Acceptance Criteria**:
  - [ ] Task 4와 동일한 기능이 PowerShell로 구현됨
  - [ ] Windows 경로 (백슬래시) 올바르게 사용됨
  - [ ] frontmatter 주입 로직 제거됨
  - [ ] references\ 디렉토리 생성 및 파일 다운로드
  - [ ] 이전 설치 cleanup 로직 포함

  **Commit**: YES (Task 4 커밋에 포함)
  - Message: Task 4 커밋에 포함
  - Files: `install_win.ps1`

---

- [x] 6. README.md 업데이트

  **What to do**:

  README.md에서 경로 참조를 새 구조로 업데이트:

  - `.claude/commands/write-post.md` → `.claude/skills/write-post/SKILL.md`
  - 설치 후 안내에 "skills 디렉토리" 참조 반영
  - "설치 방법" 섹션에 디렉토리 구조 설명 추가

  **Must NOT do**:
  - README 섹션 재작성
  - 새 섹션 추가
  - 기존 예시/다이어그램 삭제

  **Parallelizable**: NO (Task 4, 5 완료 후)

  **References**:
  - `README.md` - 현재 README

  **Acceptance Criteria**:
  - [ ] `.claude/commands/` 경로 참조가 제거됨
  - [ ] 새 경로 `.claude/skills/write-post/` 반영됨
  - [ ] 기존 구조 유지

  **Commit**: YES
  - Message: `docs: update README paths for skill directory structure`
  - Files: `README.md`

---

- [x] 7. End-to-end 검증

  **What to do**:

  전체 변경사항의 정합성을 최종 검증:

  1. **파일 구조 확인**:
     ```bash
     ls -la .claude/skills/write-post/
     ls -la .claude/skills/write-post/references/
     ```

  2. **콘텐츠 검증**:
     ```bash
     # SKILL.md 줄 수 확인 (300줄 이하)
     wc -l .claude/skills/write-post/SKILL.md

     # frontmatter 확인
     head -5 .claude/skills/write-post/SKILL.md

     # 5개 도구 모두 포함 확인
     grep -c "Claude Code\|OpenCode\|Codex CLI\|Gemini CLI\|Antigravity" .claude/skills/write-post/SKILL.md
     ```

  3. **설치 스크립트 문법 검증**:
     ```bash
     bash -n install_mac.sh
     ```

  4. **리다이렉트 stub 확인**:
     ```bash
     head -3 .claude/commands/write-post.md
     ```

  5. **references/ 파일 확인**:
     ```bash
     grep -c "게시글 템플릿\|작성 시 주의사항\|마무리 안내" .claude/skills/write-post/references/case-study-template.md
     ```

  **Acceptance Criteria**:
  - [ ] 위 모든 검증 명령어가 기대값 반환
  - [ ] git status가 계획된 파일만 변경으로 표시
  - [ ] SKILL.md가 300줄 이하
  - [ ] references/case-study-template.md에 템플릿 전체 포함

  **Commit**: NO (검증만)

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 + 2 + 3 | `refactor(skill): restructure write-post as skill directory with Progressive Disclosure` | `.claude/skills/write-post/SKILL.md`, `references/case-study-template.md`, `.claude/commands/write-post.md` | 콘텐츠 diff 검증 |
| 4 + 5 | `feat(install): update installation for skill directory structure` | `install_mac.sh`, `install_win.ps1` | `bash -n` 문법 검증 |
| 6 | `docs: update README paths for skill directory structure` | `README.md` | 경로 참조 확인 |

---

## Success Criteria

### Verification Commands
```bash
# 스킬 디렉토리 구조 확인
ls -R .claude/skills/write-post/
# 예상: SKILL.md, references/case-study-template.md

# SKILL.md 줄 수 확인
wc -l .claude/skills/write-post/SKILL.md
# 예상: 300줄 이하

# frontmatter 확인
head -4 .claude/skills/write-post/SKILL.md
# 예상: ---\nname: write-post\ndescription: ...\n---

# 5개 도구 포함 확인
grep -c "Claude Code\|OpenCode\|Codex CLI\|Gemini CLI\|Antigravity" .claude/skills/write-post/SKILL.md
# 예상: 각 도구명 최소 2회

# 설치 스크립트 문법 검증
bash -n install_mac.sh
# 예상: 에러 없음

# 리다이렉트 stub 존재 확인
cat .claude/commands/write-post.md | head -1
# 예상: "# ⚠️ write-post 스킬이 이동했습니다"
```

### Final Checklist
- [x] 모든 "Must Have" 항목 충족
- [x] 모든 "Must NOT Have" 가드레일 준수
- [x] `/write-post` 커맨드가 동일하게 동작
- [x] Progressive Disclosure 적용 (SKILL.md <300줄)
- [x] 이전 사용자 호환성 유지 (리다이렉트 stub)
- [x] 한국어 스타일 일관성 유지
