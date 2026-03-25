---
description: Validate wallet addresses and check token risk — honeypot detection, audit status, freeze authority, and security signals. Use this before interacting with any unfamiliar token or address, whenever someone asks "is this token safe", "is this address legit", wants to check for scams/rugs, or needs security due diligence on a contract.
---

# Security

Validate addresses and analyze token risk before transacting. This is the safety net — use it proactively before swaps or transfers to unfamiliar addresses/tokens.

**Base URL:** `https://tws.trustwallet.com`
**Auth:** HMAC-SHA256 (run `/setup` first if you haven't configured auth)

## Validate Address — `GET /v1/validate`

Check if an address is safe, flagged, or sanctioned.

| Param | Required | Description |
|-------|----------|-------------|
| `address` | Yes | Address to validate |
| `asset_id` | No | Asset ID for context (e.g., `c60`) |
| `type` | No | `address` or `transaction` |

Example: `GET /v1/validate?address=0xd8dA...&asset_id=c60&type=address`

**Result values:** `whitelist` (known safe), `neutral` (no signals), `blacklist` (known malicious), `unknown` (insufficient data)

Also returns `is_contract`, `is_sanctioned`, `risk_score`, and `labels`.

## Check Token Risk — `GET /v2/coinstatus/{assetId}`

Deep security analysis for a token — critical before interacting with any new or unverified token.

| Param | Required | Description |
|-------|----------|-------------|
| `version` | No | Use `2` |
| `include_security_info` | No | Include EVM security data (default: `true`) |
| `include_solana_security_info` | No | Include Solana security data (default: `true`) |

Example: `GET /v2/coinstatus/c60_t0xdAC17F958D2ee523a2206206994597C13D831ec7?version=2&include_security_info=true`

**Risk levels:** `low`, `medium`, `high`, `critical`, `unknown`

**EVM security signals:** `isHoneypot`, `hasAudit`, `auditProvider`, `hasMintFunction`, `canTakeBackOwnership`, `isTradingCooldown`, `warnings`

**Solana security signals:** `hasFreezeAuthority`, `hasMintAuthority`, `isInitialized`, `warnings`

For full response schemas, read `skills/api/references/security.md`.
