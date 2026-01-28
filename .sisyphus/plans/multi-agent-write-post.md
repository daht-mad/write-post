# write-post 스킬 멀티 에이전트 세션 지원

## Context

### Original Request
AI_CODING_TOOLS_FOLDER_STRUCTURE.md의 8번 섹션(대화 세션 저장 위치)을 기반으로, 현재 Claude Code만 지원하는 write-post 스킬을 5개 AI 코딩 도구 전체로 확장. 설치 스크립트도 멀티 도구 지원으로 업데이트.

### Interview Summary
**Key Discussions**:
- 지원 범위: Claude Code, OpenCode, Codex CLI, Gemini CLI, Antigravity (5개 전체)
- Antigravity: conversations/ 폴더는 암호화된 .pb → brain/ 마크다운 아티팩트 활용
- Phase 1(세션 파싱)만 업데이트, Phase 2/3은 동결
- 설치 스크립트도 멀티 도구 지원으로 업데이트
- 기존 스킬 업데이트 방식 (새 스킬 X)

**Research Findings**:
- **Claude Code**: `~/.claude/projects/<hash>/*.jsonl` - JSONL. `type: 'user'`/`type: 'assistant'` 파싱 (현재 구현됨)
- **OpenCode**: MCP 세션 도구(session_list, session_read, session_search) 제공. Raw: `~/.local/share/opencode/storage/` - session/message/part 3단계 JSON
- **Codex CLI**: `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl` - JSONL (검증 완료)
- **Gemini CLI**: `~/.gemini/tmp/<project_hash>/chats/` (자동 저장), `/chat save <tag>`로 수동 저장 - JSON (검증 완료)
- **Antigravity**: `~/.gemini/antigravity/brain/<conversation-id>/` - task.md, implementation_plan.md, walkthrough.md (마크다운). conversations/ .pb는 Google 암호화 키 필요하여 복호화 불가
- OpenCode는 `.claude/skills/`를 fallback으로 인식
- Antigravity brain/ 아티팩트에는 walkthrough.md가 없는 경우도 있음 (실제 확인됨)

### Metis Review
**Identified Gaps** (addressed):
- Phase 2/3에 "Claude" 하드코딩 이슈 → 최소한의 도구명 파라미터화 적용 (별도 태스크)
- Codex CLI/Gemini CLI 세션 형식 미검증 → 웹 검색으로 검증 완료
- 환경 감지 방법 불명확 → 자연어 지시사항으로 도구별 감지 조건 명시
- Antigravity 대화 식별 방법 → brain/ 폴더 목록에서 사용자 선택
- 단일 파일 vs 복수 파일 → 단일 원본(write-post.md) + 설치 시 frontmatter 추가

---

## Work Objectives

### Core Objective
write-post 스킬의 Phase 1을 5개 AI 코딩 도구의 세션 파싱을 지원하도록 업데이트하고, 설치 스크립트를 멀티 도구 배포로 확장한다.

### Concrete Deliverables
- `.claude/commands/write-post.md` - 멀티 에이전트 세션 파싱 지원 업데이트
- `install_mac.sh` - 5개 도구 설치 지원
- `install_win.ps1` - 5개 도구 설치 지원
- `README.md` - 멀티 도구 지원 반영

### Definition of Done
- [x] 기존 Claude Code 동작이 동일하게 유지됨 (하위 호환성)
- [x] Phase 1에 5개 도구의 세션 파싱 지침이 포함됨
- [x] 설치 스크립트가 도구 선택 후 해당 위치에 설치함
- [x] Phase 2/3 내용이 변경되지 않음 (도구명 파라미터화 제외)

### Must Have
- 5개 도구 각각의 세션 파일 위치, 형식, 파싱 방법 지침
- 환경 자동 감지 지침 (어떤 도구에서 실행 중인지 판별)
- 감지 실패 시 사용자에게 직접 질문하는 fallback
- 설치 스크립트 멀티 도구 지원
- 기존 Claude Code 하위 호환성 유지

