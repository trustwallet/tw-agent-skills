
# Transaction History

Query transaction history and look up individual transactions by hash.

On error, both commands emit `{ error, errorCode }` on stdout (with `--json`) and exit with code 1. Unknown `--chain` values → `CHAIN_UNSUPPORTED`.

## Prerequisites

- Authenticated (`twak auth status`)

## Transaction History

Defaults to the last 30 days:

```bash
twak history --address <addr> --chain ethereum --limit 20 --json
twak history --address <addr> --chain solana --json
twak history --address <addr> --chain bsc --from 2025-01-01 --to 2025-02-01 --json
```

Single-chain rows may include a computed `usdValue` field (native amount × current price; omitted when not computable).

## Transaction Details

Look up a specific transaction by hash:

```bash
twak tx <hash> --chain ethereum --json
twak tx <hash> --chain solana --json
```

Two output shapes depending on whether a wallet address is available:

- Wallet available (`--address` given, or agent wallet unlocks): on-chain RPC lookup → `{ hash, chain, confirmed, pending, failed, error?, meta? }`
- No wallet: txhub API fallback → `{ id, hash, chain, type, status, from, to, amount, fee, date, metadata? }`

## Own Wallet History

Single-chain mode (`--chain` given): if `--address` is omitted, the address is auto-detected from the agent wallet:

```bash
twak history --chain ethereum --json                    # auto-detects wallet address
twak history --chain ethereum --json --password <pw>    # explicit password if no keychain
```

Bulk mode (no `--chain`): queries all chains using addresses derived from the stored agent wallet — requires a wallet and password, and `--address` is IGNORED. To query an arbitrary address, always pass `--chain`.

## Options

### `history`
- `--address <addr>` — Wallet address (single-chain mode only; auto-detected from agent wallet if omitted; ignored in bulk mode)
- `--chain <chainKey>` — Chain key (omit for bulk history across all chains)
- `--limit <n>` — Max results (default: 20)
- `--from <date>` — Start date (YYYY-MM-DD)
- `--to <date>` — End date (YYYY-MM-DD)
- `--password <pw>` — Wallet password (for deriving addresses when `--address` is omitted or in bulk mode)
- `--json` — Output as JSON

### `tx`
- First argument: transaction hash (required)
- `--chain <chainKey>` — Chain key (required)
- `--address <addr>` — Wallet address for the on-chain lookup (auto-detected from agent wallet if omitted; without either, falls back to the txhub record)
- `--password <pw>` — Wallet password (for auto-detecting address)
- `--json` — Output as JSON
