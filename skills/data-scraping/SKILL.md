---
name: data-scraping
description: Plan and implement responsible, resumable website data collection from a user-provided public source. Use when the user wants to download structured data from web pages, APIs, feeds, or client-rendered sites; do not bypass authentication, paywalls, CAPTCHAs, robots restrictions, rate limits, or access controls.
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
user-invocable: true
argument-hint: "<URL> [what to collect]"
---

# Data Scraping

Turn an authorized website-data request into a bounded, observable collection program. The deliverable is normally a scraper project or script plus configuration, schema, provenance, checkpoints, tests, and run instructions. Do not start a large download merely because a URL was supplied.

## Modes

- **Plan** — inspect the source and propose scope, schema, volume, architecture, and risks without downloading the corpus.
- **Implement** — create or update the collector in the target project.
- **Dry-run** — request a small bounded sample and validate selectors, schema, deduplication, and output.
- **Run** — execute an approved bounded collection with logging, rate limits, retries, and checkpoints.
- **Resume** — continue an interrupted run only from its recorded checkpoint and with the same source/configuration fingerprint.

If the mode is unclear, start with Plan. A full run requires an explicit scope and a bounded maximum unless the user has already provided both.

## Before touching the source

Confirm:

- the exact starting URL(s) and allowed domains;
- what records/fields are wanted and what must be excluded;
- whether the source is public and whether the user is authorized to collect it;
- page/item limits, output format, destination, and retention requirements;
- whether an official API, export, sitemap, RSS/Atom feed, or downloadable dataset exists;
- whether the data may contain personal, sensitive, copyrighted, or access-controlled material.

Prefer an official API or export when it provides the required data. Do not collect credentials, session cookies, tokens, hidden form values, private profiles, or unnecessary personal data. If authorization, terms, robots policy, or intended use is unclear, pause and ask rather than infer permission.

Read [references/responsible-use.md](references/responsible-use.md) when the source, authorization, robots policy, rate limits, or personal data are relevant.

## Choose the smallest suitable architecture

1. **Static HTML/API**: use a standard HTTP client and an HTML/JSON parser.
2. **Paginated or linked pages**: implement an explicit frontier with domain and URL rules.
3. **Client-rendered content**: use a browser automation tool only when necessary and authorized; prefer a documented network API if available.
4. **Large or long-running collection**: use a durable queue/frontier, checkpoint store, bounded concurrency, and idempotent writes.

Do not use browser automation, high concurrency, proxy rotation, fingerprint spoofing, or CAPTCHA-solving to defeat a site's controls. These are not reliability features.

## Collector contract

The implementation must make these values configurable rather than burying them in code:

- start URLs and allowed hostnames;
- URL normalization and pagination rules;
- extraction schema and parser version;
- maximum pages, records, bytes, and runtime;
- request timeout, concurrency, and per-host delay;
- retryable status codes and backoff policy;
- output path/format and deduplication key;
- checkpoint path and resume behavior.

Write raw responses only when they are necessary for reproducibility and permitted by the source. Store provenance for each record: source URL, retrieval timestamp, parser/schema version, and a stable record key where possible.

## Safe run sequence

### 1. Plan and inspect

Fetch only the landing page, relevant robots policy, and documented API/feed metadata needed to design the collector. Record the observed pagination and field structure. Do not crawl from every discovered link during inspection.

### 2. Implement with bounded behavior

Use explicit allowlists, URL canonicalization, timeouts, a conservative per-host rate, `Retry-After` handling, exponential backoff for transient failures, and structured logs. Retry only transient failures such as 408, 429, and appropriate 5xx responses. Do not retry authorization failures or parser errors indefinitely.

### 3. Dry-run a sample

Run a small sample, such as one page or a user-approved record limit. Check:

- expected fields and types;
- missing-field behavior;
- duplicate records;
- pagination termination;
- malformed responses;
- output encoding and atomic writes;
- request count, bytes, delay, and error rate.

Do not begin the full run until the sample is inspected and accepted.

### 4. Run with checkpoints

Persist progress after each safe unit of work. A checkpoint should include the source/configuration fingerprint, parser version, completed URLs or record keys, output location, and timestamp. Write records idempotently so a restart does not duplicate data. Use temporary files and atomic renames for manifests and batches.

### 5. Verify and report

Validate the final dataset against the schema, count records and duplicates, summarize failures and skipped URLs, and confirm the checkpoint says whether the run completed. Report what was not collected. A process that ended without errors is not automatically a complete collection.

## Resume and change handling

Resume only if the source scope, extraction schema, parser version, and relevant configuration match the checkpoint. If any changed, start a new run or explicitly migrate the old output. Never silently mix incompatible schemas or overwrite an existing dataset.

If the source changes selectors or response structure, stop after the parser-validation failure, preserve the evidence, update the parser and tests, then rerun a bounded dry-run. Do not add broad fallback selectors that may silently collect the wrong field.

## Stop conditions

Stop and report when:

- robots policy, terms, authorization, or data rights are unclear;
- the collector encounters authentication, CAPTCHA, paywall, bot-detection, or access-control barriers;
- the requested volume is unbounded or exceeds the approved budget;
- the server signals rate limiting and the allowed delay is unknown;
- the schema is ambiguous or extraction confidence drops;
- the source unexpectedly exposes personal or sensitive data;
- the checkpoint is incompatible with the requested resume;
- error rate, response volume, or runtime exceeds the configured threshold.

Never claim “all data” unless the scope, termination condition, and verification support that claim. Prefer “all records reachable under these rules and limits.”

## Output report

Use this shape:

```text
STATUS: planned | dry-run-passed | completed | partial | blocked
SOURCE: <starting URL and allowed domains>
SCOPE: <pages/records/bytes/time limits>
METHOD: api | html | browser | feed | export
OUTPUT: <path and format>
RESULT: <records, pages, duplicates, bytes>
CHECKS: <schema/quality checks and results>
RETRIES: <count and status summary>
SKIPPED/FAILED: <counts and representative causes>
CHECKPOINT: <path, fingerprint, resumable yes/no>
NEXT: <one concrete next action>
```

Read [references/validation-and-resume.md](references/validation-and-resume.md) when implementing checkpoints, schemas, retries, or long-running collection.
