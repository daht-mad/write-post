# write-post

AI 코딩 도구(Claude Code, OpenCode, Codex CLI, Gemini CLI, Antigravity)로 작업한 내용을 **로그로 남기고**, 그 로그를 바탕으로 **AI 활용 사례글**을 작성하는 커맨드입니다.

## 왜 만들었나요?

AI 코딩 도구로 뭔가를 만들고 나면 "이거 어떻게 했더라?" 싶을 때가 많습니다. 나중에 사례글을 쓰려고 해도 기억이 안 나고, 대화 내역을 다시 뒤지기도 번거롭죠.

이 커맨드를 쓰면 `/write-post` 한 번으로:
1. **DEVLOG 자동 생성** - 세션 파일에서 작업 내역을 추출
2. **확인 및 수정** - 생성된 로그를 확인하고 수정
3. **사례글 작성** - 비개발자도 읽기 쉬운 글로 변환

---

## 지원 도구

이 커맨드는 다음 5개 AI 코딩 도구를 지원합니다:

| 도구 | 세션 읽기 방식 |
|------|---------------|
| **Claude Code** | `~/.claude/projects/` 폴더의 `.jsonl` 파일 파싱 |
| **OpenCode** | MCP 세션 도구 (`session_list`, `session_read`) 또는 `~/.local/share/opencode/storage/` 파일 파싱 |
| **Codex CLI** | `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl` 파일 파싱 |
| **Gemini CLI** | `~/.gemini/tmp/<project_hash>/chats/` 또는 `checkpoints/` 파일 파싱 |
| **Antigravity** | (1) Antigravity 내부에서 스킬 실행 시: 내부 검색으로 과거 대화 직접 참조 (2) 다른 도구에서 실행 시: `~/.gemini/antigravity/brain/<conversation-id>/` 마크다운 아티팩트 읽기 |

프로젝트 단위로 모든 도구의 세션을 스캔하여 통합 DEVLOG를 생성합니다. 하나의 프로젝트를 여러 도구로 작업했더라도, 모든 세션을 자동으로 수집합니다.

---

## 설치 방법

실행하면 설치 위치를 선택할 수 있습니다:
- **도구 선택**: 설치할 AI 코딩 도구 선택 (Claude Code, OpenCode, Codex CLI, Gemini CLI, Antigravity, 또는 전체)
- **설치 위치**: 전역 설치 또는 프로젝트 설치

### Mac / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/daht-mad/write-post/main/install_mac.sh | bash
```

설치 시 사용할 도구와 설치 위치를 선택할 수 있습니다.

### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/daht-mad/write-post/main/install_win.ps1 | iex
```

설치 시 사용할 도구와 설치 위치를 선택할 수 있습니다.

### 설치 후

설치가 완료되면 **사용 중인 AI 코딩 도구를 재시작**해야 커맨드가 인식됩니다.
- VSCode: Claude Code 패널 닫았다가 다시 열기
- 터미널: `claude` 명령어 다시 실행

### 설치 경로

도구와 설치 위치(전역/프로젝트)에 따라 다음 경로에 스킬 파일이 설치됩니다:

| 도구 | 전역 설치 | 프로젝트 설치 |
|------|----------|-------------|
| **Claude Code** | `~/.claude/skills/write-post/` | `.claude/skills/write-post/` |
| **OpenCode** | `~/.config/opencode/skills/write-post/` | `.opencode/skills/write-post/` |
| **Codex CLI** | `~/.codex/skills/write-post/` | `.codex/skills/write-post/` |
| **Gemini CLI** | `~/.gemini/skills/write-post/` | `.gemini/skills/write-post/` |
| **Antigravity** | `~/.gemini/antigravity/skills/write-post/` | `.agent/skills/write-post/` |

> Windows에서는 `~`가 `%USERPROFILE%`로 대체됩니다.

---

## 사용법

```
/write-post
```

이 커맨드 하나로 DEVLOG 생성부터 사례글 작성까지 전체 프로세스가 진행됩니다.

---

## 전체 흐름

