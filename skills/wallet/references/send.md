
# Send Tokens

Transfer native tokens or ERC-20 tokens across supported chains. Supports ENS names and human-readable addresses. Keys remain local — signing happens on-device.

## Prerequisites

- Authenticated (`twak auth status`)
- Agent wallet created (`twak wallet create --password <pw>`)

## Safety: Always Verify Before Sending

1. Confirm the destination address is correct
2. Check balance before sending
3. Start with a small test transfer for new addresses

## Steps

1. Check wallet address on the target chain:
   ```bash
   twak wallet address --chain <chainKey> --json
   ```

2. Check balance:
   ```bash
   twak wallet balance --chain <chainKey> --json
   ```

3. Execute the transfer:
   ```bash
   twak transfer --to <address> --amount <n> --token <assetId> --json
   ```

Password resolution order: `--password` flag → `TWAK_WALLET_PASSWORD` env var → OS keychain. Fails with an error if none is set. Passing `--password` prints a shell-history warning to stderr.

Success output: `{ hash, chain, from, to, amount, token, explorer }` — `hash` is the transaction hash, `chain` the resolved chain key, `to` the resolved destination address, `amount` echoes the input string, `token` is the resolved asset ID (`c{coinId}` or `c{coinId}_t0x…` form, even when you passed `--chain` + contract address), `explorer` is the explorer tx URL or `''` when the chain has no explorer mapping.

## Selecting the chain & token

Two equivalent ways to specify what to send:

1. **By asset ID** (default) — `--token <assetId>`, no `--chain`. The chain is derived from the asset ID's coin ID:
   ```bash
   twak transfer --to 0x… --amount 1.5 --token c60 --json                  # native ETH
   twak transfer --to 0x… --amount 100 --token c60_t0xA0b8…eB48 --json      # USDC on Ethereum
   ```

2. **By chain key** — `--chain <key>` plus an optional bare token contract address (omit `--token` for the native coin):
   ```bash
   twak transfer --to 0x… --amount 1.5 --chain base --json                          # native coin on Base
   twak transfer --to 0x… --amount 100 --chain base --token 0x833589…2913 --json    # token by address on Base
   ```

Do not combine an asset ID with `--chain` (e.g. `--chain base --token c60`) — that is rejected. Use one form or the other.

## ENS & Human-Readable Names

Any `--to` value containing a dot is resolved via Trust's naming API (naming.trustwallet.com) — this covers ENS-style names (`.eth`, `.crypto`, …) but is not an on-chain ENS lookup. Resolution failure → `ENS_NOT_FOUND`.

```bash
twak transfer --to vitalik.eth --amount 0.01 --token c60 --json
twak transfer --to myname.crypto --amount 100 --token c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 --json
```

`--confirm-to <address>` pins the expected resolved address: if resolution changed the address and the result differs from the pin (case-insensitive compare), the transfer fails with `ENS_MISMATCH`. The pin is only checked when resolution actually changed the input — passing a raw `0x…` address with a non-matching `--confirm-to` is not rejected.

## Amount Format

Amounts are human-readable (not smallest unit):

```bash
--amount 1.5       # 1.5 ETH
--amount 100       # 100 USDC
--amount 0.001     # 0.001 BTC
```

Decimals resolution order: `--decimals` override → token-search result → known-token registry. If none yields a value, the transfer fails with `VALIDATION_ERROR` ("Could not determine decimals…") — pass `--decimals <n>` for tokens the search/registry doesn't know. Decimals are never silently defaulted to 18.

## Asset IDs

- Native tokens: `c{coinId}` (e.g., `c60` for ETH, `c20000714` for BNB, `c501` for SOL)
- ERC-20 tokens: `c{coinId}_t{contractAddress}`

## Options

- `--to <address>` — Destination address or ENS name (required)
- `--amount <n>` — Amount in human-readable format (required)
- `--token <assetIdOrAddress>` — Without `--chain`: the asset ID (e.g. `c60`, `c60_t0x…`) — required in this form. With `--chain`: a bare token contract address (`0x…`); omit it to send the native coin.
- `--chain <key>` — Chain key (e.g. `base`, `ethereum`, `bsctestnet`). When set, `--token` is a token contract address. See **Selecting the chain & token** above.
- `--decimals <n>` — Token decimals override (non-negative integer); use when auto-resolution fails for tokens not in the registry
- `--confirm-to <address>` — Pin the expected resolved address. Rejected with `ENS_MISMATCH` only when name resolution changed the address and the result differs from the pin.
- `--max-usd <n>` — Maximum allowed transfer value in USD (default: 10000). Exceeding it fails with `USD_LIMIT_EXCEEDED`.
- `--skip-safety-check` — Bypass the USD value safety check
- `--password <pw>` — Wallet password (falls back to `TWAK_WALLET_PASSWORD` env var, then OS keychain)
- `--json` — Output as JSON

## USD Safety Check

Unless `--skip-safety-check` is set, the transfer's USD value is estimated from a price lookup. If it exceeds `--max-usd`, the transfer fails with `USD_LIMIT_EXCEEDED`. If the price lookup fails or returns 0, the check is **silently skipped** (a warning goes to stderr only) and the transfer proceeds — do not rely on `--max-usd` as a hard gate for tokens without price data. Values over $1000 print a high-value warning to stderr.

## Errors

With `--json`, errors emit a single `{ error, errorCode }` object to stdout and exit with code 1.

| errorCode | Trigger |
|---|---|
| `VALIDATION_ERROR` | Asset ID combined with `--chain`; missing `--token` without `--chain`; malformed token ID; non-positive `--amount` or `--max-usd`; bad `--decimals`; decimals could not be determined |
| `CHAIN_UNSUPPORTED` | Unknown `--chain` key, or unsupported coin ID in the asset ID |
| `ENS_NOT_FOUND` | Dotted `--to` name could not be resolved |
| `ENS_MISMATCH` | Resolved address differs from `--confirm-to` pin |
| `TOKEN_NOT_FOUND` | Token could not be resolved on the target chain |
| `USD_LIMIT_EXCEEDED` | Estimated USD value exceeds `--max-usd` |
| `INSUFFICIENT_BALANCE` | Broadcast rejected for insufficient funds |
| `NETWORK_ERROR` | Network/connection failure during broadcast |
| `BROADCAST_FAILED` | RPC/broadcast rejected the transaction |
| `SIGN_FAILED` | Signing failed |
| `RATE_LIMITED` | API returned HTTP 429 |

## Supported Chains

Run `twak chains` for all supported chains and coin IDs.

## BSC Testnet

`--chain bsctestnet` targets BSC testnet (chain ID 97). This testnet key is intentionally **not** listed by `twak chains` — it is enabled only for a limited set of operations: native (tBNB) and ERC-20 transfers, ERC-20 approve/balance, and ERC-8004 / ERC-8183 contract calls. Swaps, portfolio, market data, and onramp stay mainnet-only.

```bash
# Native tBNB transfer
twak transfer --to 0x… --amount 0.01 --chain bsctestnet --json

# ERC-20 token transfer (token by contract address)
twak transfer --to 0x… --amount 1 --chain bsctestnet --token 0x… --json
```

The testnet wallet address is the same as the mainnet BSC address (`twak wallet address --chain bsc`); fund it from a BSC testnet faucet. Note: `twak wallet balance --chain bsctestnet` is **not** supported (the CLI balance command reads a mainnet data gateway). To read testnet balances, use the MCP `token_balance` tool with `chain: "bsctestnet"`, which queries the testnet RPC directly.
