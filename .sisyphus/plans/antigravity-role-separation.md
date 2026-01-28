# Antigravity DEVLOG 에이전트 답변 덤프 문제 수정

## TL;DR

> **Quick Summary**: Antigravity 환경에서 write-post 스킬 실행 시 DEVLOG에 AI 응답 전체가 그대로 출력되는 문제를 수정합니다. 원인은 1차 방법(내부 검색)에 역할(role) 분리 지침이 없어서, 검색 결과의 사용자 요청과 AI 응답을 구분하지 못하는 것입니다.
> 
> **Deliverables**:
> - `SKILL.md` lines 162-174 (Antigravity 파싱 가이드) 내 역할 분리 + 필터링 지침 추가
> - (선택) line 183 Antigravity 필터링 규칙에 1차 방법용 규칙 1줄 추가
> 
> **Estimated Effort**: Quick
> **Parallel Execution**: NO - sequential (단일 파일 편집)
> **Critical Path**: Task 1 → Task 2 (선택) → Task 3 (검증)

---

## Context

### Original Request
Antigravity 환경에서 write-post 스킬 실행 시 DEVLOG에 에이전트 답변 전체가 그대로 출력되는 문제 수정. SKILL.md의 Antigravity 섹션(lines 162-174)에 역할 분리 + 필터링 지침을 인라인으로 추가.

### Interview Summary
**Problem Root Cause**:
- 다른 도구들(Claude Code, OpenCode, Codex CLI, Gemini CLI)은 모두 명시적 역할 구분 방법이 있음 (`type: 'user'`/`type: 'assistant'`, `role` 필드, `role: user/model`)
- Antigravity 1차 방법은 "과거 대화를 검색해줘"라고만 되어있어, 검색 결과에서 사용자 요청과 AI 응답을 분리하는 방법이 전혀 없음
- 2차 방법의 `brain/` 아티팩트는 전부 AI 생성 요약문서라 사용자 요청 추출 자체가 불가능
- 결과적으로 DEVLOG에 에이전트 답변 전체가 쏟아져 나옴

**Research Findings**:
- Antigravity `.pb` 파일: 암호화되어 외부에서 읽기 불가, 하지만 에이전트 내부에서는 접근 가능
- `brain/` 아티팩트 (`walkthrough.md`, `implementation_plan.md`, `task.md`): 전부 AI 생성 요약 — 역할 마커 없음, 원문 사용자 요청 없음
- `task.md`: 사용자 의도에 가장 가까운 파일이지만, AI가 도출한 체크리스트이지 원문 요청이 아님
- `.metadata.json`: `artifactType`, `summary`, `updatedAt` 필드만 — 작성자/역할 정보 없음
- Antigravity 에이전트는 내부적으로 복호화된 대화 데이터에 접근 가능하며, 특정 형식으로 반환하도록 지시할 수 있음

### Metis Review
**Identified Gaps** (addressed):

1. **Line 166 `brain/` 보조 자료 모호성** → 계획에 명시적 약화 지침 포함 ("보조 참고용이며, DEVLOG의 사용자 요청 원문 소스로 사용하지 않음"으로 변경)
2. **1차 방법 전용 필터링 규칙 부재** → line 183에 1차 방법용 필터링 규칙 1줄 추가 포함 (선택적 — 기술적으로 lines 162-174 범위 밖이지만 단일 불릿 추가로 최소 변경)
3. **역할 구분 불명확 시 폴백 전략 누락** → "질문/요청 형태의 문장만 사용자 요청으로 추출" 폴백 지침 포함
4. **에이전트 발화 질문 처리** → 에이전트가 묻는 질문은 사용자 요청이 아님을 명시
5. **도구 실행 출력 혼입** → 도구 호출 결과/실행 로그 제외 지침 포함
6. **날짜 정보 추출** → 내부 검색 시 날짜 정보도 함께 요청하도록 지침 포함

---

## Work Objectives

### Core Objective
Antigravity 1차 방법(내부 검색)에 역할 분리 + 필터링 지침을 추가하여, DEVLOG 생성 시 사용자 요청만 코드블록으로, AI 작업만 불릿 포인트로 올바르게 분리되도록 합니다.

### Concrete Deliverables
- `SKILL.md` Antigravity 1차 방법 (lines 163-167): 역할 분리 지침 ~10줄 추가
- `SKILL.md` line 166: `brain/` 보조 자료 역할 명확화 (약화)
- (선택) `SKILL.md` line 183: Antigravity 1차 방법 전용 필터링 규칙 1줄 추가

