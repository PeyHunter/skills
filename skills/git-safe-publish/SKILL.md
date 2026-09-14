---
name: git-safe-publish
description: Safely commit, synchronize, rebase, test, and push changes to a Git remote. Use when the user asks to commit and publish work, update a branch before pushing, or prepare a clean GitHub push; stop on conflicts, uncertain scope, failed verification, or risky branch conditions.
allowed-tools: Bash, Read, Grep, Glob
user-invocable: true
argument-hint: "[commit message or scope]"
---

# Git Safe Publish

Publish a deliberate set of local changes to a remote Git branch with evidence that the tree, history, tests, and remote state are understood. This skill changes repository state and can contact a remote; the user's explicit request to publish authorizes an ordinary push, but not an unsafe force-push, deletion, credential change, or unrelated cleanup.

## Non-negotiable rules

- Never use `git reset --hard`, `git clean -fd`, broad deletion, or an unreviewed force-push.
- Never stage unrelated changes merely to make the tree clean. Inspect and scope the files first.
- Never rewrite `main`, `master`, a protected branch, or a shared branch without explicit authorization.
- Prefer `git push --force-with-lease` only after a rebase on a non-protected branch and only when the user authorized the history rewrite.
- Do not resolve semantic conflicts by guessing. Mechanical conflict resolution may be proposed, but the result must be inspected and verified before continuing.
- A successful local command is not proof that the remote contains the intended commit. Verify the remote after pushing.
- If a step fails, leave the repository in a recoverable state and report the exact state and next action.

## Required outcome

At the end, report:

- repository root, branch, remote, and upstream;
- commit created or selected;
- whether synchronization/rebase occurred;
- tests/checks run and their results;
- whether conflicts occurred and how they were handled;
- exact push result and remote commit ID;
- any remaining local changes or risks.

## Workflow

### 1. Establish scope and preflight

Read the user's requested scope and commit message. If the message is missing, propose one from the actual diff; do not invent unrelated intent.

Run read-only checks:

```bash
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote -v
git branch -vv
git log -1 --oneline
```

Confirm the current directory is the intended repository, the branch is not detached, and the remote is the intended destination. If the tree contains pre-existing user changes, preserve them and separate them from the requested work. If scope cannot be separated safely, stop and ask.

### 2. Discover the verification gate

Inspect the repository for its documented build/test commands (`README`, `CONTRIBUTING`, `Justfile`, `Makefile`, package manifests, and CI configuration). Run the narrowest relevant existing checks after the change. Do not guess a command from the programming language alone.

If no meaningful check exists, state that explicitly. Do not convert “no test command found” into “tests passed.”

### 3. Review and commit only intended changes

Inspect:

```bash
git diff
git diff --stat
git diff --check
git status --short
```

Stage only files within the confirmed scope. Before committing, show the staged summary and check for secrets, generated artifacts, credentials, and accidental unrelated edits. Use a concise imperative commit message. After committing, record the commit ID and verify the tree state.

Do not use `git add -A` or `git add .` unless the user explicitly requested the entire tree and the review confirms that every change belongs in the commit.

### 4. Fetch and understand remote state

If an upstream exists, fetch it without changing the working tree:

```bash
git fetch --prune <remote>
git rev-list --left-right --count HEAD...<upstream>
```

Interpret the result:

- local ahead only: continue to verification and push;
- remote ahead only: rebase local work onto upstream, then verify again;
- both ahead: rebase local commits onto upstream, then verify again;
- no upstream: identify the intended remote branch and prepare an explicit first push;
- fetch failure: stop and report authentication, network, or remote errors.

Do not merge a remote branch merely to avoid a rebase. If the repository convention requires merge commits, follow that documented convention and explain it before proceeding.

### 5. Rebase and recover conflicts

For an authorized non-protected branch with local commits and an upstream update:

```bash
git rebase <upstream>
```

If a conflict occurs, stop the automated flow and inspect:

```bash
git status
git diff --name-only --diff-filter=U
git diff
```

Read [references/conflict-recovery.md](references/conflict-recovery.md). Resolve only when the intended result is clear from the code, tests, and user's request. After each resolution:

```bash
git add <resolved-files>
git rebase --continue
```

If the conflict is semantic, the correct version is uncertain, or the user must choose between behaviors, run `git rebase --abort`, return to the pre-rebase state, and ask the user. Never leave a conflict half-resolved while claiming success.

### 6. Verify the post-rebase tree

Run the discovered checks again after any rebase or conflict resolution. At minimum:

```bash
git diff --check
git status --short
git log --oneline --decorate -n 5
```

The tree must be clean except for explicitly preserved user changes. Confirm the intended commit is an ancestor of `HEAD` and the branch points where expected. A rebase invalidates earlier test evidence; rerun tests.

### 7. Review the push plan

Before pushing, calculate and present:

```bash
git status --short --branch
git log --oneline <upstream>..HEAD
git diff <upstream>..HEAD --stat
```

Confirm remote, branch, commit range, test result, and whether the push is ordinary or requires `--force-with-lease`. If the user did not clearly authorize the external push, stop here and ask for confirmation.

### 8. Push safely

For a normal push:

```bash
git push <remote> HEAD:<branch>
```

For a rebased non-protected branch where the remote has not changed since fetch, use:

```bash
git push --force-with-lease=<branch>:<expected-remote-oid> <remote> HEAD:<branch>
```

Prefer an explicit lease based on the fetched remote object ID. If the lease fails, do not retry with `--force`; fetch again, reassess, and stop if another person's work is involved. Never use plain `--force`.

### 9. Verify publication

After a successful push:

```bash
git ls-remote <remote> refs/heads/<branch>
git status --short --branch
git log -1 --oneline --decorate
```

The remote object ID must match the intended `HEAD`. Report any remaining local changes; they are not part of the published result.

## Stop conditions

Stop and report instead of improvising when:

- the repository, remote, branch, or requested file scope is ambiguous;
- the branch is detached or protected and the requested operation is unclear;
- credentials, network access, or repository permissions fail;
- conflicts require a semantic decision;
- tests fail after the final history state;
- the remote moved after the lease was calculated;
- the tree contains secrets or unrelated changes;
- the user requested a destructive cleanup not covered by this workflow.

## Failure report format

Use:

```text
STATUS: blocked | published | published-with-warnings
REPOSITORY: <root>
BRANCH: <branch>
REMOTE: <remote/url>
COMMIT: <sha> <subject>
SYNC: none | fetch-only | rebased | merged
CHECKS: <command> — PASS/FAIL/NOT RUN
PUSH: <result and remote sha>
REMAINING: <clean or exact paths>
NEXT: <one concrete next action>
```

Read [references/conflict-recovery.md](references/conflict-recovery.md) only when a rebase or merge conflict occurs.
