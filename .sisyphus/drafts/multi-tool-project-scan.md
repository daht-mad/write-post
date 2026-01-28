# Draft: 프로젝트 단위 멀티 도구 세션 수집

## Requirements (confirmed)
- **목표**: 하나의 프로젝트에서 여러 AI 코딩 도구로 작업한 세션을 모두 수집하여 통합 DEVLOG 생성
- **수집 방식**: 자동 전체 스캔 (모든 도구의 세션 경로를 자동으로 스캔)
- **DEVLOG 헤더**: "AI 코딩 도구와 함께 진행한 개발 작업 기록입니다" (도구 중립적)
- **섹션별 도구명**: 각 작업 섹션의 `**{도구명} 작업:**` 에서 실제 도구명 표시
- **미설치 도구**: best-effort 구현 (문서 기반 추정)
- **이어쓰기**: 날짜 기준 필터링 (마지막 날짜 이후 세션을 모든 도구에서 수집)

## Technical Decisions
- 환경 감지 → 프로젝트 세션 스캔으로 전환
- 단일 도구 감지 대신 전체 도구 경로 스캔 후 현재 프로젝트 매칭
- `{도구명}` 변수: 전역 → 섹션별 (작업마다 어떤 도구로 했는지 표시)
- 날짜순 병합: 여러 도구의 세션을 시간순으로 정렬

## Research Findings
- Claude Code: `~/.claude/projects/{경로-인코딩}/` 또는 `history.jsonl`의 `project` 필드 → 매칭 쉬움
- OpenCode: `ses_*.json`의 `directory` 필드 또는 MCP `session_list` → 매칭 쉬움
- Antigravity: `code_tracker/active/{프로젝트명}_{해시}/` 또는 `brain/*/task.md.resolved`의 `file:///` 링크 → 가능하지만 복잡
- Codex CLI: 미설치. JSONL에 cwd 필드 있을 가능성 → best-effort
- Gemini CLI: `~/.gemini/tmp/` 비어있음. 해시↔경로 매핑 불명 → best-effort

## Open Questions
- (모두 해결됨)

## Scope Boundaries
- INCLUDE: SKILL.md Phase 1 재작성 (환경 감지 → 프로젝트 세션 스캔), 출력 포맷 업데이트, references 파일 도구명 필드 업데이트
- EXCLUDE: Phase 2/3 프로세스 로직 변경, 설치 스크립트 변경, 디렉토리 구조 변경
