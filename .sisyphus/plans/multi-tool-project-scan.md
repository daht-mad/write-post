# write-post 프로젝트 단위 멀티 도구 세션 수집

## Context

### Original Request
하나의 프로젝트를 여러 AI 코딩 도구(Claude Code, OpenCode, Codex CLI 등)로 작업한 경우, 모든 도구의 세션을 프로젝트 단위로 수집하여 통합 DEVLOG를 생성하도록 write-post 스킬 업데이트.

### Interview Summary
**Key Discussions**:
- 현재 "단일 도구 감지" 방식의 한계: 첫 매칭 도구만 파싱, 나머지 도구의 세션 누락
- 수집 방식: 자동 전체 스캔 (모든 도구의 세션 경로를 자동으로 스캔)
- DEVLOG 헤더: "AI 코딩 도구와 함께 진행한 개발 작업 기록입니다" (도구 중립적)
- 섹션별 도구 표시: `**Claude Code 작업:**`, `**OpenCode 작업:**` 등 실제 도구명
- 미설치 도구: best-effort 구현 (문서 기반 추정)
- 이어쓰기: 날짜 기준 필터링 (마지막 날짜 이후 세션을 모든 도구에서 수집)

**Research Findings**:
- Claude Code: `~/.claude/projects/{경로-인코딩}/` 디렉토리명 또는 `history.jsonl`의 `project` 필드 → 매칭 쉬움
- OpenCode: `ses_*.json`의 `directory` 필드 또는 MCP `session_list` → 매칭 쉬움
- Antigravity: `code_tracker/active/{프로젝트명}_{해시}/` 또는 `brain/*/task.md.resolved`의 `file:///` 링크 → 가능하지만 복잡
- Codex CLI: 미설치. JSONL에 cwd 필드 있을 가능성 → best-effort
- Gemini CLI: `~/.gemini/tmp/` 비어있음. 해시↔경로 매핑 불명 → best-effort
- 타임스탬프 형식 차이: Claude Code(ISO 8601), OpenCode(Epoch ms), Antigravity(아티팩트 레벨)

### Metis Review
**Identified Gaps** (addressed):
- 타임스탬프 형식 차이 → 날짜(YYYY-MM-DD) 단위 그룹핑으로 통일 (시간 순서는 도구 내에서만)
- Antigravity는 메시지 단위가 아닌 아티팩트 단위 → 아티팩트를 하나의 작업 블록으로 처리
- 도구 세션이 하나도 발견되지 않는 경우 → "세션을 찾을 수 없습니다" 안내 후 종료
- 같은 날짜에 여러 도구 사용 시 정렬 → 도구별로 그룹핑 (날짜 > 도구 순)
- Phase 3 질문의 "Claude와 협업하면서" 하드코딩 → "AI와 협업하면서"로 변경
- 사례글 템플릿 "도구명" 필드 → 여러 도구 나열 가능하도록 변경

---

## Work Objectives

### Core Objective
write-post 스킬의 Phase 1을 "단일 도구 감지" 방식에서 "프로젝트 단위 멀티 도구 스캔" 방식으로 전환하여, 여러 도구로 작업한 프로젝트의 세션을 통합 DEVLOG로 생성한다.

### Concrete Deliverables
- `.claude/skills/write-post/SKILL.md` - Phase 1 멀티 도구 스캔으로 업데이트
- `.claude/skills/write-post/references/case-study-template.md` - 도구명 필드 업데이트

### Definition of Done
- [x] "환경 감지" 섹션이 "프로젝트 세션 스캔"으로 전환됨
- [x] 모든 도구의 세션 경로를 스캔하는 지침이 포함됨
- [x] 각 도구별 프로젝트 매칭 방법이 명시됨
- [x] DEVLOG 출력 포맷에서 `{도구명}`이 섹션별로 동적 표시됨
- [x] 이어쓰기 시 모든 도구에서 날짜 기준 필터링 적용됨
- [x] 사례글 템플릿의 도구명 필드가 복수 도구 지원

### Must Have
- 프로젝트 세션 스캔 지침 (감지 → 스캔으로 전환)
- 도구별 프로젝트 매칭 방법 (5개 도구 각각)
- DEVLOG 출력 포맷의 섹션별 도구명 표시
- 이어쓰기 시 멀티 도구 날짜 필터링
- 세션이 0개인 경우의 안내 메시지

