# Decisions - multi-agent-write-post

## [2026-01-26T07:04:25Z] Architecture Decisions

### Environment Detection Order
1. OpenCode (MCP tool availability check)
2. Claude Code (~/.claude/projects/ existence)
3. Antigravity (~/.gemini/antigravity/brain/ existence)
4. Codex CLI (~/.codex/sessions/ existence)
5. Gemini CLI (~/.gemini/tmp/ existence)
6. Fallback: Ask user directly

### Antigravity Artifact Fallback Chain
walkthrough.md → implementation_plan.md → task.md
(Some conversations lack walkthrough.md - verified in real data)

### OpenCode Primary Method
Use MCP session tools first (session_list, session_read, session_search)
Raw file parsing as fallback only

### Installation Strategy
- Claude Code: Keep original write-post.md (no frontmatter)
- Other tools: Add YAML frontmatter, save as SKILL.md
- Single source file + frontmatter injection at install time

## [2026-01-26T07:15:00Z] Windows PowerShell Installer Implementation

### Tool Selection Menu
- 5 tools + "All" option (6 total)
- Supports comma-separated selections (e.g., "1,3,5")
- Uses [Console]::ReadLine() for iwr | iex compatibility

### Windows Paths (Backslashes)
| Tool | Global | Project |
|------|--------|---------|
| Claude Code | `$env:USERPROFILE\.claude\commands` | `.claude\commands` |
| OpenCode | `$env:USERPROFILE\.config\opencode\skills\write-post` | `.opencode\skills\write-post` |
| Codex CLI | `$env:USERPROFILE\.codex\skills\write-post` | `.codex\skills\write-post` |
| Gemini CLI | `$env:USERPROFILE\.gemini\skills\write-post` | `.gemini\skills\write-post` |
| Antigravity | `$env:USERPROFILE\.gemini\antigravity\skills\write-post` | `.agent\skills\write-post` |

### File Naming Convention
- Claude Code: `write-post.md` (no frontmatter)
- Other tools: `SKILL.md` (with YAML frontmatter)

### Frontmatter Format
```yaml
---
name: write-post
description: DEVLOG 생성부터 AI 활용 사례 게시글 작성까지 한 번에 진행합니다. AI 코딩 도구의 대화 세션을 자동으로 파싱하여 개발 로그를 만들고, 비개발자 대상 사례글까지 작성합니다.
---
```

### Installation Function
- Single `Install-Tool` function handles all 5 tools
- Frontmatter injected at install time (not in source file)
- Uses `Out-File -Encoding UTF8` for proper encoding
- Supports both global and project scope

### iwr | iex Compatibility
- No interactive features beyond [Console]::ReadLine()
- All paths use backslashes (Windows native)
- No external dependencies
- Proper error handling with Out-Null for directory creation
