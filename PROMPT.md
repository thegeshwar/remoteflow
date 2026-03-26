# RemoteFlow — Ralph Loop Prompt (Phase 3b — Mac)

You are the lead developer of RemoteFlow, a Flutter SSH client.

## FIRST: Set Working Directory and Read Context
```bash
cd ~/remoteflow
```
Read `~/remoteflow/CLAUDE.md` for full project context, compliance rules, and coding standards. This file is your bible — every line of code must follow its rules.

Also read `~/remoteflow/SESSION_CONTEXT.md` for state from previous iterations.

## Your Mission

Complete Phase 3b — the Mac-dependent issues that were blocked until now. Work through GitHub issues one at a time. Each iteration: pick the next ready issue, implement it fully with tests, commit, close it, and move on.

All commands below run from `~/remoteflow/`.

## Iteration Protocol

Every time you receive this prompt, execute these steps IN ORDER:

### Step 1: Assess State
```bash
cd ~/remoteflow
gh issue list --repo thegeshwar/remoteflow --state open --json number,title,labels,body --limit 50
git log --oneline -10
```

### Step 2: Select Next Issue
1. Filter to issues labeled `needs-mac` or `phase-3b` ONLY (all other phases are done)
2. For each issue, read its body for "Depends on" line. Check if ALL dependency issues are closed:
   ```bash
   gh issue view <dep-number> --repo thegeshwar/remoteflow --json state
   ```
3. Pick the FIRST issue (lowest number) whose dependencies are ALL closed
4. If no issue is ready, output: `<promise>MVP COMPLETE</promise>`

### Step 3: Implement
1. Ensure you are in `~/remoteflow`
2. Create a feature branch: `git checkout -b feature/f-XX-short-name`
3. Read the issue body carefully — it contains specific tasks and acceptance criteria
4. Implement the feature following CLAUDE.md compliance rules
5. Write tests for all new code
6. Commit frequently with: `type: description (refs #XX)`

### Step 4: Quality Gates
Before closing the issue, ALL of these must pass:
```bash
cd ~/remoteflow
flutter test
flutter analyze
```
For iOS/macOS specific issues, also verify:
```bash
cd ~/remoteflow/ios && pod install
flutter build ios --no-codesign
flutter build macos
```
- Zero test failures
- Zero analyze errors
- All public methods have dartdoc comments
- No magic numbers — constants in `lib/constants.dart`
- No hardcoded hex colors in widgets — use `Theme.of(context).colorScheme`
- Credentials NEVER stored in plain Hive — only `flutter_secure_storage`

### Step 5: Close and Clean Up
```bash
cd ~/remoteflow
git add -A && git commit -m "feat: <description> (closes #XX)"
git checkout main && git merge feature/f-XX-short-name
git push origin main
gh issue close XX --repo thegeshwar/remoteflow
```

### Step 6: Update Context
Update `SESSION_CONTEXT.md` with: what was just completed, what issue is next, any blockers or decisions made.

```bash
cd ~/remoteflow
git add SESSION_CONTEXT.md && git commit -m "docs: update session context" && git push origin main
```

### Step 7: Check Completion
```bash
OPEN=$(gh issue list --repo thegeshwar/remoteflow --state open --json number --jq 'length')
```
If `$OPEN` equals 0: ALL issues are done. Output:
```
<promise>MVP COMPLETE</promise>
```
Otherwise, this iteration is done. The loop will feed you this prompt again for the next issue.

## Key Rules
- ONE issue per iteration. Do not try to do multiple issues at once.
- Read the issue body — it has the specific tasks and acceptance criteria.
- Read and follow `~/remoteflow/CLAUDE.md` compliance rules on EVERY line of code you write.
- If `flutter test` or `flutter analyze` fails, fix it BEFORE closing the issue.
- If you get stuck on an issue after 3 attempts, add a comment to the issue explaining the blocker and move to the next ready issue.
- Push all work. Never leave uncommitted changes.
- This is running on macOS (Apple Silicon). Flutter SDK should be on PATH. Use `which flutter` to verify.
- For Xcode signing, use free Apple ID (personal team) for development builds.
