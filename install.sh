#!/bin/bash

set -e

REPO_URL="https://raw.githubusercontent.com/BowTiedSwan/rlm-skill/main/SKILL.md"
CLAUDE_DIR="$HOME/.claude/skills"
SKILL_DIR="$CLAUDE_DIR/rlm"
SKILL_FILE="$SKILL_DIR/SKILL.md"

GREEN='\033[0;32m'
GRAY='\033[0;90m'
NC='\033[0m'

echo ""
echo -e "${GRAY}Detecting environment...${NC}"

if [ -d "$HOME/.claude" ]; then
    echo -e "${GREEN}✓ Claude Code detected${NC}"
    mkdir -p "$SKILL_DIR"
    
    echo -e "${GRAY}Downloading skill...${NC}"
    curl -sSL "$REPO_URL" -o "$SKILL_FILE"
    
    echo ""
    echo -e "${GREEN}> /rlm installed successfully${NC}"
    echo -e "${GRAY}  Location: $SKILL_FILE${NC}"
    echo ""
    exit 0
else
    echo "Claude Code directory (~/.claude) not found."
    echo "Creating standard directory anyway..."
    mkdir -p "$SKILL_DIR"
    curl -sSL "$REPO_URL" -o "$SKILL_FILE"
    echo -e "${GREEN}> /rlm installed${NC}"
    exit 0
fi
