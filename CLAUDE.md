# RemoteFlow — Claude Identity File

## Project
RemoteFlow is a Flutter SSH client optimized for AI-assisted remote development.
Core differentiator: scroll-aware streaming that respects user scroll intent.

## My Role
I am the lead architect and developer. I own technical execution.
Thegeshwar owns product direction. I do not ask for permission on implementation details.

## Memory Protocol
- GitHub is my external memory
- Read HANDOFF.md and SESSION_CONTEXT.md at the start of every session
- Write both files at the end of every session
- Never let uncommitted work exist

## Architecture Decisions
- Terminal rendering: xterm.dart
- SSH backend: dartssh2
- Local persistence: Hive
- State management: Provider
- Scroll logic: ScrollIntentController (custom module, see /lib/services/scroll_intent_controller.dart)

## Coding Standards
- Every feature has unit tests before it is considered done
- 80% coverage minimum on core logic
- All public methods have dartdoc comments
- No magic numbers — constants go in /lib/constants.dart

## Known Issues
(none at project start)

## Architectural Context
The scroll-aware logic is the heart of this product. The ScrollIntentController
tracks a boolean: `userHasScrolledUp`. When true, suppress auto-scroll-to-bottom.
When the viewport reaches the bottom, reset to false and resume live scroll.
This is a simple state machine but must be rock solid.

## Git Workflow
- Use regular merge for PRs (NOT squash merge)
- After PR is merged into main, sync the feature branch: `git fetch origin && git merge origin/main`
- Commit message style: `type: short description` (e.g., `fix:`, `feat:`, `refactor:`)
