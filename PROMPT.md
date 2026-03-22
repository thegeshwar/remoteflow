# RemoteFlow — Ralph Loop Prompt

You are the lead developer of RemoteFlow, a Flutter SSH client. Read CLAUDE.md for full project context, compliance rules, and coding standards.

## Your Mission

Build the RemoteFlow MVP by working through GitHub issues one at a time. Each iteration of this loop, you pick the next ready issue, implement it fully with tests, commit, close it, and move on.

## Iteration Protocol

Every time you receive this prompt, execute these steps IN ORDER:

### Step 1: Assess State
```bash
gh issue list --repo thegeshwar/remoteflow --state open --json number,title,labels,body --limit 50
```
Also check: `git log --oneline -10` and read `SESSION_CONTEXT.md` for context from previous iterations.

### Step 2: Select Next Issue
1. Filter out any issue labeled `needs-mac`
2. Sort remaining by phase priority: `phase-1` first, then `phase-2`, then `phase-3a`
3. For each issue, read its body for "Depends on" line. Check if ALL dependency issues are closed:
   ```bash
   gh issue view <dep-number> --repo thegeshwar/remoteflow --json state
   ```
4. Pick the FIRST issue (lowest phase, lowest number) whose dependencies are ALL closed
5. If no issue is ready, output: `<promise>MVP COMPLETE</promise>`

### Step 3: Implement
1. Create a feature branch: `git checkout -b feature/f-XX-short-name`
2. Read the issue body carefully — it contains specific tasks and acceptance criteria
3. Implement the feature following CLAUDE.md compliance rules
4. Write tests for all new code
5. Commit frequently with: `type: description (refs #XX)`

### Step 4: Quality Gates
Before closing the issue, ALL of these must pass:
```bash
flutter test
flutter analyze
```
- Zero test failures
- Zero analyze errors
- All public methods have dartdoc comments
- No magic numbers — constants in `lib/constants.dart`
- No hardcoded hex colors in widgets — use `Theme.of(context).colorScheme`
- Credentials NEVER stored in plain Hive — only `flutter_secure_storage`

### Step 5: Close and Clean Up
```bash
git add -A && git commit -m "feat: <description> (closes #XX)"
git checkout main && git merge feature/f-XX-short-name
git push origin main
gh issue close XX --repo thegeshwar/remoteflow
```

### Step 6: Update Context
Update `SESSION_CONTEXT.md` with: what was just completed, what issue is next, any blockers or decisions made.

```bash
git add SESSION_CONTEXT.md && git commit -m "docs: update session context" && git push origin main
```

### Step 7: Check Completion
```bash
OPEN=$(gh issue list --repo thegeshwar/remoteflow --state open --json labels --jq '[.[] | select(.labels[].name != "needs-mac")] | length')
```
If `$OPEN` equals 0: all non-Mac issues are done. Output:
```
<promise>MVP COMPLETE</promise>
```
Otherwise, this iteration is done. The loop will feed you this prompt again for the next issue.

## Key Rules
- ONE issue per iteration. Do not try to do multiple issues at once.
- Read the issue body — it has the specific tasks and acceptance criteria.
- Follow CLAUDE.md compliance rules on EVERY line of code you write.
- If `flutter test` or `flutter analyze` fails, fix it BEFORE closing the issue.
- If you get stuck on an issue after 3 attempts, add a comment to the issue explaining the blocker and move to the next ready issue.
- Push all work. Never leave uncommitted changes.
