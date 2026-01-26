# write-post - 개발 로그

AI 코딩 도구와 함께 진행한 개발 작업 기록입니다.

---

## 2025-12-28 (Day 1)

### 1. Claude Code 글쓰기 커맨드 초기 생성

```
Claude Code용 글쓰기 커맨드 모음을 만들고 싶어. DEVLOG 자동 생성 커맨드와 AI 활용 사례글 작성 커맨드를 분리해서 만들어줘.
```

**Claude Code 작업:**
- `/devlog` 커맨드 생성 - Claude Code 세션 파일(`.jsonl`)을 파싱하여 날짜별 작업 로그 자동 생성
- `/ai-case` 커맨드 생성 - DEVLOG 기반으로 비개발자 대상 사례글 작성 지원
- `.claude/commands/devlog.md` - 세션 파싱 규칙, 출력 포맷, 정리 규칙 포함
- `.claude/commands/ai-case.md` - 11개 질문 흐름, 게시글 템플릿, 작성 가이드 포함
- `README.md` - 프로젝트 설명 문서

---

### 2. README 상세 설명 추가

```
README에 사용법이랑 설명을 더 자세하게 추가해줘
```

**Claude Code 작업:**
- README.md에 커맨드별 상세 사용법, 결과물 예시, 추천 대상 등 추가

---

## 2025-12-29 (Day 2)

### 3. 사례글 커맨드 업데이트

```
ai-case.md 내용 업데이트
```

**Claude Code 작업:**
- `/ai-case` 커맨드의 질문 흐름, 템플릿 구조 개선
- 스토리텔링 형식 작성 가이드라인 추가
- 재사용 가능한 프롬프트 섹션 추가

---

## 2025-12-31 (Day 3)

### 4. 두 커맨드를 하나로 통합

```
현재 프로세스는 devlog를 먼저 실행해서 만들고, 사용자가 한 번 확인하고 devlog 수정요청한다음(선택), ai-case를 실행해서 사례게시글을 쓰는 순서야. 근데 이걸 하나의 커맨드로 합치고 싶은데 어떻게 하면 좋을까?
```

```
그러면 커맨드가 총 3개야? 나는 write-post.md 커맨드 하나로 관리하고 싶어
```

```
혹시 하나의 커맨드로 했을 때 너무 문서가 길어서 잘 작동하지 않는 등의 우려가 있니?
```

```
2번이 좋은데 절대로 안헷갈리게 핵심만 남길 수 있어?
```

**Claude Code 작업:**
- 처음에 `write-post.md` + 기존 `devlog.md`, `ai-case.md` 유지 방안 제안 → 사용자가 하나로 통합 요청
- 문서 길이 우려 상담: 두 파일 합치면 ~450줄 → Python 예시 스크립트(~110줄) 제거하고 핵심만 남기는 "간소화" 방향으로 결정
- `/devlog`와 `/ai-case`를 `/write-post` 하나의 커맨드로 통합 (~340줄)
- Phase 1(DEVLOG 생성) → Phase 2(확인) → Phase 3(사례글 작성) 3단계 워크플로우 설계
- 기존 `devlog.md`, `ai-case.md` 삭제

---

### 5. Phase 2 수정 요청 예시 추가

```
write-post md를 조금 업데이트하자. phase2에서 수정할 부분에 대한 예시를 좀 제공하면 좋겠어.
```

```
[사용자 아이디어]
1. 내가 요구한 명령어를 조금 더 순화시켜달라고 하거나
2. 클로드가 한 일 중에 너무 개발용어 같은 건 비개발자용으로 수정해달라고 하거나
3. 날짜별로 그룹핑 말고 작업 범위별로 그룹핑해달라고 하거나
4. 각 단계별로 나의 시행착오나 배운점을 추가해달라고 하거나
```

```
너무 나열하면 뭘해야하는지 모르니까 카테고리를 나누는건?
```

```
아 조금 더 설명이 포함된 예시면 좋겠는데.
```

**Claude Code 작업:**
- 사용자와 티키타카하며 수정 요청 예시 카테고리화:
  - **표현 다듬기**: "이거 왜 안돼 ㅡㅡ" → "특정 상황에서 오류가 발생했다" / "API 라우트 생성" → "서버와 통신하는 경로 설정"
  - **구조 변경**: 날짜별 → 작업 범위별 그룹핑 / 잡다한 설정 5개 → "초기 환경 설정" 하나로
  - **내용 보강**: 맥락 추가, 배운점 추가, 에러 해결 상세화
  - **제외 요청**: 민감한 내용, 실수 커밋 등 제외
