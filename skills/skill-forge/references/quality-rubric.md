# Skill Quality Rubric

Use this rubric for detailed reviews. Do not turn every suggestion into a mandatory rule; prioritize issues that affect routing, correctness, safety, or repeatability.

## Routing

- Name is lowercase, action-oriented, and under 64 characters.
- Description identifies the capability and useful trigger situations.
- Description excludes the nearest likely misroutes.

## Behavior

- The skill defines an observable outcome.
- Workflow steps are ordered only where order matters.
- Decision points explain what evidence changes the path.
- The skill distinguishes required behavior from optional recommendations.

## Reliability

- Failure modes include symptoms and recovery.
- Validation checks observable results rather than generated wording.
- Claims are proportional to the evidence collected.
- Repeated or fragile logic is executable or documented once in a reference.
- Stateful workflows define preconditions, transitions, and postconditions.
- Partial completion is distinguishable from success.

## Safety and scope

- User instructions remain authoritative.
- External mutations, sensitive data, and destructive operations have explicit boundaries.
- The skill does not silently expand the task.
- Stop conditions exist for blocked or ambiguous work.

## Maintainability

- `SKILL.md` contains shared routing and constraints.
- Conditional detail is progressively disclosed through linked references.
- Scripts have safe argument handling and clear exit codes.
- Examples are realistic and do not contain secrets or personal data.

## Review output

Prioritize findings as HIGH, MEDIUM, or LOW. Each finding should identify the evidence, explain the impact, and propose one concrete remediation. Do not emit a vague improvement suggestion.
