#!/bin/bash

# write-post installer for Mac/Linux - Multi-tool support

REPO_URL="https://raw.githubusercontent.com/daht-mad/write-post/main"

# Step 1: Select scope (global or project)
echo "설치 위치를 선택하세요:"
echo "1) 전역 설치 (모든 프로젝트에서 사용)"
echo "2) 프로젝트 설치 (현재 폴더에서만 사용)"
read -p "선택 (1/2): " scope_choice </dev/tty

if [ "$scope_choice" = "1" ]; then
    SCOPE="global"
    SCOPE_LABEL="전역"
else
    SCOPE="project"
    SCOPE_LABEL="프로젝트"
fi

# Step 2: Select tools
echo ""
echo "어떤 도구에 설치할까요?"
echo "1) Claude Code"
echo "2) OpenCode"
echo "3) Codex CLI"
echo "4) Gemini CLI"
echo "5) Antigravity"
echo "6) 전체"
read -p "선택 (1-6, 쉼표로 구분 가능): " tool_choice </dev/tty

# Parse tool selections
declare -a TOOLS_TO_INSTALL
if [ "$tool_choice" = "6" ]; then
    TOOLS_TO_INSTALL=("claude" "opencode" "codex" "gemini" "antigravity")
else
    IFS=',' read -ra CHOICES <<< "$tool_choice"
    for choice in "${CHOICES[@]}"; do
        choice=$(echo "$choice" | xargs)
        case $choice in
            1) TOOLS_TO_INSTALL+=("claude") ;;
            2) TOOLS_TO_INSTALL+=("opencode") ;;
            3) TOOLS_TO_INSTALL+=("codex") ;;
            4) TOOLS_TO_INSTALL+=("gemini") ;;
            5) TOOLS_TO_INSTALL+=("antigravity") ;;
        esac
    done
fi