### Must NOT Have (Guardrails)
- Phase 2 로직 변경 (DEVLOG 확인 프로세스는 동결)
- Phase 3 로직 변경 (질문 순서, 제목 선정 등은 동결 — "Claude" 하드코딩 수정만)
- 설치 스크립트 변경
- 디렉토리 구조 변경
- DEVLOG 출력 포맷의 구조적 변경 (날짜별 그룹핑, 커밋 히스토리 등은 유지)
- 정리 규칙 (lines 131-158) 변경 (기존 필터링 규칙은 유지)
- SKILL.md를 300줄 초과하게 만들기

---

## Verification Strategy (MANDATORY)

### Test Decision
- **Infrastructure exists**: NO (마크다운 스킬 파일)
- **User wants tests**: Manual-only
- **Framework**: 없음

### Manual QA
- SKILL.md 줄 수 확인 (300줄 이하)
- 변경된 섹션의 키워드 존재 여부 확인
- Phase 2/3 내용이 변경되지 않았는지 확인 (하드코딩 수정 제외)

---

## Task Flow

```
Task 1 (Phase 1 멀티 도구 스캔으로 재작성)
    ↓
Task 2 (Phase 3 "Claude" 하드코딩 수정)
    ↓
Task 3 (references 템플릿 도구명 필드 업데이트)
    ↓
Task 4 (콘텐츠 검증 + 커밋)
```

## Parallelization

| Task | Depends On | Reason |
|------|------------|--------|
| 2 | 1 | Phase 1 변경 확정 후 Phase 3 최소 수정 |
| 3 | 1 | SKILL.md 변경 확정 후 references 수정 |
| 4 | ALL | 최종 검증 |

---

## TODOs

