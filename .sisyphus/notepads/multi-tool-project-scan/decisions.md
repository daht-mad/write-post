# Decisions - multi-tool-project-scan

## [2026-01-26T08:41:15Z] Architecture Decisions

### Project Matching Strategy by Tool

**Claude Code**: 
- Path encoding: `/Users/dahye/DEV/my-app` → `~/.claude/projects/-Users-dahye-DEV-my-app/`

**OpenCode**:
- MCP `session_list`: auto-filters by current project
- Raw parsing: `ses_*.json` → `directory` field match

**Codex CLI** (best-effort):
- JSONL → `cwd` or `working_directory` field match
- If no field: ask user confirmation

**Gemini CLI** (best-effort):
- `~/.gemini/tmp/{hash}/` → search project path in chat content
- Uncertain match: ask user

**Antigravity**:
- `code_tracker/active/{project-name}_{hash}/` → directory name match
- OR `brain/*/task.md.resolved` → `file:///` link match

### Output Format Strategy
- DEVLOG header: tool-neutral (no specific tool name)
- Work section headers: dynamic per-section tool name
- Same-day multi-tool: group by tool within date

### Timestamp Handling
- Different formats (ISO 8601, epoch ms, artifact-level)
- Solution: Date-level grouping (YYYY-MM-DD)
- Time order preserved within each tool only
