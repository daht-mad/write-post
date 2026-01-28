## [2026-01-26] write-post Skill Restructure

### Progressive Disclosure Pattern
- Split 392-line monolithic file into SKILL.md (252 lines) + references/ (145 lines)
- Template content moved to references/ - only loaded when Phase 3 step 4 is reached
- Achieved 36% context reduction for Phase 1/2 operations

### YAML Frontmatter
- All tools now use same SKILL.md with frontmatter already included
- No need for sed injection or string concatenation in install scripts
- Format: `---\nname: skill-name\ndescription: ...\n---`

### Install Script Patterns
- Download 2 files: SKILL.md + references/case-study-template.md
- Error handling: SKILL.md failure = exit 1, references failure = warn + continue
- Cleanup old installations: Check and remove old paths before success message
- Success messages: Show both files installed (e.g., "SKILL.md + references/")

### Backward Compatibility
- Keep redirect stub at old location with migration instructions
- Prevents 404 errors for users with old installations
- Stub includes reinstall commands for both platforms

### Multi-File Download Error Handling
- Critical file (SKILL.md) failure → abort entire installation
- Optional file (references) failure → warn but continue (Phase 1/2 still work)
- Prevents partial installations that silently fail

### Path Conventions
- All tools now use `skills/{skill-name}/` directory pattern
- Claude Code also moved from `commands/` to `skills/` for consistency
- Windows: Use backslashes, `$env:USERPROFILE`
- Mac/Linux: Use forward slashes, `$HOME`
