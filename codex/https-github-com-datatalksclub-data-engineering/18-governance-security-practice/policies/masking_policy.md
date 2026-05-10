# Masking and Tokenization Policy

## Purpose

Protect PII while preserving analytical usefulness where possible.

## Masking Patterns

| Field | Masked Example | Notes |
|---|---|---|
| email | `a***@example.com` | useful for support triage, not joins |
| phone | `******1234` | show last 4 only |
| full_name | `Alice N.` | partial masking |
| address | null or city-level only | avoid street-level exposure |
| national_id | null | generally should not be visible |

## Tokenization

Tokenization replaces sensitive value with a stable token.

Example:

```text
alice@example.com -> tok_email_8f23a91
```

Use when:

- analysts need to join records across systems
- direct identifier is not needed
- consistent pseudonymous ID is enough

Trade-off:

- Masking is simpler.
- Tokenization preserves joinability but requires key management and governance.

## Policy

- Raw PII remains in restricted datasets.
- Curated marts should expose masked or tokenized fields.
- Direct identifiers require explicit approval.
- Dashboards should not show raw email/phone unless approved.

