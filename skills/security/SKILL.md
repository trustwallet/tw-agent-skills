---
name: security
description: Validate wallet addresses and check token risk — honeypot detection, audit status, freeze authority, and other security signals. Use this before interacting with any unfamiliar token or address, whenever someone asks "is this token safe", "is this address legit", wants to check for scams/rugs, or needs security due diligence on a contract.
---

# Security

Validate addresses and analyze token risk before transacting.

**Base URL:** `https://tws.trustwallet.com`
**Auth:** HMAC-SHA256 (see [setup](../setup/SKILL.md))

## Endpoints

### Validate Address

`GET /v1/validate`

Validate a wallet address or transaction for security risks.

**Query parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `address` | string | Yes | Address to validate |
| `asset_id` | string | No | Asset ID for context (e.g., `c60` for Ethereum) |
| `type` | string | No | Validation type: `address`, `transaction` |

**Example request:**

```
GET /v1/validate?address=0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045&asset_id=c60&type=address
```

**Response:**

```json
{
  "valid": true,
  "result": "whitelist",
  "details": {
    "is_contract": false,
    "is_sanctioned": false,
    "risk_score": 0,
    "labels": []
  }
}
```

**Result values:**

| Value | Meaning |
|-------|---------|
| `whitelist` | Known safe address |
| `neutral` | No risk signals |
| `blacklist` | Known malicious address |
| `unknown` | Not enough data |

---

### Check Token Risk

`GET /v2/coinstatus/{assetId}`

Check security and risk information for a token — honeypot detection, audit status, freeze authority, and more.

**Path parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `assetId` | string | Yes | Asset ID (e.g., `c60_t0xA0b8...` for ERC-20, `c501` for SOL) |

**Query parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `version` | string | No | API version (use `2`) |
| `platform` | string | No | Platform identifier |
| `include_security_info` | boolean | No | Include EVM security data (default: `true`) |
| `include_solana_security_info` | boolean | No | Include Solana-specific security data (default: `true`) |

**Example request:**

```
GET /v2/coinstatus/c60_t0xdAC17F958D2ee523a2206206994597C13D831ec7?version=2&include_security_info=true
```

**Response:**

```json
{
  "asset_id": "c60_t0xdAC17F958D2ee523a2206206994597C13D831ec7",
  "name": "Tether USD",
  "symbol": "USDT",
  "isActive": true,
  "supportsSwap": true,
  "securityInfo": {
    "riskLevel": "low",
    "isHoneypot": false,
    "hasAudit": true,
    "auditProvider": "OpenZeppelin",
    "hasMintFunction": true,
    "canTakeBackOwnership": false,
    "isTradingCooldown": false,
    "warnings": []
  }
}
```

For Solana tokens, the response includes `solanaSecurityInfo` instead:

```json
{
  "solanaSecurityInfo": {
    "riskLevel": "medium",
    "hasFreezeAuthority": true,
    "hasMintAuthority": true,
    "isInitialized": true,
    "warnings": ["Token has active freeze authority"]
  }
}
```

**Risk levels:** `low`, `medium`, `high`, `critical`, `unknown`

**EVM security fields:**

| Field | Type | Description |
|-------|------|-------------|
| `riskLevel` | string | Overall risk level |
| `isHoneypot` | boolean | Cannot sell after buying |
| `hasAudit` | boolean | Smart contract has been audited |
| `auditProvider` | string | Name of audit firm |
| `hasMintFunction` | boolean | Token supply can be increased |
| `canTakeBackOwnership` | boolean | Owner can reclaim ownership after renouncing |
| `isTradingCooldown` | boolean | Trading restrictions after buy |
| `warnings` | string[] | Human-readable risk warnings |

**Solana security fields:**

| Field | Type | Description |
|-------|------|-------------|
| `riskLevel` | string | Overall risk level |
| `hasFreezeAuthority` | boolean | Token accounts can be frozen |
| `hasMintAuthority` | boolean | Supply can be increased |
| `isInitialized` | boolean | Token program is initialized |
| `warnings` | string[] | Human-readable risk warnings |