- 1번(내 요청 순화)과 2번(Claude 작업 비개발자화)은 주체가 다르므로 분리 유지

---

### 6. Phase 3 맥락 질문 재구성

```
phase 3을 수정해볼래. 2단계 맥락질문의 구성을 좀 바꾸면 좋겠어. 특히 클로드코드를 쓰는 거라서 왜 클로드코드냐? 이건 질문이 조금 의미 없는 것 같아.
```

```
막혔던 부분은 클로드가 잘못이해하거나, 내가 스스로 막혔던 부분 - 이런 식으로 구분하자.
```

**Claude Code 작업:**
- 기존 11개 질문 → 8개로 축소, 4개 카테고리로 재구성:
  - **배경 (Before)**: 문제 상황 + 시작 계기 (기존 2개 → 1개로 통합)
  - **과정 (During)**: 작업 하이라이트, 인상적인 순간, 막혔던 부분
  - **결과 (After)**: 결과 임팩트
  - **공유 (For Readers)**: 타겟 독자, 핵심 팁, 향후 계획
- "AI 선택 이유" 질문 삭제 (Claude Code 전용이라 의미 없음)
- "팀 협업 변화" 질문 삭제 (개인 사용자에게 한정적)
- "막혔던 부분" 범위 확장: AI가 잘 못 이해한 것 / 내가 뭘 요청해야 할지 몰랐던 것 / 해결 방법
- 번호 리스트 → bullet 리스트로 변경 (마크다운 렌더링 깨짐 방지)

---

### 7. 사례글 템플릿 검토 및 수정

```
사례글 작성 템플릿도 조금 변경되어야 하는 부분이 있을지 검토해줘.
```

```
전체적으로 대화체로 다 바꾸면 좋겠어
```

```
아니 기존대로 하되 시작계기만 빼자
```

**Claude Code 작업:**
- 질문 구조 변경에 맞춰 게시글 템플릿 검토
- 대화체 헤딩 전환 제안 → 사용자가 기존 유지 결정
- `## 💡 시작 계기` 섹션만 삭제하고 `## 😫 문제 상황 (Before)`에 통합

---

### 8. 설치 스크립트 업데이트 및 전역/프로젝트 선택

```
자 이제 혹시 mac용 윈도우파워쉘용 설치파일은 변경할 필요 없니?
```

```
응 수정하고 install_mac, install_win 이런식으로 바꾸자
```

```
[리드미 설치방법 위치에 대해] 리드미에서 설치방법이 더 상단에 있으면 좋겠어
```

```
질문이 있어. 이걸 전역에 설치하는 스킬로 만들 수 있어?
```

**Claude Code 작업:**
- `install.sh` → `install_mac.sh`, `install.ps1` → `install_win.ps1`로 리네이밍
- 기존 `devlog.md` + `ai-case.md` 2개 파일 설치 → `write-post.md` 1개 파일 설치로 변경
- 전역 설치(`~/.claude/commands/`) / 프로젝트 설치(`.claude/commands/`) 선택 옵션 추가
- `curl -fsSL ... | bash` 한 줄 설치 지원
- README에 설치 방법 섹션을 상단으로 이동

---

### 9. 리포지토리 이름 변경

```
폴더명과 리포 명을 write-post로 바꿨어. 리드미랑 등등 수정해줘
```

**Claude Code 작업:**
- `ai-post-write` → `write-post`로 전체 리네이밍
- README.md, install_mac.sh, install_win.ps1의 GitHub URL 3곳씩 업데이트
- Git remote URL 변경: `git remote set-url origin https://github.com/daht-mad/write-post.git`

---

### 10. 설치 스크립트 파이프 실행 버그 수정

```
근데 전역설치/프로젝트설치 물어보고 답변 안했는데 설치완료래
```

```
근데 방금 curl -fsSL https://raw.githubusercontent.com/daht-mad/write-post/main/install_mac.sh | bash 했는데도 바로 설치완료로 나와
```

**Claude Code 작업:**
- **원인**: `curl | bash` 파이프 실행 시 stdin이 스크립트 내용으로 전달되어 `read` 명령이 사용자 입력을 받지 못하는 문제
- **해결**: Mac에서 `read ... </dev/tty` 추가 → 터미널에서 직접 입력 받도록 수정
- Windows에서도 동일 문제 → `[Console]::ReadLine()` 으로 콘솔에서 직접 입력 받도록 수정
- 수정 후 push 했지만 GitHub raw 캐시(~5분)로 이전 버전이 계속 제공되는 현상 발견 → jsDelivr CDN 우회 방법 안내

