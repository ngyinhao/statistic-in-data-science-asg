# Git index lock permission denied in managed workspace

## Context and intended action

While preparing a user-requested commit, `git add --all` was run from the repository root to stage the complete working-tree update.

## Observable symptom

Git failed before staging any paths:

```text
fatal: Unable to create '<repository>/.git/index.lock': Permission denied
```

## Impact

No files could be staged, so committing and pushing could not continue inside the default filesystem sandbox.

## Cause

The managed workspace grants read access to the repository's `.git` directory but does not grant write access there. Git needs to create `.git/index.lock` for index mutations.

## Troubleshooting and result

- Confirmed the working tree remained unstaged with `git status --short` after the failure.
- The application files themselves remained writable; the restriction was isolated to Git metadata.
- The blocker recurred when committing the completed report revision; `git diff --cached --check` and `git commit` could not proceed because staging never created the index lock.

## Workaround

Retry Git metadata-changing commands through the environment's approved escalation mechanism. Keep the command scoped to the active repository and the exact requested Git action.

## Future prevention

- Expect `git add`, `git commit`, and potentially other metadata-changing Git operations to require escalation in this workspace profile.
- Perform read-only inspection first, then group the minimum necessary Git mutation commands into narrowly scoped escalation requests.