# Function to install a tool
install_tool() {
    local tool=$1
    local scope=$2
    local installed_tools=$3
    
    case $tool in
        "claude")
            if [ "$scope" = "global" ]; then
                TARGET_DIR="$HOME/.claude/skills/write-post"
            else
                TARGET_DIR=".claude/skills/write-post"
            fi
            mkdir -p "$TARGET_DIR"
            
            # Download SKILL.md (with error handling)
            if ! curl -fsSL "$REPO_URL/.claude/skills/write-post/SKILL.md" -o "$TARGET_DIR/SKILL.md"; then
                echo "ERROR: Failed to download SKILL.md for claude" >&2
                exit 1
            fi
            
            # Create references directory
            mkdir -p "$TARGET_DIR/references"
            
            # Download template (with warning on failure)
            if ! curl -fsSL "$REPO_URL/.claude/skills/write-post/references/case-study-template.md" -o "$TARGET_DIR/references/case-study-template.md"; then
                echo "WARNING: Failed to download references/case-study-template.md (Phase 3 template won't work)" >&2
            fi
            
            echo "✓ Claude Code: $TARGET_DIR/SKILL.md + references/"
            ;;
        "opencode")
            if [ "$scope" = "global" ]; then
                TARGET_DIR="$HOME/.config/opencode/skills/write-post"
            else
                TARGET_DIR=".opencode/skills/write-post"
            fi
            mkdir -p "$TARGET_DIR"
            
            # Download SKILL.md (with error handling)
            if ! curl -fsSL "$REPO_URL/.claude/skills/write-post/SKILL.md" -o "$TARGET_DIR/SKILL.md"; then
                echo "ERROR: Failed to download SKILL.md for opencode" >&2
                exit 1
            fi
            
            # Create references directory
            mkdir -p "$TARGET_DIR/references"
            
            # Download template (with warning on failure)
            if ! curl -fsSL "$REPO_URL/.claude/skills/write-post/references/case-study-template.md" -o "$TARGET_DIR/references/case-study-template.md"; then
                echo "WARNING: Failed to download references/case-study-template.md (Phase 3 template won't work)" >&2
            fi
            
            echo "✓ OpenCode: $TARGET_DIR/SKILL.md + references/"
            ;;
        "codex")
            if [ "$scope" = "global" ]; then
                TARGET_DIR="$HOME/.codex/skills/write-post"
            else
                TARGET_DIR=".codex/skills/write-post"
            fi
            mkdir -p "$TARGET_DIR"
            
            # Download SKILL.md (with error handling)
            if ! curl -fsSL "$REPO_URL/.claude/skills/write-post/SKILL.md" -o "$TARGET_DIR/SKILL.md"; then
                echo "ERROR: Failed to download SKILL.md for codex" >&2
                exit 1
            fi
            
            # Create references directory
            mkdir -p "$TARGET_DIR/references"
            
            # Download template (with warning on failure)
            if ! curl -fsSL "$REPO_URL/.claude/skills/write-post/references/case-study-template.md" -o "$TARGET_DIR/references/case-study-template.md"; then
                echo "WARNING: Failed to download references/case-study-template.md (Phase 3 template won't work)" >&2
            fi
            
            echo "✓ Codex CLI: $TARGET_DIR/SKILL.md + references/"
            ;;
        "gemini")
            if [ "$scope" = "global" ]; then
                TARGET_DIR="$HOME/.gemini/skills/write-post"
            else
                TARGET_DIR=".gemini/skills/write-post"
            fi
            mkdir -p "$TARGET_DIR"
            
            # Download SKILL.md (with error handling)
            if ! curl -fsSL "$REPO_URL/.claude/skills/write-post/SKILL.md" -o "$TARGET_DIR/SKILL.md"; then
                echo "ERROR: Failed to download SKILL.md for gemini" >&2
                exit 1
            fi
            
            # Create references directory
            mkdir -p "$TARGET_DIR/references"
            
            # Download template (with warning on failure)
            if ! curl -fsSL "$REPO_URL/.claude/skills/write-post/references/case-study-template.md" -o "$TARGET_DIR/references/case-study-template.md"; then
                echo "WARNING: Failed to download references/case-study-template.md (Phase 3 template won't work)" >&2
            fi
            
            echo "✓ Gemini CLI: $TARGET_DIR/SKILL.md + references/"
            ;;
        "antigravity")
            if [ "$scope" = "global" ]; then
                TARGET_DIR="$HOME/.gemini/antigravity/skills/write-post"
            else
                TARGET_DIR=".agent/skills/write-post"
            fi
            mkdir -p "$TARGET_DIR"
            
            # Download SKILL.md (with error handling)
            if ! curl -fsSL "$REPO_URL/.claude/skills/write-post/SKILL.md" -o "$TARGET_DIR/SKILL.md"; then
                echo "ERROR: Failed to download SKILL.md for antigravity" >&2
                exit 1
            fi
            
            # Create references directory
            mkdir -p "$TARGET_DIR/references"
            
            # Download template (with warning on failure)
            if ! curl -fsSL "$REPO_URL/.claude/skills/write-post/references/case-study-template.md" -o "$TARGET_DIR/references/case-study-template.md"; then
                echo "WARNING: Failed to download references/case-study-template.md (Phase 3 template won't work)" >&2
            fi
            
            echo "✓ Antigravity: $TARGET_DIR/SKILL.md + references/"
            ;;
    esac
}

# Step 3: Install selected tools
echo ""
echo "설치 중..."
for tool in "${TOOLS_TO_INSTALL[@]}"; do
    install_tool "$tool" "$SCOPE"
done

# Cleanup: Remove old installation paths
if [ "$SCOPE" = "global" ]; then
    [ -f "$HOME/.claude/commands/write-post.md" ] && rm "$HOME/.claude/commands/write-post.md" && echo "  (Cleaned up old file: ~/.claude/commands/write-post.md)"
else
    [ -f ".claude/commands/write-post.md" ] && rm ".claude/commands/write-post.md" && echo "  (Cleaned up old file: .claude/commands/write-post.md)"
fi

# Step 4: Show completion message
echo ""
echo "write-post $SCOPE_LABEL 설치 완료!"
echo "설치된 도구: $(IFS=', '; echo "${TOOLS_TO_INSTALL[*]}")"
echo "사용법: /write-post"