- [x] 1. SKILL.md Phase 1 멀티 도구 프로젝트 스캔으로 재작성

  **What to do**:

  SKILL.md의 Phase 1 관련 섹션들을 "단일 도구 감지"에서 "프로젝트 단위 멀티 도구 스캔"으로 업데이트:

  ### 1-1. "환경 감지" → "프로젝트 세션 스캔" 전환 (lines 14-25)

  **현재** (lines 14-25):
  ```
  현재 도구 환경을 감지하고 대화 내역을 기반으로 개발 로그 문서를 자동 생성합니다.

  ## 환경 감지 (Environment Detection)
  스킬 실행 시 아래 순서로 현재 도구 환경을 판별합니다:
  1. OpenCode: ...
  2. Claude Code: ...
  (첫 매칭에서 멈추는 우선순위 방식)
  ```

  **변경 후**:
  ```markdown
  사용 가능한 모든 AI 코딩 도구의 세션을 프로젝트 단위로 스캔하고, 통합 개발 로그 문서를 자동 생성합니다.

  ## 프로젝트 세션 스캔 (Project Session Scan)

  스킬 실행 시 아래 **모든** 도구의 세션 경로를 스캔하여 현재 프로젝트와 매칭되는 세션을 수집합니다:

  1. **Claude Code**: `~/.claude/projects/` 에서 현재 프로젝트 경로와 매칭되는 폴더 탐색
  2. **OpenCode**: MCP `session_list` 또는 `~/.local/share/opencode/storage/`에서 `directory` 필드로 매칭
  3. **Antigravity**: `~/.gemini/antigravity/brain/`에서 아티팩트 내 프로젝트 경로 매칭
  4. **Codex CLI**: `~/.codex/sessions/`에서 세션 파일 내 작업 디렉토리 매칭
  5. **Gemini CLI**: `~/.gemini/tmp/`에서 프로젝트 해시 매칭

  **스캔 결과 처리:**
  - 매칭되는 세션이 있는 도구들의 목록을 사용자에게 보여주기: "다음 도구에서 세션을 찾았습니다: Claude Code (3개 세션), OpenCode (2개 세션)"
  - 매칭되는 세션이 하나도 없으면: "현재 프로젝트와 매칭되는 세션을 찾을 수 없습니다. 프로젝트 경로를 확인해주세요."
  - 특정 도구의 세션 경로가 존재하지 않으면 해당 도구는 건너뜀 (에러 표시 X)
  ```

  ### 1-2. 출력 포맷 업데이트 (lines 27-82)

  **변경 대상 (3곳)**:
  - line 32: `{도구명}와 함께 진행한 개발 작업 기록입니다.`
    → `AI 코딩 도구와 함께 진행한 개발 작업 기록입니다.`
  - line 44: `**{도구명} 작업:**`
    → `**{해당 작업의 도구명} 작업:**` (예: **Claude Code 작업:**, **OpenCode 작업:**)
  - line 57: 동일하게 `**{해당 작업의 도구명} 작업:**`

  **추가 설명 (출력 포맷 섹션 직후에 삽입)**:
  ```markdown
  > **멀티 도구 참고**: 여러 도구의 세션이 수집된 경우, 각 작업 섹션의 `**{도구명} 작업:**` 헤더에 해당 작업을 수행한 실제 도구명이 표시됩니다. 같은 날짜에 여러 도구를 사용한 경우 도구별로 구분하여 기록합니다.
  ```

  ### 1-3. 실행 방법 업데이트 (lines 84-93)

  **현재** (line 89):
  ```
  2. 세션 파일에서 **그 이후 날짜의 대화 내역만** 파싱
  ```

  **변경 후**:
  ```
  2. **모든 감지된 도구의** 세션 파일에서 **그 이후 날짜의 대화 내역만** 파싱
  ```

  ### 1-4. 도구별 세션 파싱 가이드에 프로젝트 매칭 추가 (lines 94-129)

  각 도구 섹션에 `- **프로젝트 매칭**:` 항목 추가:

  **Claude Code** (line 96-99):
  ```
  - **프로젝트 매칭**: `~/.claude/projects/` 폴더에서 현재 프로젝트의 절대경로를 `-`로 치환한 폴더명 탐색. 예: `/Users/dahye/DEV/my-app` → `~/.claude/projects/-Users-dahye-DEV-my-app/`
  ```

  **OpenCode** (lines 101-110):
  ```
  - **프로젝트 매칭**: MCP `session_list` 사용 시 현재 프로젝트 세션 자동 필터링. Raw 파싱 시 `ses_*.json`의 `directory` 필드가 현재 프로젝트 경로와 일치하는지 확인.
  ```

  **Codex CLI** (lines 112-116):
  ```
  - **프로젝트 매칭** (best-effort): JSONL 파일 내 `cwd` 또는 `working_directory` 필드가 현재 프로젝트 경로와 일치하는지 확인. 해당 필드가 없으면 사용자에게 "이 세션이 현재 프로젝트의 것인가요?" 질문.
  ```

  **Gemini CLI** (lines 118-122):
  ```
  - **프로젝트 매칭** (best-effort): `~/.gemini/tmp/` 하위 해시 디렉토리들의 채팅 파일 내에서 현재 프로젝트 경로가 언급되는지 확인. 매칭이 불확실하면 사용자에게 확인 질문.
  ```

  **Antigravity** (lines 124-129):
  ```
  - **프로젝트 매칭**: `~/.gemini/antigravity/code_tracker/active/` 에서 현재 프로젝트명이 포함된 디렉토리 탐색. 또는 `brain/*/task.md.resolved` 파일 내 `file:///` 링크에서 현재 프로젝트 경로 매칭. 매칭된 conversation-id의 아티팩트만 파싱.
  ```

  ### 1-5. 구조화 규칙 업데이트 (lines 141-144)

  **현재** (line 141-144):
  ```
  2. **구조화**:
     - 날짜별로 그룹핑 (Day 1, Day 2...)
     - 관련 작업끼리 하나의 섹션으로 묶기
     - 사용자 요청은 **코드블록**으로, AI 작업은 **bullet point**로
  ```

  **변경 후**:
  ```
  2. **구조화**:
     - 날짜별로 그룹핑 (Day 1, Day 2...)
     - 여러 도구의 세션을 날짜순으로 병합
     - 같은 날짜에 여러 도구를 사용한 경우 도구별로 구분하여 기록
     - 각 작업 섹션의 `**{도구명} 작업:**` 헤더에 해당 도구의 실제 이름 표시
     - 관련 작업끼리 하나의 섹션으로 묶기
     - 사용자 요청은 **코드블록**으로, AI 작업은 **bullet point**로
  ```

  **Must NOT do**:
  - Phase 2/3 내용 변경 (Task 2에서 처리하는 최소 수정 제외)
  - 정리 규칙의 공통 필터링 (lines 133-139) 변경
  - 사용자 요청 정리 규칙 (lines 146-152) 변경
  - 출력 포맷의 구조적 변경 (날짜별 그룹핑, 커밋 히스토리, 기술 스택 등 유지)
  - SKILL.md를 300줄 초과하게 만들기

  **Parallelizable**: NO (다른 태스크의 기반)

  **References**:
  - `.claude/skills/write-post/SKILL.md:14-158` - 현재 Phase 1 전체 내용. 이 범위를 수정
  - `.claude/skills/write-post/SKILL.md:16-25` - 현재 환경 감지 섹션 (전면 재작성)
  - `.claude/skills/write-post/SKILL.md:27-82` - 현재 출력 포맷 (3곳 수정 + 설명 추가)
  - `.claude/skills/write-post/SKILL.md:84-93` - 현재 실행 방법 (1곳 수정)
  - `.claude/skills/write-post/SKILL.md:94-129` - 현재 도구별 파싱 가이드 (5곳에 프로젝트 매칭 추가)
  - `.claude/skills/write-post/SKILL.md:141-144` - 현재 구조화 규칙 (3줄 추가)
  - `~/.claude/projects/` - Claude Code 프로젝트 경로 인코딩 패턴 실제 확인
  - `~/.local/share/opencode/storage/session/` - OpenCode `directory` 필드 실제 확인
  - `~/.gemini/antigravity/code_tracker/active/` - Antigravity 프로젝트명 디렉토리 패턴 확인
  - `~/.gemini/antigravity/brain/8a17b84e-2e3f-479c-9a91-44aafae5fc61/task.md.resolved` - `file:///` 링크 패턴 확인

  **Acceptance Criteria**:
  - [ ] "환경 감지" 섹션이 "프로젝트 세션 스캔"으로 전면 교체됨
  - [ ] 5개 도구 모두의 세션 경로를 스캔하는 지침 포함
  - [ ] 각 도구별 프로젝트 매칭 방법이 파싱 가이드에 추가됨
  - [ ] DEVLOG 헤더가 "AI 코딩 도구와 함께..."로 변경됨
  - [ ] 작업 섹션 헤더가 `{해당 작업의 도구명}`으로 설명됨
  - [ ] 이어쓰기 시 "모든 감지된 도구의" 세션 파싱으로 변경됨
  - [ ] 구조화 규칙에 멀티 도구 병합 지침 추가됨
  - [ ] 세션 0개 시 안내 메시지 지침 포함
  - [ ] SKILL.md가 300줄 이하 유지
  - [ ] Phase 2/3 내용이 변경되지 않음

  **Commit**: NO (Task 4에서 일괄 커밋)

---

- [x] 2. Phase 3 "Claude" 하드코딩 최소 수정

  **What to do**:

  Phase 3 섹션에서 "Claude"가 하드코딩된 부분을 도구 중립적 표현으로 수정:

  - line 211: `Claude와 협업하면서 "오!" 했던 순간이 있나요?`
    → `AI와 협업하면서 "오!" 했던 순간이 있나요?`
  - line 212: `Claude가 잘 못 이해한 것`
    → `AI가 잘 못 이해한 것`

  **Must NOT do**:
  - Phase 3의 질문 순서, 로직, 템플릿 참조 변경
  - 2줄 초과 변경
  - Phase 2 변경

  **Parallelizable**: NO (Task 1 완료 후)

  **References**:
  - `.claude/skills/write-post/SKILL.md:211-212` - "Claude" 하드코딩 위치

  **Acceptance Criteria**:
  - [ ] "Claude와 협업하면서" → "AI와 협업하면서" 변경됨
  - [ ] "Claude가 잘 못 이해한 것" → "AI가 잘 못 이해한 것" 변경됨
  - [ ] Phase 3의 다른 내용은 전혀 변경되지 않음
  - [ ] 변경은 정확히 2줄

  **Commit**: NO (Task 4에서 일괄 커밋)

---

- [x] 3. references/case-study-template.md 도구명 필드 업데이트

  **What to do**:

  사례글 템플릿의 "사용한 도구" 섹션에서 도구명 필드를 복수 도구 지원으로 변경:

  **현재** (references/case-study-template.md, line 29):
  ```
  - **도구명**: (예: Claude Code)
  ```

  **변경 후**:
  ```
  - **도구명**: (예: Claude Code, OpenCode — 여러 도구 사용 시 모두 나열)
  ```

  **Must NOT do**:
  - 템플릿의 다른 부분 변경
  - 1줄 초과 변경

  **Parallelizable**: NO (Task 1 완료 후)

  **References**:
  - `.claude/skills/write-post/references/case-study-template.md:29` - 도구명 필드

  **Acceptance Criteria**:
  - [ ] 도구명 예시에 여러 도구 나열 + "여러 도구 사용 시 모두 나열" 안내 포함
  - [ ] 변경은 정확히 1줄

  **Commit**: NO (Task 4에서 일괄 커밋)

---

- [x] 4. 콘텐츠 검증 + 커밋

  **What to do**:

  전체 변경사항의 정합성을 검증하고 커밋:

  1. **SKILL.md 줄 수 확인**:
     ```bash
     wc -l .claude/skills/write-post/SKILL.md
     # 예상: 260-280줄 (300줄 이하)
     ```

  2. **핵심 키워드 확인**:
     ```bash
     grep -c "프로젝트 세션 스캔\|프로젝트 매칭\|모든 감지된 도구" .claude/skills/write-post/SKILL.md
     # 예상: 3 이상

     grep "AI 코딩 도구와 함께" .claude/skills/write-post/SKILL.md
     # 예상: 1줄

     grep "환경 감지" .claude/skills/write-post/SKILL.md
     # 예상: 0줄 (교체 완료)
     ```

  3. **Phase 2/3 동결 확인**:
     ```bash
     # Phase 2는 완전히 동결 (변경 0줄)
     # Phase 3는 "Claude" → "AI" 2줄만 변경
     ```

  4. **references 파일 확인**:
     ```bash
     grep "여러 도구 사용 시" .claude/skills/write-post/references/case-study-template.md
     # 예상: 1줄
     ```

  **Acceptance Criteria**:
  - [ ] SKILL.md가 300줄 이하
  - [ ] "환경 감지" 키워드가 0회 (교체 완료)
  - [ ] "프로젝트 세션 스캔" 키워드가 존재
  - [ ] Phase 2 내용 무변경
  - [ ] Phase 3는 2줄만 변경

  **Commit**: YES
  - Message: `feat(skill): add multi-tool project-level session scanning`
  - Files: `.claude/skills/write-post/SKILL.md`, `.claude/skills/write-post/references/case-study-template.md`

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 4 (all) | `feat(skill): add multi-tool project-level session scanning` | `SKILL.md`, `references/case-study-template.md` | 줄 수 + 키워드 확인 |

---

## Success Criteria

### Verification Commands
```bash
# SKILL.md 줄 수 확인
wc -l .claude/skills/write-post/SKILL.md
# 예상: 260-280줄 (300줄 이하)

# 프로젝트 세션 스캔 섹션 존재 확인
grep -c "프로젝트 세션 스캔" .claude/skills/write-post/SKILL.md
# 예상: 1 이상

# 환경 감지 섹션 제거 확인
grep -c "환경 감지" .claude/skills/write-post/SKILL.md
# 예상: 0

# 5개 도구 프로젝트 매칭 존재 확인
grep -c "프로젝트 매칭" .claude/skills/write-post/SKILL.md
# 예상: 5 (도구당 1개)

# DEVLOG 헤더 변경 확인
grep "AI 코딩 도구와 함께" .claude/skills/write-post/SKILL.md
# 예상: 1줄

# Phase 3 Claude 하드코딩 제거 확인
grep -c "Claude와 협업\|Claude가 잘" .claude/skills/write-post/SKILL.md
# 예상: 0

# references 도구명 필드 변경 확인
grep "여러 도구 사용 시" .claude/skills/write-post/references/case-study-template.md
# 예상: 1줄
```

### Final Checklist
- [x] 모든 "Must Have" 항목 충족
- [x] 모든 "Must NOT Have" 가드레일 준수
- [x] SKILL.md가 300줄 이하
- [x] 5개 도구의 프로젝트 매칭 지침 포함
- [x] Phase 2 완전 동결
- [x] Phase 3는 최소 수정만 (2줄)
- [x] 한국어 스타일 일관성 유지
