## [2026-01-26] Architectural Decisions

### Decision: Directory Structure Over Single File
**Rationale**: skill-creator guidelines recommend Progressive Disclosure for files >300 lines
**Trade-off**: Slightly more complex installation (2 files vs 1) for better context efficiency
**Result**: 36% context reduction for common operations (Phase 1/2)

### Decision: Unified SKILL.md for All Tools
**Rationale**: Avoid maintenance burden of 5 separate files with frontmatter variations
**Implementation**: SKILL.md includes frontmatter, install scripts download directly
**Benefit**: Single source of truth, no sed/string manipulation needed

### Decision: Redirect Stub Instead of Deletion
**Rationale**: Users with old installations would get 404 errors
**Implementation**: Replace old file with migration instructions
**Benefit**: Graceful upgrade path, clear communication

### Decision: Cleanup in Install Scripts
**Rationale**: Users upgrading from old version need old files removed
**Implementation**: Check and remove old paths after successful installation
**Benefit**: Prevents confusion from duplicate installations

### Decision: Differential Error Handling
**Rationale**: SKILL.md is critical, references is optional (only for Phase 3)
**Implementation**: SKILL.md failure = exit 1, references failure = warn + continue
**Benefit**: Partial functionality better than complete failure