### Must NOT Have (Guardrails)
- Cursor 지원 추가 (5개 도구만)
- 크로스 도구 세션 파싱 (각 도구는 자기 세션만 파싱)
- Antigravity conversations/ (.pb) 파싱 시도
- Antigravity knowledge/ 또는 browser_recordings/ 파싱
- DEVLOG.md 출력 형식 변경
- Phase 2/3 로직 변경 (도구명 참조 최소 업데이트 제외)
- 실행 가능한 코드/스크립트 파일 생성 (마크다운 지시사항만)
- 새 출력 파일 추가 (DEVLOG.md, AI_CASE_STUDY.md만)

---

## Verification Strategy (MANDATORY)

### Test Decision
- **Infrastructure exists**: NO (마크다운 스킬 파일, 테스트 코드 없음)
- **User wants tests**: Manual-only
- **Framework**: 없음

### Manual QA

각 TODO의 검증은 파일 내용 확인 + 실제 도구 환경에서 수동 테스트로 진행.

**검증 가능한 도구** (이 머신에 설치됨):
- ✅ Claude Code
- ✅ OpenCode
- ✅ Antigravity

**검증 불가 도구** (미설치):
- ❌ Codex CLI → 문서 기반 best-effort 지침
- ❌ Gemini CLI → 문서 기반 best-effort 지침

---

## Task Flow

```
Task 1 (환경 감지 + 도구별 Phase 1 작성)
    ↓
Task 2 (Phase 2/3 도구명 파라미터화)
    ↓
Task 3 (install_mac.sh 업데이트)
    ↓  (병렬)
Task 4 (install_win.ps1 업데이트)
    ↓
Task 5 (README.md 업데이트)
```

## Parallelization

| Group | Tasks | Reason |
|-------|-------|--------|
| A | 3, 4 | 독립적인 플랫폼별 설치 스크립트 |

| Task | Depends On | Reason |
|------|------------|--------|
| 2 | 1 | Phase 1 구조 확정 후 Phase 2/3 최소 수정 |
| 3, 4 | 1 | write-post.md 최종 내용 확정 후 설치 대상 결정 |
| 5 | 1, 3, 4 | 전체 변경 사항 반영 |

---

## TODOs

