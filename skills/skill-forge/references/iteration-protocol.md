# Skill Forge Iteration Protocol

Use this for a new skill with meaningful side effects, multiple modes, or a stateful workflow. Five passes are enough for a strong first version; each pass must inspect the current files and may produce edits.

## Pass 1 — Routing and scope

Check the name, description, trigger phrases, exclusions, user-invocable policy, and allowed tools. Test one request that should trigger and one nearby request that should not. Remove catch-all wording.

## Pass 2 — Workflow and decisions

Trace the workflow from preflight to final output. For every branch, state what evidence selects it. Mark which steps are required, optional, destructive, external, or approval-gated. Remove steps that do not change a decision.

## Pass 3 — Failure and recovery

Enumerate realistic failures, including interruption halfway through the workflow. For each, record symptoms, cause, safe recovery, and what must not be claimed afterwards. Ensure the skill stops instead of guessing when recovery needs user input.

## Pass 4 — Forward testing

Run at least three realistic scenarios in an isolated temporary workspace: happy path, boundary case, and failure/recovery case. Give the evaluator the skill and raw artifacts, but not the expected answer or suspected defect. Inspect the actual artifacts and commands, not just the evaluator's summary.

## Pass 5 — Final audit

Check frontmatter, links, references, scripts, scope, permissions, and output shape. Compare every claim against the observable checks. Record remaining limitations. Only then call the skill ready for normal use.

Do not manufacture confidence by repeating the same test five times. Each pass must target a different risk.
