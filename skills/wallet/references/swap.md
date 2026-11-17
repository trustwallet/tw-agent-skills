
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
- `--slippage <pct>` — Slippage tolerance in percent (default: 1). A plain decimal such as `1` or `0.5` (`VALIDATION_ERROR` otherwise). Above the user's maximum (`twak config` `max-slippage`, default 10) a swap is refused with `SLIPPAGE_EXCEEDED` before the password is asked for; above 50 even a quote is refused. Above 5 a stderr warning is printed. Do not raise the maximum unless the user asks (`references/limits.md`).
- `--decimals <n>` — Source token decimals, only for a token twak does not know (registry, then Trust token search); rejected with `VALIDATION_ERROR` if it contradicts them
- `--usd <amount>` — Swap a USD-equivalent amount of the source token (e.g. `twak swap ETH USDC --usd 100`); fails with `TOKEN_NOT_FOUND` if the token has no USD price, `NETWORK_ERROR` if the price lookup fails
- `--max-usd <n>` — USD limit for this command only (default: `TWAK_MAX_USD`, then `twak config set max-usd`, then 10000). Never pass it unless the user asks.
- `--skip-safety-check` — Skip the USD limit for this command. Never pass it unless the user asks.
- `--quote-only` — Get quote without executing
- `--password <pw>` — Wallet password (resolution order: `--password` → `TWAK_WALLET_PASSWORD` → OS keychain)
- `--json` — Output as JSON

## Token Resolution

Use token symbols (ETH, USDC, USDT, DAI, WETH, WBTC, SOL, BONK, JUP) or contract addresses. The CLI resolves symbols to addresses automatically.

Asset IDs are also accepted: `c{coinId}` for native coins (e.g. `c60` = ETH) and `c{coinId}_t{contractAddress}` for tokens (e.g. `c60_t0xdAC17F958D2ee523a2206206994597C13D831ec7` = USDT on Ethereum). An asset-ID **source** token overrides `--chain` with the chain derived from its coin ID; an asset-ID **destination** token overrides `--to-chain` the same way, but only when `--to-chain` is passed — without `--to-chain` the destination chain is always the source chain. An unrecognized coin ID fails with `CHAIN_UNSUPPORTED`.

## JSON Output

With `--json`, stdout carries **only** the JSON object — all status/progress messages (USD conversion, approval/swap tx links, high-slippage warning) go to stderr, so `twak swap … --json | jq` is safe.

Quote (`--quote-only`): `{ input, output, minReceived?, provider, priceImpact, networkFee?, steps }`

- `input` / `output` — formatted strings with symbol, e.g. `"1.0 ETH"`, `"2543.21 USDC"`
- `minReceived` — formatted string; omitted when the route has no min-amount-out
- `provider` — provider names joined with `" → "` for multi-step routes, e.g. `"1inch"` or `"Stargate → 1inch"`
- `priceImpact` — string
- `networkFee` — formatted string, multiple step fees joined with `" + "` (e.g. `"0.001 ETH + 0.002 BNB"`); omitted when no step reports a fee
- `steps` — number of route steps

Execute success: same keys as the quote, plus `{ hash, fromChain, toChain, explorer }` — `hash` is the swap transaction hash, `explorer` is the block-explorer URL.

Error: `{ error, errorCode }` on stdout, exit code 1.

## Error Codes

- `VALIDATION_ERROR` — bad/missing amount, both `<amount>` and `--usd` given, a `--slippage` that is not a positive plain decimal, non-positive `--usd`
- `SLIPPAGE_EXCEEDED` — `--slippage` above the user's maximum (default 10; at most 50)
- `USD_LIMIT_EXCEEDED` — the swap is worth more than the user's USD limit (default $10,000)
- `USD_VALUE_UNVERIFIED` — twak cannot value the source token (no price, or `--decimals` supplied) and the user has not allowed unverified values
- `CHAIN_UNSUPPORTED` — unknown chain or unknown coin ID in an asset-ID token, a testnet chain, or a source chain twak cannot sign swaps for (only EVM chains and Solana; `--quote-only` still quotes any route)
- `TOKEN_NOT_FOUND` — token symbol not resolvable on the chain, or no USD price for `--usd`
- `NETWORK_ERROR` — a price or token lookup failed; retry
- `NO_ROUTES` — no swap routes found for the pair
- `INSUFFICIENT_BALANCE` — on-chain execution failed for insufficient funds
- `TX_FAILED` — transaction failed on-chain or was not confirmed in time
- `APPROVAL_SENT_SWAP_FAILED` — the ERC-20 approval tx was broadcast but the swap itself failed; the approval tx hash is included in `error`. Check the allowance before retrying
- `UNKNOWN_ERROR` — unclassified failure (last resort)

## Approvals

ERC-20 approvals are handled automatically during execution — no separate approve step is needed. The executor signs and broadcasts any `revokeApproval`/`approval` transactions returned by the routing API before the swap tx, and when none are returned it checks the on-chain allowance for the route's operator and auto-approves if it falls short. Each approval is confirmed (up to 60s) before the swap tx is sent (confirmed up to 120s). Approval tx links are logged to stderr.

## Chain Key vs Chain ID

Prefer chain keys for `--chain` arguments (e.g., `bsc`, `ethereum`, `base`); aliases, CAIP-2 IDs (`eip155:56`) and EVM chain IDs (`56`) are accepted too. Outputs always name the chain by its key. Run `twak chains` for valid keys.

## Supported Chains

Ethereum, Arbitrum, Optimism, Polygon, BSC, Avalanche, Base, Fantom, Linea, Scroll, zkSync, Blast, Sonic, Celo, Aurora, Solana.
