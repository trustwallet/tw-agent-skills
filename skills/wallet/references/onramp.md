
# Onramp & Offramp (Fiat ↔ Crypto)

Buy crypto with fiat (onramp) or sell crypto for fiat (offramp) through third-party providers. Quotes are aggregated; the user completes KYC and payment in the provider's hosted browser flow. Available providers depend on the user's region.

## Prerequisites

- Authenticated (`twak auth status`)
- Agent wallet created (`twak wallet create --password <pw>`) — the destination/source address is derived from your stored wallet by default

## Onramp (Buy Crypto)

Two-step flow: get quotes, then open the chosen provider's checkout URL.

```bash
# 1. Compare provider quotes for $100 USD → ETH
twak onramp quote --amount 100 --asset c60 --json

# 2. Pick a quoteId from the result and open the checkout URL
twak onramp buy --quote-id <quoteId> --asset c60 --json
```

The destination address defaults to your stored wallet's address on the asset's chain. Override with `--wallet <address>` (the CLI loudly flags manual addresses — verify before continuing).

After payment completes (5–30 min for card, 1–3 business days for bank transfer), check your balance:

```bash
twak wallet balance --chain ethereum --json
```

### Onramp options

`twak onramp quote`:
- `--amount <n>` — Fiat amount, e.g. `100` (required)
- `--asset <id>` — Asset ID, e.g. `c60` for ETH, `c20000714` for BNB (required)
- `--currency <code>` — Fiat currency (default: USD)
- `--wallet <address>` — Override the derived destination address
- `--json` — Output as JSON

`twak onramp buy`:
- `--quote-id <id>` — Quote ID from `onramp quote` (required)
- `--asset <id>` — Required when `--wallet` is omitted (used to derive your address)
- `--wallet <address>` — Override the derived destination address
- `--json` — Output as JSON

## Offramp (Sell Crypto)

Three-step flow: get quotes, open the provider's checkout to get a deposit address, then broadcast the on-chain payout.

```bash
# 1. Compare provider quotes for selling 0.1 ETH → USD
twak onramp sell-quote --amount 0.1 --asset c60 --json

# 2. Pick a quoteId; the URL completes KYC and reveals the deposit address
twak onramp sell --quote-id <quoteId> --asset c60 --json

# 3. Broadcast the payout to the deposit address shown by the provider
twak onramp sell-confirm \
  --asset c60 --to <provider-deposit-address> --amount 0.1 --json
```

### Offramp options

`twak onramp sell-quote`:
- `--amount <n>` — Crypto amount to sell, e.g. `0.1` (required)
- `--asset <id>` — Asset ID being sold (required)
- `--currency <code>` — Fiat currency (default: USD)
- `--method <method>` — Payout method: `ANY`, `card`, `bank_transfer` (default: `ANY`)
- `--wallet <address>` — Override the derived source address
- `--json` — Output as JSON

`twak onramp sell`:
- `--quote-id <id>` — Quote ID from `sell-quote` (required)
- `--asset <id>` — Required when `--wallet` is omitted
- `--wallet <address>` — Override the derived source address
- `--json` — Output as JSON

`twak onramp sell-confirm`:
- `--asset <id>` — Asset being sold (required)
- `--to <address>` — Provider's deposit address (required, shown after KYC)
- `--amount <n>` — Exact amount the provider displays (required, must match)
- `--memo <tag>` — Memo / destination tag (Cosmos, XRP, Stellar, BNB Beacon — funds unrecoverable without it when required)
- `--quote-id <id>` — Optional, included in output for traceability
- `--max-usd <n>` — USD safety cap (default: 10,000)
- `--skip-safety-check` — Bypass the USD cap
- `--password <pw>` — Wallet password (resolved from keychain if omitted)
- `--json` — Output as JSON

## Safety

- `sell-confirm` rejects payouts above `--max-usd` (default $10,000); warns above $1,000.
- The deposit address shown by the provider is **not under your control** — verify it byte-for-byte against what the provider displayed before broadcasting.
- The browser flow has no access to your keys; it only collects KYC and reveals the deposit address. Signing always happens locally via `sell-confirm`.
- `--memo` is required on chains like XRP, Cosmos, Stellar, BNB Beacon — omitting it can make funds unrecoverable.

## Minimum Order Sizes

Most providers enforce a minimum (typically ~$20 USD). When no provider meets the request, the gateway returns an empty quote list (`[]`) rather than an error — try a higher amount.

## Asset IDs

Same format as elsewhere in `twak`:

- Native: `c{coinId}` — e.g. `c60` (ETH), `c0` (BTC), `c501` (SOL), `c20000714` (BNB)
- ERC-20: `c{coinId}_t{contractAddress}` — e.g. `c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` (USDC on Ethereum)

Run `twak chains --json` for chain keys and coin IDs (the non-JSON table omits coin IDs).
