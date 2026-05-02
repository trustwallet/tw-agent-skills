
# Risk Check

Score counterparties, get signed attestations, and batch-process multiple entities.

**Base URL:** `https://revettr.com`

## Endpoints

### Score a counterparty

`POST /v1/score`

Returns a risk score (0 to 100), tier classification, flags, and per-signal breakdown.

**Request body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `entity_type` | string | Yes | One of: `wallet`, `domain`, `ip`, `company` |
| `value` | string | Yes | The entity to score (address, domain, IP, or name) |
| `skip_insumer` | boolean | No | Set `true` for free tier (wallet-only, no enrichment). Default `false`. |

**Example request:**

```bash
twak x402 request https://revettr.com/v1/score \
  --method POST \
  --body '{
    "entity_type": "wallet",
    "value": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
  }' \
  --yes --json
```

**Response:**

```json
{
  "score": 82,
  "tier": "low",
  "entity_type": "wallet",
  "value": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
  "flags": [],
  "signals": {
    "tx_count": { "value": 1847, "weight": 0.2, "contribution": 18.5 },
    "wallet_age_days": { "value": 1092, "weight": 0.15, "contribution": 15.0 },
    "counterparty_diversity": { "value": 312, "weight": 0.15, "contribution": 14.2 },
    "is_contract": { "value": false, "weight": 0.1, "contribution": 10.0 },
    "sanctions_match": { "value": false, "weight": 0.2, "contribution": 20.0 },
    "insumer_trust": { "value": 0.91, "weight": 0.2, "contribution": 4.3 }
  }
}
```

**Score tiers:**

| Tier | Score range | Meaning |
|------|------------|---------|
| `low` | 70 to 100 | Low risk. Safe to transact. |
| `medium` | 40 to 69 | Moderate risk. Review flags before proceeding. |
| `high` | 20 to 39 | High risk. Proceed with caution or decline. |
| `critical` | 0 to 19 | Critical risk. Do not transact. |

**Common flags:**

| Flag | Description |
|------|-------------|
| `NEW_WALLET` | Wallet is less than 30 days old |
| `LOW_TX_COUNT` | Fewer than 5 transactions |
| `SANCTIONS_HIT` | Matched OFAC, EU, or UN sanctions list |
| `CONTRACT_ADDRESS` | Entity is a smart contract, not an EOA |
| `PROXY_IP` | IP routed through known proxy or VPN |
| `WHOIS_PRIVATE` | Domain WHOIS record is privacy-protected |
| `SINGLE_CHAIN` | Wallet has activity on only one chain |

**Signal sources:**

| Signal | Source | Available on |
|--------|--------|-------------|
| `tx_count` | On-chain | Free + Standard |
| `wallet_age_days` | On-chain | Free + Standard |
| `counterparty_diversity` | On-chain | Free + Standard |
| `is_contract` | On-chain | Free + Standard |
| `sanctions_match` | OFAC, EU, UN lists | Standard only |
| `whois_age` | WHOIS lookup | Standard only (domain entities) |
| `geo_risk` | IP geolocation | Standard only (IP entities) |
| `insumer_trust` | InsumerAPI cross-chain profile | Standard only |

---

### Signed attestation

`POST /v1/attest`

Returns the same score wrapped in a JWS (ES256) envelope with an Ed25519 sibling signature. Use this when you need a verifiable, tamper-proof risk assessment that downstream services can validate.

**Request body:** Same as `/v1/score`.

**Response:**

```json
{
  "jws": "eyJhbGciOiJFUzI1NiIs...",
  "ed25519_signature": "base64-encoded-signature",
  "payload": {
    "score": 82,
    "tier": "low",
    "entity_type": "wallet",
    "value": "0xd8dA...6045",
    "flags": [],
    "timestamp": "2026-04-15T12:00:00Z",
    "expires": "2026-04-15T12:30:00Z"
  }
}
```

**Verifying attestations:**

Fetch the public keys from the JWKS endpoint:

```
GET https://revettr.com/v1/jwks
```

Validate the JWS using the ES256 key from the JWKS response. The `expires` field indicates how long the attestation is valid.

---

### Batch scoring

`GET /v1/batch`

Score multiple entities in a single request.

**Query parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `entities` | string | Yes | Comma-separated list of `type:value` pairs |

**Example request:**

```bash
twak x402 request "https://revettr.com/v1/batch?entities=wallet:0xabc...,domain:example.com,ip:203.0.113.42" \
  --yes --json
```

**Response:**

```json
{
  "results": [
    { "entity_type": "wallet", "value": "0xabc...", "score": 75, "tier": "low", "flags": [] },
    { "entity_type": "domain", "value": "example.com", "score": 61, "tier": "medium", "flags": ["WHOIS_PRIVATE"] },
    { "entity_type": "ip", "value": "203.0.113.42", "score": 34, "tier": "high", "flags": ["PROXY_IP"] }
  ]
}
```

Each result has the same shape as the `/v1/score` response. Batch pricing is per entity.

---

## Integration Pattern: Pre-Send Check

Before sending funds via x402, check the recipient. This is the primary use case.

```
1. User/agent wants to pay 0xRecipient via x402
2. Call POST /v1/score with entity_type=wallet, value=0xRecipient
3. If tier is "low" → proceed with payment
4. If tier is "medium" → surface flags to user, ask for confirmation
5. If tier is "high" or "critical" → block the transaction
```

### twak example

```bash
# Step 1: Check the counterparty
SCORE=$(twak x402 request https://revettr.com/v1/score \
  --method POST \
  --body '{"entity_type":"wallet","value":"0xRecipientAddress"}' \
  --yes --json | jq -r '.tier')

# Step 2: Proceed only if low risk
if [ "$SCORE" = "low" ]; then
  twak x402 request https://paid-api.example.com/data --yes --json
else
  echo "Counterparty risk too high: $SCORE"
fi
```

### Free tier alternative

For basic checks without x402 payment:

```bash
curl -s -X POST https://revettr.com/v1/score \
  -H "Content-Type: application/json" \
  -d '{"entity_type":"wallet","value":"0xRecipientAddress","skip_insumer":true}' \
  | jq '.tier'
```

This returns on-chain signals only. No sanctions screening, no cross-chain enrichment.