### Definition of Done
- [x] SKILL.md Antigravity 1차 방법에 다른 도구들과 동등한 수준의 역할 분리 지침이 있음
- [x] 검색 결과에서 사용자 요청/AI 응답을 분리하는 구체적 방법이 명시되어 있음
- [x] 총 줄 수 ≤ 500줄

### Must Have
- 1차 방법에 역할 분리 지침 (사용자 요청 → 코드블록, AI 작업 → 불릿 포인트 정리)
- 검색 시 "사용자가 보낸 메시지만 따로 추출해줘" 형태의 프롬프트 지침
- 역할 구분 불명확 시 폴백 전략 (질문/요청 형태 문장만 추출)
- `brain/` 보조 자료가 DEVLOG 원문 소스가 아님을 명확화
- AI 응답 전문, 도구 실행 출력, 에이전트 발화 질문 제외 지침

### Must NOT Have (Guardrails)
- Phase 1/2/3 워크플로우 로직 변경
- 다른 도구(Claude Code, OpenCode, Codex CLI, Gemini CLI)의 파싱 가이드 변경
- Antigravity 2차 방법(lines 168-174) 변경
- 새로운 하위 헤딩 추가 또는 섹션 구조 변경
- Windows 참고 블록 추가
- 추가 검색 프롬프트 예시 (기존 line 165의 예시로 충분)
- SKILL.md 총 500줄 초과

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: NO (마크다운 문서 편집)
- **User wants tests**: Manual-only
- **Framework**: none

### Manual QA Procedure

검증은 아래 순서로 진행:

1. **줄 수 확인**: `wc -l SKILL.md` → 500 이하
2. **변경 범위 확인**: `git diff SKILL.md` → 변경이 Antigravity 섹션(162-174 근처)과 선택적으로 line 183 근처에만 있는지 확인
3. **역할 분리 지침 존재 확인**: 수정된 Antigravity 1차 방법에 "사용자 요청"과 "AI 응답"을 구분하는 명시적 지침이 있는지 육안 검증
4. **패턴 일관성 확인**: Claude Code(line 123) `type: 'user'` → 사용자 요청 패턴과 유사한 명령형 매핑 스타일인지 확인
5. **다른 섹션 무변경 확인**: lines 1-161, 175-182 (또는 184-468)이 변경되지 않았는지 diff로 확인

---

## Execution Strategy

### Sequential Execution

```
Task 1: Antigravity 1차 방법 역할 분리 지침 추가 (lines 163-167)
    ↓
Task 2 (선택): 정리 규칙 필터링 항목 추가 (line 183)
    ↓  
Task 3: 검증
```

### Agent Dispatch Summary

| Order | Task | Recommended Agent |
|-------|------|-------------------|
| 1 | 1차 방법 역할 분리 지침 추가 | delegate_task(category="quick", load_skills=["write-post"]) |
| 2 | 정리 규칙 필터링 추가 (선택) | 같은 세션에서 연속 처리 |
| 3 | 검증 | 같은 세션에서 연속 처리 |

---

## TODOs

