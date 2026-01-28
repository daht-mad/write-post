# Draft: write-post 스킬 구조적 개선

## Requirements (confirmed)
- skill-creator 가이드라인 기반 구조 개선
- 기존 기능 유지 (Phase 1/2/3)

## Analysis: Current vs skill-creator Best Practices

### Current State
- 단일 파일: `.claude/commands/write-post.md` (392줄)
- YAML frontmatter 없음 (Claude Code commands 형식)
- 모든 내용이 하나의 파일에 모놀리식으로 존재
- references/ 디렉토리 없음

### Identified Gaps
1. **Progressive Disclosure 미적용**: 392줄 전체가 스킬 로드 시 context에 올라감
2. **DEVLOG 템플릿 (55줄)**: context 낭비 - 필요할 때만 로드해야 함
3. **사례글 템플릿 + 작성 가이드 (~140줄)**: Phase 3 진입 시에만 필요
4. **도구별 세션 파싱**: 감지된 도구 하나만 필요한데 5개 전부 로드됨
5. **Phase 2 수정 예시**: 매번 필요하지 않을 수 있음

## Open Questions
- [ ] 배포 모델: 디렉토리 구조로 바꾸면 설치 스크립트 수정 필요
- [ ] Claude Code commands/ 호환성: 단일 파일 vs 디렉토리

## Technical Decisions
(pending interview)

## Scope Boundaries
- INCLUDE: SKILL.md 구조 개선, references/ 분리
- EXCLUDE: Phase 2/3 로직 변경, 새 기능 추가

## Technical Decisions (confirmed)
- **배포 모델**: 디렉토리 구조 전환 (SKILL.md + references/)
- **설치 스크립트**: 여러 파일 다운로드하도록 수정 필요

## Phase 3 분리 범위 (my recommendation)
- **추천**: "템플릿 + 작성 가이드만 분리"
- 이유:
  1. Phase 3 프로세스(질문 순서, 제목 선정 등)는 핵심 워크플로우 → SKILL.md에 유지
  2. 사례글 마크다운 템플릿(93줄)은 Phase 3 Step 4(초안 작성) 시에만 필요 → references/
  3. 작성 시 주의사항 + 마무리 안내(40줄)도 초안 작성 시에만 → references/
  4. skill-creator Pattern 3 "Conditional details" 정확히 적용

## Open Questions
- [ ] Claude Code 설치 경로: commands/ → skills/ 변경?
