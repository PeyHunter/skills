# Validation and Resume

## Minimum dataset checks

- required fields exist with expected types;
- URLs and identifiers are normalized;
- duplicate keys are counted and handled deterministically;
- pagination stops for an observed reason;
- malformed records are quarantined with a reason;
- output is readable after an interrupted write;
- counts and byte totals are recorded.

## Checkpoint contents

Store a versioned JSON or equivalent manifest containing:

```text
source scope
configuration fingerprint
parser and schema versions
completed URL/record keys
output batches and checksums
started/updated timestamps
status and failure counts
```

Write the checkpoint atomically. The resume command must verify the fingerprint before consuming it. If the fingerprint differs, fail with a clear message and require a new run or explicit migration.

## Retry policy

Retry only bounded transient failures. Honor `Retry-After` for 429 and 503 responses. Use exponential backoff with jitter and a maximum attempt count. Do not retry 401/403, invalid URLs, schema errors, or deterministic parser failures without a changed configuration.
