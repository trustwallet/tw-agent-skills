---
description: Get swap quotes and execute token swaps — same-chain and cross-chain via the Amber aggregator with 10+ DEX/bridge providers (1inch, Jupiter, KyberSwap, THORChain, Stargate, etc.). Use this whenever someone wants to swap tokens, bridge between chains, get a swap quote, compare DEX rates, or execute any kind of token exchange.
---

# Swap Quotes

Get quotes and transaction data for same-chain and cross-chain token swaps via the Amber aggregator.

**Base URL:** `https://tws.trustwallet.com`
**Auth:** HMAC-SHA256 (run `/setup` first if you haven't configured auth)

## Key Concepts

**Native token addresses:**
- EVM: `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- Solana (SOL): `So11111111111111111111111111111111111111112`
- All others: use the contract/mint address

**Domain IDs** identify chains: `ethereum`, `bsc`, `polygon`, `arbitrum`, `optimism`, `base`, `avalanche`, `solana`, `bitcoin`, `tron`

## Get Swap Quote — `POST /amber-api/v1/route`

Returns ranked routes sorted by output amount.

```json
{
  "fromAsset": "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE",
  "fromAddress": "0xYourAddress",
  "fromDomain": "base",
  "amount": "100000000000000000",
  "toAsset": "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
  "toAddress": "0xYourAddress",
  "toDomain": "base",
  "slippage": "1",
  "sortBy": "outcome",
  "contractCall": false
}
```

Optional fields: `preferredProviders`, `ignoredProviders` (arrays of provider IDs), `thorchain: { "streaming": true }` for streaming swaps.

## Get Step Transaction — `POST /amber-api/v1/route/step`

Get executable transaction data for a specific step. Pass `{ "stepId": "step-uuid" }`.

Returns `transaction` (the swap tx), `approve` (ERC-20 approval if needed), and `revokeApproval` (if needed).

## Execution Flow

1. `POST /amber-api/v1/route` — get quotes
2. Pick the best route (first one is best by `sortBy`)
3. For each step: `POST /amber-api/v1/route/step`
4. Execute in order: revokeApproval (if any) → approve (if any) → main transaction

For full response schemas and provider details, read `skills/api/references/swap-quote.md`.