---

### 11. 팀 공유용 슬랙 멘트 작성

```
팀원들이 사내에서 AX 시도 중인데 사례글을 써야하거든. 근데 그게 오래걸리잖아 무슨 작업했는지 기억도 안나고. 한방에 쓰는 거라는 걸 강조한 버전으로 공유용 다시해줘
```

**Claude Code 작업:**
- 슬랙 공유용 멘트 작성 (문제 상황 공감 + 해결책 강조)
- Mac/Windows 설치 명령어 분리 포함

---

## 2026-01-26 (Day 4)

### 12. 다중 AI 도구 세션 파싱 계획 수립

```
[Antigravity에서] 자동 Devlog 생성기 (Auto Devlog Generator) 계획
```

```
[OpenCode에서] AI_CODING_TOOLS_FOLDER_STRUCTURE.md에서 8번 섹션에 에이전트 별 대화세션 저장위치가 나와있거든? 이거에 따라서 현재 write-post 스킬을 수정하고 싶어.
```

**Antigravity 작업:**
- write-post 범용화를 위한 아키텍처 설계 ("Agent-Agnostic Context Extraction")
- 환경 감지 로직 설계: Antigravity → Claude Code → Cursor 순으로 자동 판별
- 환경별 추출기 설계: Antigravity는 Summary-first (walkthrough.md), Claude Code는 Raw-parsing (.jsonl)
- `implementation_plan.md` 아티팩트에 범용 write-post 구현 계획 작성

**OpenCode 작업 (Prometheus 플래너):**
- 5개 도구별 세션 저장 위치 조사 (웹 검색 + 로컬 파일 확인):
  - Claude Code: `~/.claude/projects/<hash>/*.jsonl` (JSONL)
  - OpenCode: `~/.local/share/opencode/storage/` (3단계 JSON: session/message/part)
  - Codex CLI: `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl` (JSONL)
  - Gemini CLI: `~/.gemini/tmp/<hash>/chats/` (JSON)
  - Antigravity: `~/.gemini/antigravity/brain/` (마크다운 아티팩트, `.pb`는 암호화)
- Antigravity conversations/ 폴더의 `.pb` 파일이 Google 암호화 키 필요 → brain/ 마크다운 아티팩트 활용 대안 결정
- OpenCode는 MCP 세션 도구(`session_list`, `session_read`) 제공 → 1차 방법으로 채택
- Codex CLI, Gemini CLI 세션 형식 웹 검색으로 교차 검증 완료
- 5개 태스크의 실행 계획 수립 (의존관계 + 병렬화 맵)

---

### 13. 다중 AI 도구 세션 파싱 구현

```
[OpenCode에서 실행] multi-agent-write-post 플랜 실행
```

**OpenCode 작업 (Atlas 실행자):**
- **Task 1**: `write-post.md` Phase 1에 환경 감지(6단계 우선순위) + 5개 도구 세션 파싱 지침 추가 (+97줄)
- **Task 2**: Phase 2/3의 "Claude 작업" → "AI 작업"으로 최소 수정 (2줄만 변경)
- **Task 3+4 (병렬)**: `install_mac.sh`(+126줄), `install_win.ps1`(+115줄) 멀티 도구 설치 메뉴 추가
  - 5개 도구 선택지 + "전체" 옵션
  - 도구별 설치 경로 매핑 (전역/프로젝트)
  - 비-Claude 도구는 YAML frontmatter 동적 주입
- **Task 5**: `README.md`에 지원 도구 비교 테이블 + 설치 안내 업데이트
- 전체 검증: bash 문법 체크, 키워드 존재 확인, Phase 2/3 동결 확인

---

### 14. 스킬 디렉토리 구조 전환 (Progressive Disclosure)

```
skill-creator 스킬의 가이드라인을 적용하여 write-post 스킬을 구조적으로 개선해줘. 모놀리식 단일 파일에서 디렉토리 구조로 전환.
```

**OpenCode 작업 (Prometheus 플래너 → Atlas 실행자):**
- skill-creator 가이드라인 분석: "context window는 공공재" → Progressive Disclosure 패턴 적용
- `.claude/commands/write-post.md` (392줄 모놀리식) → 디렉토리 구조로 분할:
  - `.claude/skills/write-post/SKILL.md` (~250줄) - 핵심 워크플로우 (Phase 1/2/3 프로세스)
  - `.claude/skills/write-post/references/case-study-template.md` (~140줄) - 사례글 템플릿 + 작성 가이드
