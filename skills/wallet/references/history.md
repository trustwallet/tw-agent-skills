
# Transaction History

Query transaction history and look up individual transactions with explorer URLs.

## Prerequisites

- Authenticated (`twak auth status`)

## Transaction History

Defaults to the last 30 days:

```bash
twak history --address <addr> --chain ethereum --limit 20 --json
twak history --address <addr> --chain solana --json
twak history --address <addr> --chain bsc --from 2025-01-01 --to 2025-02-01 --json
```

## Transaction Details

Look up a specific transaction by hash (includes explorer URL):

```bash
twak tx <hash> --chain ethereum --json
twak tx <hash> --chain solana --json
```

## Own Wallet History

If `--address` is omitted and an agent wallet exists, the address is auto-detected:

```bash
twak history --chain ethereum --json                    # auto-detects wallet address
twak history --chain ethereum --json --password <pw>    # explicit password if no keychain
```

## Options

### `history`
- `--address <addr>` — Wallet address (auto-detected from agent wallet if omitted)
- `--chain <chainKey>` — Chain key (omit for bulk history across all chains)
- `--limit <n>` — Max results (default: 20)
- `--from <date>` — Start date (YYYY-MM-DD)
- `--to <date>` — End date (YYYY-MM-DD)
- `--password <pw>` — Wallet password (for auto-detecting address when `--address` is omitted)
- `--json` — Output as JSON

### `tx`
- First argument: transaction hash (required)
- `--chain <chainKey>` — Chain key (required)
- `--json` — Output as JSON