```
/write-post 실행
    ↓
Phase 1: DEVLOG 생성
    - 기존 DEVLOG 있으면 → 이어쓰기 / 새 파일 / 덮어쓰기 선택
    - 첫 실행이면 → 모든 세션 스캔하여 DEVLOG.md 생성
    - 날짜별/도구별로 정리 및 병합
    ↓
Phase 2: DEVLOG 확인
    - "수정할 부분 있으세요?" 질문
    - 수정 요청 시 반영
    - 확인 완료 후 다음 단계로
    ↓
Phase 3: 사례글 작성
    - 맥락 질문 (한 번에 하나씩)
    - 제목 선정
    - AI_CASE_STUDY.md 초안 작성
    - 피드백 반영
    - 이미지 추천 + 업로드 안내
```

---

## Phase별 상세 설명

### Phase 1: DEVLOG 생성

프로젝트에서 사용한 모든 AI 코딩 도구의 세션을 스캔하여 통합 작업 로그를 자동 생성합니다.

**기존 DEVLOG가 있으면 선택지를 제시합니다:**
1. **이어쓰기** — 마지막 기록 이후 세션만 추가 (추천)
2. **새 DEVLOG 생성** — `DEVLOG_{제목}.md`로 세션별 파일 분리
3. **처음부터 다시 생성** — 기존 파일 덮어쓰기

**생성되는 내용:**
- 날짜별 작업 기록 (Day 1, Day 2...)
- 사용자 요청 원문 (코드블록)
- AI가 수행한 작업 (도구별 표시, bullet point)
- 커밋 히스토리 테이블
- 기술 스택 정리
- 주요 기능 요약

**결과물:** `DEVLOG.md` 또는 `DEVLOG_{제목}.md`

---

### Phase 2: DEVLOG 확인

생성된 DEVLOG를 확인하고 수정할 기회를 제공합니다.

- 빠진 내용 추가 요청 가능
- 잘못된 부분 수정 요청 가능
- "OK" 하면 다음 단계로 진행

---

### Phase 3: 사례글 작성

DEVLOG를 바탕으로 비개발자 대상 AI 활용 사례글을 작성합니다.

**특징:**
- **질문을 많이 합니다** - 한 번에 하나씩 질문하며 맥락을 충분히 파악
- **추천 답변 제공** - "응" 한 마디로 진행 가능
- **스토리텔링 형식** - 딱딱한 나열이 아닌 자연스러운 이야기
- **복붙 가능한 프롬프트** - 독자가 바로 사용할 수 있는 템플릿 포함

**질문 항목:**

1. 문제 상황 + 시작 계기
2. 작업 하이라이트
3. 인상적인 순간
4. 막혔던 부분
5. 결과 임팩트
6. 타겟 독자
7. 핵심 팁
8. 향후 계획

**결과물:** `AI_CASE_STUDY.md`

---

## 결과물 예시

### DEVLOG.md
```markdown
# 프로젝트명 - 개발 로그

## 2024-01-15 (Day 1)

### 1. 대시보드 초기 설정

사용자 요청: "Next.js로 대시보드 만들어줘"

**Claude Code 작업:**
- Next.js 프로젝트 생성
- Tailwind CSS 설정
- 기본 레이아웃 구성
```

### AI_CASE_STUDY.md
```markdown
# [Claude Code] 비개발자가 2시간 만에 매출 대시보드를 만들었다

## 📝 한줄 요약
매주 3시간 걸리던 매출 리포트를 자동화 대시보드로 만들어 주 2시간 절약

## 🔧 작업 과정

### 막막했던 시작 - "그냥 대시보드 만들어줘"로 시작했다

처음엔 뭘 요청해야 할지도 몰랐다...
```

---

## 이런 분께 추천

- AI 코딩 도구(Claude Code, OpenCode, Codex CLI, Gemini CLI, Antigravity)로 작업한 내용을 기록으로 남기고 싶은 분
- AI 활용 사례를 팀이나 커뮤니티에 공유하고 싶은 분
- 글쓰기가 막막한 분 (질문에 답하다 보면 글이 완성됨)
- 비개발자 독자를 위한 글을 써야 하는 분

---

## 라이선스

MIT