- YAML frontmatter 추가 (name, description) → 모든 도구에서 동일한 SKILL.md 사용 가능
- 이전 경로에 리다이렉트 stub 유지 ("스킬이 이동했습니다" 안내)
- 설치 스크립트에서 frontmatter 동적 주입 로직 제거 (이미 SKILL.md에 포함)
- 설치 스크립트에 이전 `commands/write-post.md` cleanup 로직 추가

---

### 15. 프로젝트 단위 멀티 도구 세션 스캔

```
하나의 프로젝트를 여러 AI 코딩 도구로 작업한 경우, 모든 도구의 세션을 프로젝트 단위로 수집하여 통합 DEVLOG를 생성하도록 업데이트해줘.
```

**OpenCode 작업:**
- "단일 도구 감지" → "프로젝트 단위 멀티 도구 스캔"으로 전환
- "환경 감지" 섹션 → "프로젝트 세션 스캔" 섹션으로 교체
- 도구별 프로젝트 매칭 방법 5개 구현:
  - Claude Code: 절대경로를 `-`로 치환한 폴더명 탐색 (예: `/Users/dahye/DEV/my-app` → `-Users-dahye-DEV-my-app`)
  - OpenCode: `directory` 필드 또는 MCP `session_list` 자동 필터링
  - Antigravity: `code_tracker/active/` 디렉토리 또는 `file:///` 링크 매칭
  - Codex CLI: `cwd` 또는 `working_directory` 필드 매칭 (best-effort)
  - Gemini CLI: 해시 디렉토리 내 경로 언급 확인 (best-effort)
- 여러 도구의 세션을 날짜순으로 병합하는 구조화 규칙 추가
- DEVLOG 헤더: `{도구명}와 함께` → `AI 코딩 도구와 함께` (도구 중립)
- 작업 섹션: `**{해당 작업의 도구명} 작업:**` (실제 도구명 동적 표시)
- 사례글 템플릿 도구명 필드: 복수 도구 나열 가능하도록 변경

---

### 16. 슬래시 커맨드 발동 이슈 해결

```
기존 슬래시커맨드로 해당 스킬이 발동되는 것도 똑같아?
```

**OpenCode 작업:**
- `.claude/commands/write-post.md` (리다이렉트 stub)와 `.claude/skills/write-post/SKILL.md` (실제 스킬)이 공존하는 문제 발견
- Claude Code에서 `/write-post` 실행 시 commands/ 파일이 우선 발동 → 마이그레이션 안내만 표시되는 이슈
- 해결: `.claude/commands/write-post.md` 리다이렉트 stub 삭제

---

### 17. Phase 3 대화형 프로세스 자동 진행 훅 충돌 해결

```
왜 자꾸 TODO CONTINUATION 훅이 반복 발동돼?
```

```
이 스킬 쓸 때 훅 반복되는 거 또 발생할 수 있어?
```

**OpenCode 작업:**
- Phase 3의 대화형 단계(맥락 질문, 제목 선정, 피드백)를 todo로 등록하면, TODO CONTINUATION 훅이 매 턴마다 "자동 진행하라"고 반복 발동되는 문제 발견
- 원인: 훅은 "pending 태스크 있음 → 자동 진행" 로직인데, Phase 3은 사용자 답변이 필수라 자동 진행 불가 → 무한 반복
- 해결: SKILL.md Phase 3 시작 부분에 "대화형 프로세스이므로 todo/task 목록에 등록하지 말 것" 경고 추가

---

### 18. Antigravity 내부 실행 시 과거 대화 접근 방식 추가

```
만약에 안티그래비티에서 해당 스킬을 발동하게 되면 그땐 읽어올 수 있니?
```

```
조금 더 조사해봐
```

**OpenCode 작업:**
- Antigravity의 `.pb` 파일(암호화된 대화 기록)을 외부에서 읽을 수 없는 한계 조사
- Antigravity Power User Guide (Kerrick Long, 2026-01-03) 발견: Antigravity 에이전트는 내부적으로 과거 대화를 검색/참조하는 기능 보유 ("Reference Past Conversations")
- 로컬 파일 구조 탐색: `conversations/*.pb` (암호화), `brain/*.md` (평문), `knowledge/` (KI 아티팩트), `annotations/*.pbtxt` (평문 protobuf)
- 결론: Antigravity 내부에서 스킬 발동 시 에이전트 자체 검색으로 과거 대화 참조 가능 (1차 방법), 외부 도구에서는 `brain/` 마크다운만 가능 (2차 방법)
- SKILL.md Antigravity 섹션에 1차/2차 방법 분리 기술