- [x] 1. Antigravity 1차 방법에 역할 분리 + 필터링 지침 추가

  **What to do**:
  
  `SKILL.md` lines 163-167 (Antigravity 1차 방법)을 편집하여 다음 내용을 인라인 불릿으로 추가:

  **a) 검색 시 역할 분리 지시 (핵심)**:
  - 기존 line 165 ("이 프로젝트에서 진행한 과거 대화들을 검색해줘" 등)에 이어서, 검색 결과에서 역할을 분리하는 지침 추가
  - 핵심 지시: "검색 결과에서 **사용자가 보낸 메시지**(요청, 질문, 지시)와 **에이전트 응답**(작업 내용, 설명, 코드)을 명확히 분리해서 반환"
  - 사용자 메시지 → DEVLOG의 코드블록 (원문 그대로)
  - 에이전트 응답 → 핵심 작업 내용만 요약하여 불릿 포인트로 정리 (전문 출력 금지)

  **b) 폴백 전략**:
  - 역할 구분이 불명확한 경우: 질문/요청/지시 형태의 문장만 사용자 요청으로 추출
  - 에이전트가 묻는 확인 질문 ("이 파일도 수정할까요?" 등)은 사용자 요청이 아님 — 제외

  **c) 제외 대상 명시**:
  - AI 응답 전문 (verbatim agent response)
  - 도구 호출 결과 및 실행 로그
  - 에이전트 발화 질문 (에이전트 → 사용자 방향)

  **d) line 166 `brain/` 보조 자료 역할 약화**:
  - 현재: "brain/ 폴더의 마크다운 아티팩트도 보조 자료로 함께 활용"
  - 변경: "brain/ 폴더의 마크다운 아티팩트는 작업 맥락 파악용 참고자료로만 활용 (AI 생성 요약이므로 DEVLOG의 사용자 요청 원문 소스로는 사용하지 않음)"

  **e) 날짜 정보 요청**:
  - 내부 검색 시 각 대화의 날짜 정보도 함께 추출하도록 지시 (DEVLOG의 Day N 그룹핑에 필요)

  **Must NOT do**:
  - 2차 방법(lines 168-174) 변경 금지
  - 새 하위 헤딩(`####`, `#####`) 추가 금지
  - 기존 line 165의 검색 프롬프트 예시 변경 금지
  - 추가 예시 프롬프트 추가 금지 (필터링/추출 지침만 추가)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 단일 파일의 특정 섹션에 ~10줄 인라인 추가하는 작업
  - **Skills**: [`write-post`]
    - `write-post`: SKILL.md의 구조와 다른 도구 파싱 가이드의 패턴을 이해하기 위해 필요

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: Task 2, Task 3
  - **Blocked By**: None

  **References**:

  **Pattern References** (기존 도구의 역할 분리 패턴 — 이 스타일을 따를 것):
  - `.claude/skills/write-post/SKILL.md:123` — Claude Code: `type: 'user'` → 사용자 요청, `type: 'assistant'` → Claude 응답 (명령형 매핑 패턴)
  - `.claude/skills/write-post/SKILL.md:134` — OpenCode: `role, content 포함` (명시적 role 필드)
  - `.claude/skills/write-post/SKILL.md:157` — Gemini CLI: `role: user/model, parts: content` (역할 마커)

  **수정 대상**:
  - `.claude/skills/write-post/SKILL.md:162-174` — Antigravity 섹션 전체 (1차 방법: 163-167이 핵심 편집 대상)

  **참고 컨텍스트**:
  - `.claude/skills/write-post/SKILL.md:176-205` — 정리 규칙 (DEVLOG에서 사용자 요청 = 코드블록, AI 작업 = 불릿 포인트 원칙 확인)
  - `.claude/skills/write-post/SKILL.md:48-103` — 출력 포맷 (DEVLOG 최종 형식 확인)
  - `.claude/skills/write-post/SKILL.md:192` — "사용자 요청은 **코드블록**으로, AI 작업은 **bullet point**로" (핵심 원칙)

  **Acceptance Criteria**:
  - [ ] Antigravity 1차 방법에 "사용자 메시지"와 "에이전트 응답"을 분리하는 명시적 지침이 있음
  - [ ] 사용자 메시지 → 코드블록, 에이전트 작업 → 요약 불릿 포인트 매핑이 명시됨
  - [ ] 역할 구분 불명확 시 폴백 전략이 있음
  - [ ] AI 응답 전문/도구 실행 로그/에이전트 발화 질문 제외가 명시됨
  - [ ] `brain/` 보조 자료가 "참고자료로만" 약화됨
  - [ ] 날짜 정보 추출 지시가 포함됨
  - [ ] 2차 방법(lines 168-174) 변경 없음
  - [ ] 추가된 줄 수 ≤ 15줄

  **Manual Execution Verification:**
  - [ ] `wc -l .claude/skills/write-post/SKILL.md` → 500 이하
  - [ ] `git diff .claude/skills/write-post/SKILL.md` → 변경이 Antigravity 1차 방법 영역에만 있는지 확인
  - [ ] 수정된 섹션을 읽어서 다른 도구(Claude Code line 123, Gemini CLI line 157)와 동등한 수준의 역할 분리 지침인지 육안 확인

  **Commit**: YES
  - Message: `fix(skill): Antigravity 파싱 가이드에 역할 분리 및 필터링 지침 추가`
  - Files: `.claude/skills/write-post/SKILL.md`
  - Pre-commit: `wc -l .claude/skills/write-post/SKILL.md` (500줄 이하 확인)

---

