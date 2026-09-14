# Conflict Recovery

A conflict is a decision point, not a failed command to hide.

## Safe sequence

1. Capture `git status` and the list of unmerged paths.
2. Read the surrounding code and both sides of each conflict.
3. Check the commit messages and tests that explain the intended behavior.
4. Resolve only conflicts whose intended result is unambiguous.
5. Stage only resolved files and continue the rebase or merge.
6. Run formatting, static checks, and tests after the operation completes.
7. Inspect the final diff against the pre-operation intent.

## Abort instead of guessing

Abort with `git rebase --abort` when the conflict changes behavior, data formats, public APIs, security boundaries, or user-visible behavior and the correct choice is not established by repository evidence. For a merge, use `git merge --abort` when available.

Never use `git checkout --theirs`, `git checkout --ours`, or equivalent bulk resolution without inspecting every affected file. Those commands select a side, not the correct behavior.

## Recovery evidence

After aborting, report that no publish occurred, identify the conflicting files, and give the user the smallest decision needed to continue. After resolving, report the files changed by the resolution and the checks that passed afterward.
