# Personal Agent Skills

A version-controlled collection of reusable skills for Codex and compatible agents.

## Skills

- [`skill-forge`](skills/skill-forge/) — design, write, review, and improve professional agent skills.
- [`git-safe-publish`](skills/git-safe-publish/) — safely commit, rebase, verify, resolve, and publish Git changes.

Each skill lives in its own directory under `skills/` and contains a `SKILL.md`. Supporting references and scripts stay inside that skill's directory.

## Development

Run the local check before committing:

```sh
bash skills/skill-forge/scripts/check_skill.sh skills/skill-forge
```

Keep secrets, personal data, machine-specific paths, and generated output out of this repository.