- [x] 2. (선택) 정리 규칙에 Antigravity 1차 방법 필터링 항목 추가

  **What to do**:
  
  `SKILL.md` line 183 근처의 Antigravity 필터링 규칙을 확장:
  
  - 현재 (line 183): `Antigravity: .metadata.json, .resolved 파일 자체는 제외 (본문만 파싱)`
  - 추가: `Antigravity (1차 방법): AI 응답 전문 제외 — 에이전트 작업 내용은 핵심만 요약하여 불릿 포인트로 정리`

  이 항목은 기술적으로 "lines 162-174" 범위 밖이지만:
  - 변경량은 1줄 추가에 불과
  - Task 1의 역할 분리 지침과 논리적으로 연결되는 필터링 규칙
  - 기존 Antigravity 필터링 규칙 바로 옆에 추가되므로 자연스러움

  **Must NOT do**:
  - 다른 도구의 필터링 규칙 변경 금지
  - 필터링 섹션 구조 변경 금지

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`write-post`]

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential (Task 1과 동일 세션에서 연속 처리)
  - **Blocks**: Task 3
  - **Blocked By**: Task 1

  **References**:
  - `.claude/skills/write-post/SKILL.md:178-184` — 정리 규칙 > 공통 필터링 섹션 (기존 Antigravity 필터링 규칙 위치)

  **Acceptance Criteria**:
  - [ ] line 183 근처에 Antigravity 1차 방법 전용 필터링 규칙 1줄 추가됨
  - [ ] 다른 도구의 필터링 규칙 변경 없음
  - [ ] 추가된 줄 수: 1줄

  **Commit**: Task 1과 같은 커밋에 포함
  - Message: `fix(skill): Antigravity 파싱 가이드에 역할 분리 및 필터링 지침 추가`
  - Files: `.claude/skills/write-post/SKILL.md`

---

- [x] 3. 최종 검증

  **What to do**:
  
  편집 완료 후 아래 검증을 순서대로 실행:

  1. **줄 수 확인**: `wc -l .claude/skills/write-post/SKILL.md` → 500 이하
  2. **변경 범위 확인**: `git diff .claude/skills/write-post/SKILL.md` 실행하여:
     - 변경이 Antigravity 1차 방법 영역 (lines 162-174 근처)에 집중되어 있는지
     - (선택) line 183 근처에 1줄 추가만 있는지
     - 그 외 영역(1-161, 2차 방법 168-174, 175-182, 185-468)은 변경 없는지
  3. **역할 분리 품질 확인**: 수정된 Antigravity 섹션을 읽어서:
     - 다른 도구(Claude Code L123, Gemini CLI L157)와 동등한 수준의 역할 분리 지침인지
     - 명령형 매핑 스타일 (`X → 사용자 요청, Y → AI 응답`)을 따르는지
     - 폴백 전략이 있는지
     - 제외 대상이 명시되어 있는지
  4. **brain/ 약화 확인**: line 166이 "참고자료로만" 또는 동등한 표현으로 약화되었는지

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`write-post`]

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Blocked By**: Task 1 (필수), Task 2 (선택)

  **Acceptance Criteria**:
  - [ ] 모든 검증 항목 통과
  - [ ] `wc -l` 결과 500 이하
  - [ ] `git diff` 결과 변경 범위가 Antigravity 섹션 + 선택적 line 183에만 한정

  **Commit**: NO (검증만 수행)

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 (+2) | `fix(skill): Antigravity 파싱 가이드에 역할 분리 및 필터링 지침 추가` | `.claude/skills/write-post/SKILL.md` | `wc -l` ≤ 500, `git diff` 범위 확인 |

---

## Success Criteria

### Verification Commands
```bash
wc -l .claude/skills/write-post/SKILL.md  # Expected: ≤ 500
git diff .claude/skills/write-post/SKILL.md  # Expected: changes only in Antigravity section (~L162-174) and optionally ~L183
```

### Final Checklist
- [x] Antigravity 1차 방법에 역할 분리 지침 존재 (다른 도구와 동등 수준)
- [x] 사용자 요청 → 코드블록, AI 작업 → 불릿 포인트 매핑 명시
- [x] 폴백 전략 (역할 불명확 시) 명시
- [x] AI 응답 전문/도구 로그/에이전트 질문 제외 명시
- [x] `brain/` 보조 자료 역할 약화
- [x] 날짜 정보 추출 지시 포함
- [x] 2차 방법, Phase 1/2/3 워크플로우, 다른 도구 파싱 가이드 무변경
- [x] 총 줄 수 ≤ 500
