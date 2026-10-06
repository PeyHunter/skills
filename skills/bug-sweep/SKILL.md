---
name: bug-sweep
description: Start from one confirmed bug, turn its root cause into a searchable pattern, hunt the codebase for sibling bugs with the same flaw, verify each candidate, and fix them with approval. Use when a bug has been found or fixed and the user asks "are there other places like this", "find similar bugs", "sweep for this bug", or "check the rest of the project for this flaw"; do not use to diagnose an unexplained bug (use a diagnosis workflow first) or for a general quality audit with no seed bug.
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
user-invocable: true
argument-hint: "<the bug: file:line, commit, or root-cause description>"
---

# Bug Sweep

One bug is rarely alone. The same author, the same copy-pasted block, the same misunderstood API, or the same wrong assumption usually produced siblings. This skill turns a single confirmed bug (the **seed**) into a pattern, finds every **variant** of it, proves which ones are real, and fixes them with the user's approval.

The value is in the middle: an agent left alone fixes the seed and stops, or greps for the exact line and misses the variants that are spelled differently. This skill forces a search at three levels of abstraction and a skeptical check on every hit.

## Phase 1 — Pin the seed

Before searching, write down:

- **Location** — `file:line` (or the commit that fixed it).
- **Root cause** — one sentence on *why* it is wrong, not what the symptom was.
- **Violated invariant** — the rule the code broke, e.g. "every `await`-able call inside the loop must be awaited", "user input reaches SQL only through parameters".
- **Evidence** — a failing test, a reproduction command and its output, or the exact faulty line quoted.

**Stop condition:** if you cannot state the root cause and invariant with evidence, do not sweep. A guessed pattern produces a pile of false positives. Say so and route to a diagnosis workflow (e.g. `diagnosing-bugs`) first, then come back.

## Phase 2 — Write the bug signature

Describe the flaw at three levels. Each level needs its own search plan.

| Level | What it is | How to search |
|---|---|---|
| **Syntactic** | The literal code shape of the seed | `rg` regex; `ast-grep` if installed |
| **Semantic** | The same mistake spelled differently: other callers of the same API, the same type misused, a renamed copy | Find callers/callees of the faulty function; search for the API name, not the line |
| **Conceptual** | The broken assumption behind it: "list is never empty", "times share a timezone", "id is always a number" | List the places that rely on that assumption (inputs, parsers, boundaries) and read them |

Also note where the seed came from — `git log -S'<snippet>'` and `git blame` often reveal code that was copied in the same commit.

Concrete search commands by bug class are in [references/search-recipes.md](references/search-recipes.md). Read it when building the search plan.

## Phase 3 — Hunt

Run every level's search. Record each hit as a **candidate** with `file:line` and the matching code. Do not judge yet.

- Search the whole tracked tree, excluding vendored and generated code (`node_modules`, `dist`, lockfiles, fixtures) unless the user asks.
- For a large repo, run the three levels as parallel read-only subagents, each returning a candidate list.
- **Too many candidates (more than about 20):** the signature is too loose. Tighten it and re-run before triage, or ask the user which area matters.
- **Zero candidates:** report that, together with the searches you ran. "No variants found with these searches" is a valid result — do not invent findings to have something to report.

## Phase 4 — Triage

Classify every candidate. Read the surrounding code for each; do not classify from the grep line alone.

- **Confirmed** — the same invariant is violated and a realistic input reaches it. Quote the evidence.
- **Likely** — the pattern matches, but reachability or input is unproven. Say what would settle it.
- **False positive** — a guard, type, or caller already prevents it. Name the guard at `file:line`.

**Skeptic pass:** for each confirmed finding, try to refute it — look for the guard, validation, or caller contract that makes it safe. Downgrade it if you find one. A wrong "confirmed" costs the user more than a missed variant.

## Phase 5 — Report, then fix with approval

Present the findings using [references/report-template.md](references/report-template.md) **before editing any code**. Then ask which ones to fix. Do not fix without approval: the sweep often reaches code the user did not ask you to touch.

Once approved:

1. Fix the seed first, with a regression test that fails before the fix and passes after.
2. Fix each approved variant. Add a test where a seam exists that exercises the real code path; where none exists, say so instead of writing a shallow test.
3. If several variants share one cause (e.g. a helper everyone misuses), propose one shared fix instead of N patches, and let the user choose.
4. Run the project's tests and show the command and its result.

## Phase 6 — Prevent recurrence

Offer — do not apply without approval — one guard that stops the pattern coming back: a lint or `ast-grep`/`semgrep` rule, a stricter type, a wrapper that makes the safe path the easy path, or a test that checks the invariant everywhere. Explain in one line why that guard fits this bug.

## Output

End with a summary: the seed, the signature, searches run, counts (confirmed / likely / false positive), what was fixed with test evidence, what was left and why, and the prevention offer.
