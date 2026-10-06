# Report template

Present this before editing any code. Keep it skimmable: the table carries the findings, prose carries only what the table cannot.

```markdown
## Bug sweep: <one-line name of the flaw>

**Seed:** `<file:line>` — <root cause in one sentence>
**Invariant:** <the rule the code broke>
**Evidence:** <test or command and its output, or the quoted line>

### Signature
- **Syntactic:** <shape> — searched with `<command>`
- **Semantic:** <shape> — searched with `<command>`
- **Conceptual:** <assumption> — checked <where>

### Findings

| # | Location | Level | Verdict | Evidence | Proposed fix |
|---|----------|-------|---------|----------|--------------|
| 1 | `src/a.js:42` | syntactic | confirmed | <quote or reasoning> | <concrete change> |
| 2 | `src/b.js:17` | semantic | likely | <what is unproven> | <change, or how to settle it> |
| 3 | `src/c.js:88` | conceptual | false positive | guarded at `src/c.js:80` | — |

**Totals:** <n> confirmed · <n> likely · <n> false positive · <n> candidates reviewed

### Shared root cause
<only if several findings share one cause: the single fix that would cover them>

### Next step
Which should I fix? (Seed first, with a regression test.)
```

After fixing, append:

```markdown
### Fixed
- #1 — <change> — test: `<command>` → <result>

### Left as is
- #2 — <reason>

### Prevention (offer)
<one guard, and why it fits this bug>
```