---

## 커밋 히스토리

| 날짜 | 커밋 | 설명 |
|------|------|------|
| 12/28 | `18ff117` | feat: Claude Code 글쓰기 커맨드 모음 |
| 12/28 | `e0d6bcf` | docs: README 상세 설명 추가 |
| 12/29 | `1c269d5` | update: ai-case.md |
| 12/31 | `00bd4a9` | refactor: /devlog + /ai-case를 /write-post로 통합 |
| 12/31 | `243e236` | feat: 설치 시 전역/프로젝트 선택 옵션 추가 |
| 12/31 | `6175eb4` | rename: ai-post-write → write-post |
| 12/31 | `1192228` | fix: curl 파이프에서 사용자 입력 받도록 수정 |
| 12/31 | `168511b` | fix: Windows 스크립트도 파이프 실행 시 입력 받도록 수정 |
| 01/26 | `0de8b63` | feat: write-post 커맨드에 다중 AI 도구 지원 추가 |
| 01/26 | `dcea06f` | feat: 설치 스크립트에 다중 AI 도구 지원 추가 |
| 01/26 | `3eb732b` | docs: README에 다중 AI 도구 지원 정보 추가 |
| 01/26 | `cd186d9` | refactor(skill): restructure write-post as skill directory with Progressive Disclosure |
| 01/26 | `6d6aba2` | feat(install): update installation for skill directory structure |
| 01/26 | `a2d8700` | docs: update README paths for skill directory structure |
| 01/26 | `dc27cbb` | feat(skill): add multi-tool project-level session scanning |
| 01/26 | `c12a928` | docs: update README to reflect multi-tool project-level session scanning |
| 01/26 | `dc551c5` | chore: remove deprecated commands/write-post.md migration notice |
| 01/26 | `39b533e` | docs(skill): Phase 3 대화형 프로세스 자동 진행 훅 방지 경고 추가 |

---

## 사용한 도구

| 도구 | 사용 기간 | 주요 역할 |
|------|----------|----------|
| **Claude Code** | Day 1-3 (12/28-12/31) | 초기 커맨드 생성, 통합, 설치 스크립트, 버그 수정 |
| **Antigravity** | Day 4 (01/26) | 범용화 아키텍처 설계, 구현 계획 수립 |
| **OpenCode** | Day 4 (01/26) | 멀티 도구 지원 계획 + 구현 + 구조 개선 |

---

## 기술 스택

- **스킬 파일**: Markdown (YAML frontmatter, Progressive Disclosure)
- **설치 스크립트**: Bash (Mac/Linux), PowerShell (Windows)
- **세션 파싱**: JSONL, JSON, Markdown 아티팩트
- **배포**: GitHub Raw + curl/iwr 파이프 설치

---

## 주요 기능

1. **DEVLOG 자동 생성**
   - 5개 AI 코딩 도구(Claude Code, OpenCode, Codex CLI, Gemini CLI, Antigravity)의 세션 파일을 프로젝트 단위로 스캔
   - 날짜별 작업 기록 자동 정리 (사용자 요청 원문 + AI 작업 bullet point)
   - 기존 DEVLOG.md가 있으면 마지막 날짜 이후만 이어서 추가

2. **AI 활용 사례글 작성**
   - DEVLOG 기반 스토리텔링 형식 게시글 생성
   - 8개 맥락 질문을 한 번에 하나씩 → 추천 답변 3개씩 제공
   - 비개발자 대상 (코드 제외, 프롬프트는 인용문으로 포함)
   - 재사용 가능한 프롬프트 템플릿 + 이미지 추천 + 게시판 업로드 안내

3. **멀티 도구 통합**
   - 프로젝트 단위 세션 스캔 (여러 도구로 작업해도 하나의 DEVLOG로 통합)
   - 도구별 프로젝트 매칭 로직 (경로 인코딩, directory 필드, file:// 링크, code_tracker 등)
   - 같은 날짜에 여러 도구 사용 시 도구별 구분 기록

4. **원클릭 설치**
   - `curl | bash` / `iwr | iex` 한 줄 설치
   - 5개 도구 중 선택 설치 (또는 전체)
   - 전역/프로젝트 설치 선택
   - 이전 버전 자동 cleanup

5. **Progressive Disclosure 구조**
   - SKILL.md (~250줄, 핵심 워크플로우) + references/ (~140줄, 템플릿/가이드)
   - Phase 3 초안 작성 시에만 references 파일 참조 → 컨텍스트 효율성 극대화
