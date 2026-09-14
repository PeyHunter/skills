# Responsible Use

This reference is operational guidance, not legal advice. The requester is responsible for confirming that the collection is authorized and lawful for the source and intended use.

## Source checks

- Identify the owner, domain, public/private boundary, and documented API or export.
- Read `robots.txt` as an operational signal and respect disallowed paths unless the owner has separately authorized access.
- Check the site's terms, usage limits, license, and data-retention expectations.
- Do not bypass login, paywalls, CAPTCHAs, IP blocks, certificate checks, or bot-detection controls.
- Do not use another person's credentials, session cookies, or private endpoints.

## Data minimization

Collect only fields required for the stated purpose. Avoid names, emails, phone numbers, precise locations, identifiers, and private content unless explicitly necessary and authorized. Keep raw responses only when needed, and protect them as sensitive if they contain personal data.

## Operational restraint

Use a clear user-agent, conservative per-host delay, bounded concurrency, `Retry-After`, and a hard request/runtime budget. Stop on repeated 403/429 responses or a sudden change in server behavior. Do not rotate IPs or identities to continue after a block.

## Evidence

Record the source URL, retrieval time, collector version, schema version, and collection limits. Preserve enough logs to explain failures without logging credentials or full sensitive payloads.
