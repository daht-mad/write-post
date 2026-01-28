# Issues - multi-agent-write-post

## [2026-01-26T07:04:25Z] Known Issues

### Antigravity Limitations
- conversations/ .pb files are encrypted (Protocol Buffers with Google encryption keys)
- Cannot parse .pb files - must use brain/ markdown artifacts only
- Not all conversations have walkthrough.md (confirmed in 8a17b84e-2e3f-479c-9a91-44aafae5fc61)

### Unverifiable Tools
- Codex CLI: Not installed on this machine (best-effort documentation-based instructions)
- Gemini CLI: Not installed on this machine (best-effort documentation-based instructions)

### Metadata Filtering Needed
- Claude Code: `<ide_opened_file>` and other IDE metadata
- OpenCode: System hooks/commands like `[search-mode]`, `<session-context>`
- Codex CLI: Token usage stats, internal tool call details
- Gemini CLI: Tool execution logs
- Antigravity: .metadata.json, .resolved files (parse artifacts only)
