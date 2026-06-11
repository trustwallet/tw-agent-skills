
# Token Swap

Execute same-chain or cross-chain token swaps via Trust Wallet. Supports all EVM chains and Solana.

## Prerequisites

- Authenticated (`twak auth status`)
- Agent wallet created (`twak wallet create --password <pw>`)

## Safety: Always Quote First

Always get a quote before executing to confirm rates and price impact:

```bash
# By amount: twak swap <amount> <from> <to>
twak swap 1 ETH USDC --chain ethereum --quote-only --json
twak swap 10 SOL USDC --chain solana --quote-only --json
twak swap 100 USDC USDC --chain ethereum --to-chain arbitrum --quote-only --json

# By USD value: twak swap <from> <to> --usd <amount>
twak swap ETH USDC --chain ethereum --usd 100 --quote-only --json
```

Only execute after the user confirms the quote. `--quote-only` needs no wallet or password.

## Execute a Swap

Password resolution order: `--password` flag → `TWAK_WALLET_PASSWORD` env var → OS keychain. Passing `--password` prints a stderr warning (visible in shell history); prefer the env var or keychain:

```bash
# Same-chain EVM
twak swap 1 ETH USDC --chain ethereum --json

# Solana
twak swap 5 SOL BONK --chain solana --json

# Cross-chain (Ethereum → Arbitrum)
twak swap 100 USDC USDC --chain ethereum --to-chain arbitrum --json

# Cross-chain (ETH → BSC)
twak swap 0.01 ETH BNB --chain ethereum --to-chain bsc --json
```

## Options

- `--chain <key>` — Source chain (default: ethereum)
- `--to-chain <key>` — Destination chain for cross-chain swaps
- `--slippage <pct>` — Slippage tolerance % (default: 1). Must be a positive number (`VALIDATION_ERROR` otherwise); values above 50 are rejected with `SLIPPAGE_EXCEEDED`; values above 5 emit a stderr warning but proceed
- `--decimals <n>` — Source token decimals (overrides auto-resolution for tokens not in the registry)
- `--usd <amount>` — Swap a USD-equivalent amount of the source token (e.g. `twak swap ETH USDC --usd 100`); fails with `NETWORK_ERROR` if the token price can't be fetched
- `--quote-only` — Get quote without executing
- `--password <pw>` — Wallet password (resolution order: `--password` → `TWAK_WALLET_PASSWORD` → OS keychain)
- `--json` — Output as JSON

## Token Resolution

Use token symbols (ETH, USDC, USDT, DAI, WETH, WBTC, SOL, BONK, JUP) or contract addresses. The CLI resolves symbols to addresses automatically.

Asset IDs are also accepted: `c{coinId}` for native coins (e.g. `c60` = ETH) and `c{coinId}_t{contractAddress}` for tokens (e.g. `c60_t0xdAC17F958D2ee523a2206206994597C13D831ec7` = USDT on Ethereum). An asset-ID **source** token overrides `--chain` with the chain derived from its coin ID; an asset-ID **destination** token overrides `--to-chain` the same way, but only when `--to-chain` is passed — without `--to-chain` the destination chain is always the source chain. An unrecognized coin ID fails with `CHAIN_UNSUPPORTED`.

## JSON Output

With `--json`, stdout carries **only** the JSON object — all status/progress messages (USD conversion, approval/swap tx links, high-slippage warning) go to stderr, so `twak swap … --json | jq` is safe.

Quote (`--quote-only`): `{ input, output, minReceived?, provider, priceImpact, networkFee?, steps? }`

- `input` / `output` — formatted strings with symbol, e.g. `"1.0 ETH"`, `"2543.21 USDC"`
- `minReceived` — formatted string; omitted when the route has no min-amount-out
- `provider` — provider names joined with `" → "` for multi-step routes, e.g. `"1inch"` or `"Stargate → 1inch"`
- `priceImpact` — string
- `networkFee` — formatted string, multiple step fees joined with `" + "` (e.g. `"0.001 ETH + 0.002 BNB"`); omitted when no step reports a fee
- `steps` — number of route steps; only present for multi-step routes (> 1)

Execute success: same keys as the quote, plus `{ hash, fromChain, toChain, explorer }` — `hash` is the swap transaction hash, `explorer` is the block-explorer URL.

Error: `{ error, errorCode }` on stdout, exit code 1.

## Error Codes

- `VALIDATION_ERROR` — bad/missing amount, both `<amount>` and `--usd` given, non-positive `--slippage` or `--usd`
- `SLIPPAGE_EXCEEDED` — `--slippage` above 50
- `CHAIN_UNSUPPORTED` — unknown chain key or unknown coin ID in an asset-ID token
- `TOKEN_NOT_FOUND` — token symbol not resolvable on the chain
- `NETWORK_ERROR` — price fetch failed for `--usd`
- `NO_ROUTES` — no swap routes found for the pair
- `INSUFFICIENT_BALANCE` — on-chain execution failed for insufficient funds
- `TX_FAILED` — transaction failed on-chain or was not confirmed in time
- `APPROVAL_SENT_SWAP_FAILED` — the ERC-20 approval tx was broadcast but the swap itself failed; the approval tx hash is included in `error`. Check the allowance before retrying
- `UNKNOWN_ERROR` — unclassified failure (last resort)

## Approvals

ERC-20 approvals are handled automatically during execution — no separate approve step is needed. The executor signs and broadcasts any `revokeApproval`/`approval` transactions returned by the routing API before the swap tx, and when none are returned it checks the on-chain allowance for the route's operator and auto-approves if it falls short. Each approval is confirmed (up to 60s) before the swap tx is sent (confirmed up to 120s). Approval tx links are logged to stderr.

## Chain Key vs Chain ID

Always use the **map key** for `--chain` arguments (e.g., `bsc`, `ethereum`, `base`). BSC uses `chain.id = smartchain` internally — the CLI handles this automatically. Run `twak chains` for valid keys.

## Supported Chains

Ethereum, Arbitrum, Optimism, Polygon, BSC, Avalanche, Base, Fantom, Linea, Scroll, zkSync, Blast, Sonic, Celo, Aurora, Solana.