- [x] 1. write-post.md Phase 1 멀티 에이전트 세션 파싱 업데이트

  **What to do**:

  `write-post.md`의 Phase 1 섹션 (line 13~120)을 아래 구조로 재작성:

  ### 1-1. 환경 감지 섹션 추가 (Phase 1 최상단)

  스킬 실행 시 에이전트가 자신의 환경을 판별하는 자연어 지침 작성:

  ```
  ## 환경 감지 (Environment Detection)

  스킬 실행 시 아래 순서로 현재 도구 환경을 판별합니다:

  1. **OpenCode**: `session_list` MCP 도구에 접근 가능한지 확인. 가능하면 OpenCode.
  2. **Claude Code**: `~/.claude/projects/` 폴더 존재 여부 확인. 존재하면 Claude Code.
  3. **Antigravity**: `~/.gemini/antigravity/brain/` 폴더 존재 여부 확인. 존재하면 Antigravity.
  4. **Codex CLI**: `~/.codex/sessions/` 폴더 존재 여부 확인. 존재하면 Codex CLI.
  5. **Gemini CLI**: `~/.gemini/tmp/` 폴더 존재 여부 확인. 존재하면 Gemini CLI.
  6. **감지 실패**: 위 모든 조건이 해당하지 않으면 사용자에게 직접 질문.
  ```

  ### 1-2. 도구별 세션 파싱 지침 작성

  각 도구에 대해 별도 섹션으로 세션 읽기 방법 기술:

  **Claude Code** (기존 내용 유지 + 정리):
  - 세션 위치: `~/.claude/projects/{프로젝트경로를-로치환}/`
  - 파일 형식: `.jsonl` (agent-*.jsonl 제외)
  - 파싱: `type: 'user'` → 사용자 요청, `type: 'assistant'` → Claude 응답
  - 기존 DEVLOG.md가 있으면 마지막 날짜 이후만 추가

  **OpenCode** (신규):
  - **1차 방법 (MCP 도구 사용 - 권장)**:
    - `session_list` → 현재 프로젝트의 세션 목록 조회
    - `session_read(session_id)` → 세션 메시지 읽기 (role, content 포함)
    - `session_search(query)` → 키워드로 세션 내 검색
  - **2차 방법 (MCP 도구 없을 때 - Raw 파일 파싱)**:
    - 세션 위치: `~/.local/share/opencode/storage/`
    - 프로젝트 해시: `storage/session/{project-hash}/` 폴더에서 현재 프로젝트 디렉토리와 매칭
    - 세션 메타: `session/{hash}/ses_*.json` → `directory` 필드로 프로젝트 매칭
    - 메시지: `message/ses_*/msg_*.json` → `role` 필드 (user/assistant)
    - 본문: `part/msg_*/prt_*.json` → `text` 필드에 실제 대화 내용
  - Windows: `%USERPROFILE%\.local\share\opencode\storage\`

  **Codex CLI** (신규):
  - 세션 위치: `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl`
  - 파일 형식: JSONL (각 줄이 JSON 객체)
  - 내용: 사용자 메시지, AI 응답, 도구 호출, 파일 변경, 토큰 사용 통계 포함
  - 날짜별 폴더 구조이므로 최신 날짜부터 역순 탐색
  - 이전 세션 이어하기: `codex resume` 또는 `codex --resume`
  - Windows: `%USERPROFILE%\.codex\sessions\`

  **Gemini CLI** (신규):
  - 자동 저장 위치: `~/.gemini/tmp/<project_hash>/chats/`
  - 수동 저장 위치: `~/.gemini/tmp/<project_hash>/checkpoints/` (`/chat save <tag>`)
  - 파일 형식: JSON (role: user/model, parts: content)
  - 프로젝트별 해시 폴더 자동 분리
  - 세션 관리: `/sessions` (목록), `/chat resume <tag>` (이어하기)
  - Windows: `%USERPROFILE%\.gemini\tmp\`

  **Antigravity** (신규):
  - 세션 위치: `~/.gemini/antigravity/brain/<conversation-id>/`
  - ⚠️ `conversations/` 폴더의 `.pb` 파일은 암호화되어 읽기 불가
  - 읽을 수 있는 마크다운 아티팩트:
    - `walkthrough.md` (가장 상세) → 없으면 `implementation_plan.md` → 없으면 `task.md`
    - `.metadata.json` 파일에서 `summary`, `updatedAt` 확인 가능
  - 대화 선택: brain/ 폴더의 최근 대화 10개를 `metadata.json` 기준으로 나열, 사용자에게 선택받기
  - `.md` 파일만 읽기 (이미지, .webp 등 바이너리 제외)
  - `.resolved`, `.resolved.N` 파일은 아티팩트 버전 이력 (최신 것 사용)

  ### 1-3. 공통 정리 규칙 유지

  기존 "정리 규칙" 섹션(line 96-118) 유지하되, 도구 특화 메타데이터 필터링 추가:
  - Claude Code: `<ide_opened_file>` 등 IDE 메타데이터 제외
  - OpenCode: 시스템 훅/커맨드 관련 메시지 제외 (예: `[search-mode]`, `<session-context>`)
  - Codex CLI: 토큰 사용 통계, 내부 도구 호출 세부사항 제외
  - Gemini CLI: 도구 실행 로그 제외
  - Antigravity: `.metadata.json`, `.resolved` 파일은 파싱 대상에서 제외 (아티팩트 본문만)

  **Must NOT do**:
  - Phase 2/3 내용 변경 (도구명 참조 제외 - Task 2에서 처리)
  - DEVLOG.md 출력 템플릿 변경 (line 19-72)
  - 기존 Claude Code 세션 파싱 로직 삭제 (확장만)

  **Parallelizable**: NO (다른 모든 태스크가 이 결과에 의존)

  **References** (CRITICAL):

  **Pattern References**:
  - `.claude/commands/write-post.md:13-120` - 현재 Phase 1 전체 내용. 이 구조를 기반으로 확장
  - `.claude/commands/write-post.md:86-118` - 현재 세션 파일 파싱 섹션. Claude Code 부분은 유지, 다른 도구 추가

  **Data Format References**:
  - `/Users/dahye.dyan/Documents/DEV/anti-skill/AI_CODING_TOOLS_FOLDER_STRUCTURE.md:912-1143` - 5개 도구의 세션 저장 위치 상세 정보
  - `~/.local/share/opencode/storage/` - OpenCode 실제 세션 데이터 구조 (session/message/part 3단계)
  - `~/.gemini/antigravity/brain/8a17b84e-2e3f-479c-9a91-44aafae5fc61/` - Antigravity brain 아티팩트 실제 예시

  **Prior Work References**:
  - `~/.gemini/antigravity/brain/8a17b84e-2e3f-479c-9a91-44aafae5fc61/implementation_plan.md` - Antigravity에서 작성한 범용 write-post 구현 계획 (환경 감지, 추출기 설계)

  **Acceptance Criteria**:
  - [ ] Phase 1 섹션에 환경 감지 지침이 포함됨
  - [ ] 5개 도구 각각에 대한 세션 파싱 지침이 독립 섹션으로 존재
  - [ ] 각 도구별 세션 위치, 파일 형식, 파싱 방법이 구체적으로 명시됨
  - [ ] 기존 Claude Code 세션 파싱 내용이 그대로 유지됨 (하위 호환성)
  - [ ] 감지 실패 시 사용자에게 질문하는 fallback 지침 포함
  - [ ] Antigravity brain/ 아티팩트 fallback 체인 명시 (walkthrough → implementation_plan → task)
  - [ ] OpenCode MCP 세션 도구 사용법이 1차 방법으로 명시됨
  - [ ] 모든 새 내용이 한국어로 작성됨 (기존 스타일 일관)
  - [ ] Phase 2/3 내용이 변경되지 않음

  **Commit**: YES
  - Message: `feat(skill): add multi-agent session parsing support for 5 AI tools`
  - Files: `.claude/commands/write-post.md`
  - Pre-commit: 파일 내용이 올바른 마크다운인지 확인

---

- [x] 2. Phase 2/3 도구명 참조 최소 파라미터화

  **What to do**:

  Phase 2/3에서 "Claude"가 하드코딩된 부분을 도구 중립적 표현으로 최소 수정:

  - line 34: `**Claude 작업:**` → `**AI 작업:**`
  - line 99: `Claude 작업은 **bullet point**로` → `AI 작업은 **bullet point**로`
  - line 238: `- **도구명**: (예: Claude Code)` → `- **도구명**: (예: Claude Code, OpenCode, Gemini CLI 등)`
  - line 326: `Claude 작업 내용은 구체적으로` → `AI 작업 내용은 구체적으로`

  **Must NOT do**:
  - Phase 2/3의 로직, 질문 순서, 템플릿 구조 변경
  - 4줄 이상의 변경 (최소 파라미터화만)
  - 이모지 변경

  **Parallelizable**: NO (Task 1 완료 후)

  **References**:
  - `.claude/commands/write-post.md:34` - `**Claude 작업:**`
  - `.claude/commands/write-post.md:99` - `Claude 작업은`
  - `.claude/commands/write-post.md:238` - `**도구명**`
  - `.claude/commands/write-post.md:326` - `Claude 작업 내용은`

  **Acceptance Criteria**:
  - [ ] "Claude 작업" → "AI 작업"으로 변경됨 (2곳)
  - [ ] 도구명 예시에 여러 도구가 나열됨
  - [ ] Phase 2/3의 다른 내용은 전혀 변경되지 않음
  - [ ] 변경은 정확히 4줄 이하

  **Commit**: YES (Task 1과 함께 단일 커밋)
  - Message: Task 1 커밋에 포함
  - Files: `.claude/commands/write-post.md`

---

- [x] 3. install_mac.sh 멀티 도구 설치 지원

  **What to do**:

  현재 Claude Code만 지원하는 install_mac.sh를 5개 도구 + 전역/프로젝트 선택 지원으로 확장:

  **설치 흐름 설계**:
  ```
  1. "어떤 도구에 설치할까요?" 질문 (복수 선택 가능)
     1) Claude Code
     2) OpenCode
     3) Codex CLI
     4) Gemini CLI
     5) Antigravity
     6) 전체
  2. "전역 설치 vs 프로젝트 설치?" 질문
  3. 선택된 도구별로 적절한 위치에 설치
  ```

  **도구별 설치 경로**:

  | 도구 | 전역 | 프로젝트 | 파일명 |
  |------|------|---------|--------|
  | Claude Code | `~/.claude/commands/` | `.claude/commands/` | `write-post.md` (그대로) |
  | OpenCode | `~/.config/opencode/skills/write-post/` | `.opencode/skills/write-post/` | `SKILL.md` (frontmatter 추가) |
  | Codex CLI | `~/.codex/skills/write-post/` | `.codex/skills/write-post/` | `SKILL.md` (frontmatter 추가) |
  | Gemini CLI | `~/.gemini/skills/write-post/` | `.gemini/skills/write-post/` | `SKILL.md` (frontmatter 추가) |
  | Antigravity | `~/.gemini/antigravity/skills/write-post/` | `.agent/skills/write-post/` | `SKILL.md` (frontmatter 추가) |

  **SKILL.md frontmatter** (Claude Code 이외 도구용):
  ```yaml
  ---
  name: write-post
  description: DEVLOG 생성부터 AI 활용 사례 게시글 작성까지 한 번에 진행합니다. AI 코딩 도구의 대화 세션을 자동으로 파싱하여 개발 로그를 만들고, 비개발자 대상 사례글까지 작성합니다.
  ---
  ```

  **설치 로직**:
  - Claude Code: 원본 `write-post.md`를 그대로 복사
  - 다른 도구: frontmatter를 앞에 붙여서 `SKILL.md`로 저장
  - `mkdir -p`로 디렉토리 생성 후 파일 다운로드/생성

  **Must NOT do**:
  - 기존 Claude Code 설치 흐름을 깨뜨리기
  - 미설치 도구 디렉토리를 강제로 생성하는 경고/에러 표시 (설치 자체는 허용)

  **Parallelizable**: YES (Task 4와 병렬)

  **References**:
  - `install_mac.sh` - 현재 설치 스크립트 (26줄). 이 구조를 기반으로 확장
  - `/Users/dahye.dyan/Documents/DEV/anti-skill/AI_CODING_TOOLS_FOLDER_STRUCTURE.md:1686-1709` - 도구별 스킬 폴더 위치

  **Acceptance Criteria**:
  - [ ] 5개 도구 선택지가 표시됨 (+ "전체" 옵션)
  - [ ] 전역/프로젝트 선택이 유지됨
  - [ ] Claude Code 선택 시 기존과 동일하게 `.claude/commands/write-post.md`에 설치됨
  - [ ] OpenCode 선택 시 frontmatter가 포함된 SKILL.md가 올바른 경로에 설치됨
  - [ ] 스크립트가 `curl | bash` 패턴으로 실행 가능
  - [ ] 설치 완료 메시지에 설치된 도구와 경로가 표시됨

  **Commit**: YES
  - Message: `feat(install): support multi-tool installation for 5 AI coding tools`
  - Files: `install_mac.sh`

---

- [x] 4. install_win.ps1 멀티 도구 설치 지원

  **What to do**:

  Task 3와 동일한 로직을 PowerShell로 구현:

  **Windows 경로 매핑**:

  | 도구 | 전역 | 프로젝트 |
  |------|------|---------|
  | Claude Code | `$env:USERPROFILE\.claude\commands\` | `.claude\commands\` |
  | OpenCode | `$env:USERPROFILE\.config\opencode\skills\write-post\` | `.opencode\skills\write-post\` |
  | Codex CLI | `$env:USERPROFILE\.codex\skills\write-post\` | `.codex\skills\write-post\` |
  | Gemini CLI | `$env:USERPROFILE\.gemini\skills\write-post\` | `.gemini\skills\write-post\` |
  | Antigravity | `$env:USERPROFILE\.gemini\antigravity\skills\write-post\` | `.agent\skills\write-post\` |

  **Must NOT do**:
  - Unix 경로 사용 (백슬래시 사용)
  - `iwr | iex` 패턴 깨뜨리기

  **Parallelizable**: YES (Task 3과 병렬)

  **References**:
  - `install_win.ps1` - 현재 설치 스크립트 (26줄)

  **Acceptance Criteria**:
  - [ ] Task 3과 동일한 기능이 PowerShell로 구현됨
  - [ ] Windows 경로가 올바르게 사용됨 (백슬래시)
  - [ ] `iwr -useb ... | iex` 패턴으로 실행 가능
  - [ ] `[Console]::ReadLine()` 으로 사용자 입력 처리

  **Commit**: YES (Task 3 커밋에 포함)
  - Message: Task 3 커밋에 포함
  - Files: `install_win.ps1`

---

- [x] 5. README.md 멀티 도구 지원 반영

  **What to do**:

  README.md를 업데이트하여 멀티 도구 지원을 반영:

  - 제목/설명에 "Claude Code" → "AI 코딩 도구(Claude Code, OpenCode, Codex CLI, Gemini CLI, Antigravity)" 반영
  - "지원 도구" 섹션 추가 (각 도구별 세션 읽기 방식 간략 설명)
  - 설치 방법에 도구 선택 과정 설명 추가
  - "이런 분께 추천" 섹션 업데이트 (Claude Code뿐 아니라 다른 도구 사용자도 포함)

  **Must NOT do**:
  - README 전체를 재작성 (기존 구조 유지, 필요한 부분만 수정)
  - 기존 예시/다이어그램 삭제

  **Parallelizable**: NO (Task 1, 3, 4 완료 후)

  **References**:
  - `README.md` - 현재 README (전체)

  **Acceptance Criteria**:
  - [ ] 5개 지원 도구가 명시됨
  - [ ] 도구별 세션 읽기 방식이 간략히 설명됨
  - [ ] 설치 방법에 도구 선택 과정이 포함됨
  - [ ] 기존 내용 구조가 유지됨

  **Commit**: YES
  - Message: `docs: update README for multi-agent tool support`
  - Files: `README.md`

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 + 2 | `feat(skill): add multi-agent session parsing for 5 AI tools` | `write-post.md` | 마크다운 구문 확인 |
| 3 + 4 | `feat(install): support multi-tool installation for 5 AI coding tools` | `install_mac.sh`, `install_win.ps1` | 스크립트 문법 확인 (`bash -n`, PowerShell 파싱) |
| 5 | `docs: update README for multi-agent tool support` | `README.md` | 마크다운 구문 확인 |

---

## Success Criteria

### Verification Commands
```bash
# write-post.md에 5개 도구 섹션이 모두 포함되었는지 확인
grep -c "Claude Code\|OpenCode\|Codex CLI\|Gemini CLI\|Antigravity" .claude/commands/write-post.md
# 예상: 각 도구명이 최소 2회 이상 등장

# install_mac.sh 문법 검증
bash -n install_mac.sh
# 예상: 에러 없음

# Phase 2/3 동결 확인 (Phase 2 시작점 이후 변경이 도구명 참조뿐인지)
```

### Final Checklist
- [x] 모든 "Must Have" 항목 충족
- [x] 모든 "Must NOT Have" 가드레일 준수
- [x] 기존 Claude Code 동작 하위 호환성 유지
- [x] 한국어 스타일 일관성 유지
- [x] 5개 도구 모두의 세션 파싱 지침 포함
