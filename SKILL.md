---
name: rlm
description: Process large codebases (>100 files) using the Recursive Language Model pattern. Treats code as an external environment, using parallel background agents to map-reduce complex tasks without context rot.
triggers:
  - "analyze codebase"
  - "scan all files"
  - "large repository"
  - "RLM"
  - "find usage of X across the project"
---

# Recursive Language Model (RLM) Skill

## Core Philosophy
**"Context is an external resource, not a local variable."**

When this skill is active, you are the **Root Node** of a Recursive Language Model system. Your job is NOT to read code, but to write programs (plans) that orchestrate sub-agents to read code.

## Protocol: The RLM Loop

### Phase 1: Index & Filter (The "Peeking" Phase)
**Goal**: Identify relevant data without loading it.
1.  **Map the Territory**: Use `find`, `ls -R`, or `tree` to understand structure.
2.  **Code-First Search**: Use `grep`, `ripgrep` (if available), or `ast-grep` to find *candidates*.
    *   *Anti-Pattern*: Reading file contents to check if they are relevant.
    *   *RLM Pattern*: Grepping for import statements, class names, or definitions to build a list of relevant paths.

### Phase 2: Parallel Map (The "Sub-Query" Phase)
**Goal**: Process chunks in parallel using fresh contexts.
1.  **Divide**: Split the work into atomic units (e.g., "Analyze file A", "Check class B").
2.  **Spawn**: Use `background_task` to launch parallel agents.
    *   *Constraint*: Launch at least 3-5 agents in parallel for broad tasks.
    *   *Prompting*: Give each background agent ONE specific file path and ONE specific question.
    *   *Format*: `background_task(agent="explore", prompt="Read <filepath>. Analyze <specific_question>. Return findings in JSON format.")`

### Phase 3: Reduce & Synthesize (The "Aggregation" Phase)
**Goal**: Combine results into a coherent answer.
1.  **Collect**: Read the outputs from `background_task` (via `background_output`).
2.  **Synthesize**: Look for patterns, consensus, or specific answers in the aggregated data.
3.  **Refine**: If the answer is incomplete, perform a second RLM recursion on the specific missing pieces.

## Critical Instructions

1.  **NEVER** use `cat *` or read more than 3-5 files into your main context at once.
2.  **ALWAYS** prefer `background_task` for reading/analyzing file contents when the file count > 1.
3.  **ALWAYS** structure background agent prompts to return structured data (e.g., "List the functions found," "Return TRUE/FALSE if vulnerable").
4.  **Python is your Memory**: If you need to track state across 50 files, write a Python script to scan them and output a summary, rather than reading them yourself.

## Example Workflow: "Find all API endpoints and check for Auth"

**Wrong Way (Monolithic)**:
- `read src/api/routes.ts`
- `read src/api/users.ts`
- ... (Context fills up, reasoning degrades)

**RLM Way (Recursive)**:
1.  **Filter**: `grep -l "@Controller" src/**/*.ts` -> Returns 20 files.
2.  **Map**: 
    - `background_task(prompt="Read src/api/routes.ts. Extract all endpoints and their @Auth decorators.")`
    - `background_task(prompt="Read src/api/users.ts. Extract all endpoints and their @Auth decorators.")`
    - ... (Launch all 20)
3.  **Reduce**: 
    - Collect all 20 outputs.
    - Compile into a single table.
    - Identify missing auth.

## Recovery Mode
If `background_task` is unavailable or fails:
1.  Fall back to **Iterative Python Scripting**.
2.  Write a Python script that loads each file, runs a regex/AST check, and prints the result to stdout.
3.  Read the script's stdout.
