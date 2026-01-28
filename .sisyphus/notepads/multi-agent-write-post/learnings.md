# Learnings - multi-agent-write-post

## [2026-01-26T07:04:25Z] Initial Context

### Existing Structure
- Current write-post.md is Claude Code only (354 lines)
- Phase 1 (lines 13-120): Session parsing section
- Phase 2 (lines 123-151): DEVLOG confirmation
- Phase 3 (lines 153-354): Case study writing
- Korean language throughout

### Multi-Agent Session Storage Patterns
**Claude Code**:
- Location: `~/.claude/projects/{path-with-dashes}/`
- Format: `.jsonl` files (agent-*.jsonl excluded)
- Parsing: `type: 'user'` / `type: 'assistant'`

**OpenCode**:
- Primary: MCP tools (session_list, session_read, session_search)
- Fallback: `~/.local/share/opencode/storage/` (session/message/part 3-tier JSON)
- Windows: `%USERPROFILE%\.local\share\opencode\storage\`

**Codex CLI**:
- Location: `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl`
- Format: JSONL with user messages, AI responses, tool calls, file changes, token stats
- Date-based folder structure

**Gemini CLI**:
- Auto-save: `~/.gemini/tmp/<project_hash>/chats/`
- Manual save: `~/.gemini/tmp/<project_hash>/checkpoints/` (via `/chat save <tag>`)
- Format: JSON (role: user/model, parts: content)

**Antigravity**:
- Location: `~/.gemini/antigravity/brain/<conversation-id>/`
- ⚠️ conversations/ .pb files are encrypted (Google keys required)
- Readable artifacts: walkthrough.md → implementation_plan.md → task.md (fallback chain)
- .metadata.json for summary/updatedAt
- .resolved, .resolved.N are version history (use latest)

### Verified Paths
- Antigravity brain exists: `~/.gemini/antigravity/brain/` (50 conversations)
- OpenCode storage exists: `~/.local/share/opencode/storage/`
- Example brain folder: 8a17b84e-2e3f-479c-9a91-44aafae5fc61 (has implementation_plan.md, task.md, NO walkthrough.md)

### Key Constraints
- Phase 2/3 must remain unchanged (except tool name parameterization in Task 2)
- Maintain Korean language consistency
- Preserve existing Claude Code functionality (backward compatibility)
- No code/script files (markdown instructions only)

## [2026-01-26T07:15:00Z] Task 1: Phase 1 Multi-Agent Update

### Changes Made
- Added environment detection section (6-step priority order)
- Created 5 tool-specific parsing subsections (Claude Code, OpenCode, Codex CLI, Gemini CLI, Antigravity)
- Updated common cleanup rules with tool-specific metadata filters
- Parameterized output template with {도구명} for multi-agent support

### Structure
- Environment detection: Lines 17-26
- Output template: Lines 28-83
- Tool-specific parsing: Lines 95-130
- Common cleanup: Lines 132-158

### Key Decisions
- OpenCode: MCP tools as primary method, raw parsing as fallback
- Antigravity: walkthrough.md → implementation_plan.md → task.md fallback chain
- Environment detection: OpenCode first (MCP tool check), then folder existence checks
- Preserved existing Claude Code logic while expanding to other tools

## [2026-01-26T07:20:00Z] Task 2: Phase 2/3 Tool Name Parameterization

### Changes Made
- Line 176: "Claude 작업 비개발자화" → "AI 작업 비개발자화"
- Line 364: "Claude 작업 내용은 구체적으로" → "AI 작업 내용은 구체적으로"

### Verification
- Total changes: 2 lines
- Phase 2/3 logic: Unchanged
- Examples and structure: Preserved

## [2026-01-26T08:30:00Z] Final Verification Complete

### All Checkboxes Verified
- ✅ Definition of Done (4/4): All criteria met
- ✅ Final Checklist (5/5): All verification items passed

### Verification Evidence
**Must Have Items**:
- 5개 도구 세션 파싱: Claude Code (4회), OpenCode (3회), Codex CLI (3회), Gemini CLI (3회), Antigravity (3회)
- 환경 감지: 6단계 우선순위 (lines 16-26)
- Fallback: 사용자 질문 메커니즘 포함
- 설치 스크립트: Mac/Windows 모두 5개 도구 선택 메뉴
- 하위 호환성: Claude Code 파싱 로직 완전 보존

**Must NOT Have Guardrails**:
- ✅ Cursor 미지원 (5개 도구만)
- ✅ 크로스 도구 파싱 없음
- ✅ Antigravity .pb 파싱 시도 없음
- ✅ DEVLOG 구조 유지
- ✅ Phase 2/3 로직 동결 (2줄 파라미터화만)

### File Locations
- Skill: `.claude/skills/write-post/SKILL.md` (252 lines)
- Mac Installer: `install_mac.sh` (bash syntax verified)
- Windows Installer: `install_win.ps1`
- Documentation: `README.md`

### Plan Status
- Total tasks: 5 (all complete)
- Total checkboxes: 14 (all verified and marked)
- Plan completion: 100%
