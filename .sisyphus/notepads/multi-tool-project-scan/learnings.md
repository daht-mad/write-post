# Learnings - multi-tool-project-scan

## [2026-01-26T08:41:15Z] Initial Context

### Plan Objective
Convert write-post skill from "single tool detection" to "project-level multi-tool scanning" to aggregate sessions from all AI coding tools used on a project.

### Current State (single tool detection)
- Phase 1 uses priority-based detection (OpenCode → Claude Code → Antigravity → Codex CLI → Gemini CLI)
- Stops at first match
- Other tools' sessions are ignored

### Target State (multi-tool project scan)
- Scan ALL 5 tools' session paths
- Match sessions to current project path
- Merge all matched sessions into unified DEVLOG
- Display actual tool name per work section (e.g., "**Claude Code 작업:**", "**OpenCode 작업:**")

### Key Changes Required
1. "환경 감지" (Environment Detection) → "프로젝트 세션 스캔" (Project Session Scan)
2. Add "프로젝트 매칭" method to each tool's parsing guide (5 tools)
3. DEVLOG header: tool-neutral "AI 코딩 도구와 함께..."
4. Output format: dynamic tool name per section
5. Incremental write: filter all tools by date
6. Phase 3: "Claude" → "AI" (2 lines)
7. Template: multi-tool support in tool name field

### Constraints
- SKILL.md must stay under 300 lines
- Phase 2 completely frozen (no changes)
- Phase 3 frozen except "Claude" → "AI" (2 lines)
- No structural changes to output format
- No changes to cleanup rules (lines 131-158)

## [2026-01-26T08:45:00Z] Task 1 Complete

### Changes Made
1. **Line 14**: "현재 도구 환경을 감지하고" → "사용 가능한 모든 AI 코딩 도구의 세션을 프로젝트 단위로 스캔하고"
2. **Lines 16-29**: "환경 감지" → "프로젝트 세션 스캔" (complete section rewrite)
   - Changed from priority-based detection to full scan
   - Added scan result handling (show found tools, handle zero matches)
3. **Line 36**: "{도구명}와 함께" → "AI 코딩 도구와 함께"
4. **Lines 48, 61**: "{도구명} 작업:" → "{해당 작업의 도구명} 작업:"
5. **Line 88**: Added multi-tool reference note
6. **Line 95**: "세션 파일에서" → "**모든 감지된 도구의** 세션 파일에서"
7. **Lines 103, 109, 121, 128, 135**: Added "프로젝트 매칭" to all 5 tools
8. **Lines 152-158**: Updated 구조화 규칙 with multi-tool merge instructions

### Verification Results
- ✅ Line count: 266 (under 300 limit)
- ✅ "프로젝트 세션 스캔" exists (line 16)
- ✅ "환경 감지" removed (0 occurrences)
- ✅ "프로젝트 매칭" count: 6 (5 tools + 1 in OpenCode 2차 방법)
- ✅ "AI 코딩 도구와 함께" exists (line 36)
- ✅ Phase 2 unchanged (lines 175-203)
- ✅ Phase 3 unchanged (lines 205-266, "Claude" still present for Task 2)

### Project Matching Patterns Documented
- Claude Code: Path encoding with `-` replacement
- OpenCode: MCP auto-filter or `directory` field match
- Codex CLI: `cwd`/`working_directory` field (best-effort)
- Gemini CLI: Content search in hash directories (best-effort)
- Antigravity: code_tracker directory name or brain artifact `file:///` links

## [2026-01-26T08:47:00Z] Task 2 Complete

### Changes Made
- Line 225: "Claude와 협업하면서" → "AI와 협업하면서"
- Line 226: "Claude가 잘 못 이해한 것" → "AI가 잘 못 이해한 것"

### Verification
- ✅ "Claude와 협업" removed (0 occurrences)
- ✅ "Claude가 잘" removed (0 occurrences)
- ✅ "AI와 협업" exists (line 225)
- ✅ "AI가 잘" exists (line 226)
- ✅ Exactly 2 lines changed

## [2026-01-26T08:48:00Z] Task 3 Complete

### Changes Made
- Line 29: "(예: Claude Code)" → "(예: Claude Code, OpenCode — 여러 도구 사용 시 모두 나열)"

### Verification
- ✅ "여러 도구 사용 시" exists in template
- ✅ Exactly 1 line changed
- ✅ Multi-tool example provided

## [2026-01-26T08:50:00Z] Task 4 Complete - All Verification Passed

### Final Verification Results
- ✅ SKILL.md line count: 266 (under 300 limit)
- ✅ "프로젝트 세션 스캔" exists: 1 occurrence
- ✅ "환경 감지" removed: 0 occurrences
- ✅ "프로젝트 매칭" count: 6 (5 tools + OpenCode raw)
- ✅ "AI 코딩 도구와 함께" exists
- ✅ "Claude와 협업|Claude가 잘" removed: 0 occurrences
- ✅ Template "여러 도구 사용 시" exists
- ✅ Phase 2 completely unchanged
- ✅ Phase 3 minimal changes (2 lines only)

### Commit Details
- Commit: dc27cbb
- Message: feat(skill): add multi-tool project-level session scanning
- Files: SKILL.md (+30, -16), case-study-template.md (+1, -1)
- Total: 2 files changed, 30 insertions(+), 16 deletions(-)

### Plan Completion
All 4 tasks completed successfully:
1. ✅ Phase 1 multi-tool project scan rewrite
2. ✅ Phase 3 "Claude" → "AI" (2 lines)
3. ✅ Template multi-tool support (1 line)
4. ✅ Content verification + commit
