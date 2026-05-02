
# Setup

## What is Revettr?

Revettr scores counterparty risk for agentic commerce. Before your agent sends funds via x402 or any other payment rail, call Revettr to check whether the recipient wallet, domain, IP, or company is trustworthy. Scores range from 0 (maximum risk) to 100 (fully trusted).

**Base URL:** `https://revettr.com`

## Discovery

Revettr publishes its capabilities at a well-known endpoint:

```
GET https://revettr.com/.well-known/risk-check.json
```

The response describes available endpoints, supported entity types, and pricing.

## Tiers

| Tier | Auth | What you get |
|------|------|-------------|
| Free | None | Wallet scoring only, no off-chain enrichment. Pass `skip_insumer=true`. |
| Standard | x402 micropayment | Full enrichment: on-chain + off-chain + cross-chain via InsumerAPI. |
| Enterprise | API key | Custom limits, SLA, dedicated support. |

## x402 Payment (Standard Tier)

Revettr uses the x402 payment protocol. TWAK already speaks x402, so there is zero additional auth overhead for agents.

### Flow

1. Agent calls `POST /v1/score` without payment headers.
2. Revettr returns `402 Payment Required` with payment details (amount in USDC on Base).
3. Agent pays on-chain and retries with payment proof.
4. Revettr returns the full risk score.

### Using twak

```bash
# Score a wallet with x402 auto-payment
twak x402 request https://revettr.com/v1/score \
  --method POST \
  --body '{"entity_type":"wallet","value":"0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"}' \
  --yes --json
```

### Using curl (free tier)

```bash
curl -X POST https://revettr.com/v1/score \
  -H "Content-Type: application/json" \
  -d '{
    "entity_type": "wallet",
    "value": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
    "skip_insumer": true
  }'
```

The free tier returns on-chain signals only (transaction count, wallet age, counterparty diversity, contract detection). No off-chain enrichment (WHOIS, geolocation, sanctions) and no cross-chain trust profiles.

## Supported Entity Types

| Entity type | Example value | Notes |
|-------------|---------------|-------|
| `wallet` | `0xd8dA...6045` | EVM, Solana, XRP, Bitcoin addresses |
| `domain` | `api.example.com` | WHOIS + DNS enrichment |
| `ip` | `203.0.113.42` | Geolocation + proxy detection |
| `company` | `Acme Corp` | Registry + sanctions screening |

## Supported Chains (cross-chain via InsumerAPI)

EVM chains (Ethereum, Base, Polygon, Arbitrum, Optimism, BSC, and others), Solana, XRP Ledger, and Bitcoin. InsumerAPI trust profiles aggregate signals across all supported chains.
