Create a simple git commit for the current staged changes.

Requirements:
- Write a concise commit message (1 line, max 72 chars)
- Do NOT include "Generated with Claude Code" footer
- Do NOT include "Co-Authored-By" footer
- Keep description simple if needed (1-2 lines max)
- Use imperative mood (e.g., "Fix bug" not "Fixed bug")

Steps:
1. Run `git diff --staged` to see what's being committed
2. Propose a commit message for user approval
3. After approval, run the commit command
