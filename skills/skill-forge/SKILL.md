---
name: skill-forge
description: Design, write, review, and improve professional agent skills for repeatable workflows. Use when creating a new skill, evaluating an existing skill, or turning an informal process into durable agent instructions.
---

# Skill Forge

Create skills that improve an agent's decisions for a specific, repeatable task. A skill is not finished because its Markdown is well formatted; it is finished when another agent can use it predictably and its important failure modes are visible.

## Modes

- **Create**: turn a task or informal process into a new skill.
- **Review**: inspect an existing skill and return prioritized findings without editing it.
- **Improve**: revise an existing skill when the user asks for changes.

If the mode is unclear, infer it from the request. Ask a question only when the missing answer would materially change the skill's scope or side effects.

## Workflow

1. Define the intended user, task, desired outcome, and concrete artifacts.
2. Write activation criteria and exclusions so the skill routes narrowly.
3. Separate required constraints from recommendations and local conventions.
4. Design the workflow, decision points, approval boundaries, and stop conditions.
5. Identify realistic failure modes, symptoms, causes, recovery, and prevention.
6. Decide whether supporting references, scripts, or assets are justified. Do not add them as decoration.
7. Draft or revise `SKILL.md` with concise shared guidance. Move conditional detail into linked references.
8. Test the skill against at least two realistic requests, including one boundary case.
9. Validate metadata, naming, references, and scripts. Report limitations that testing did not cover.

## Quality gate

Before declaring a skill complete, confirm:

- The description says what the skill does and when it applies.
- The scope is narrow enough to avoid misrouting.
- The instructions change decisions an already-capable agent would otherwise make.
- User intent and authorization boundaries are preserved.
- Side effects require the appropriate confirmation or permission.
- Important failure modes have observable checks and recovery paths.
- References are discoverable and loaded only when relevant.
- Scripts are deterministic, safe for their target paths, and tested.
- The skill does not claim to prove more than its checks can establish.

## Output

For **create**, produce the skill files and a short validation report.

For **review**, return findings ordered by impact. Each finding must include a file and line when possible, why it matters, and one concrete remediation.

For **improve**, edit only the requested skill surfaces, run proportionate checks, and summarize the changes and remaining risks.

Read [references/quality-rubric.md](references/quality-rubric.md) when performing a detailed review or when the skill has multiple modes or meaningful side effects.
