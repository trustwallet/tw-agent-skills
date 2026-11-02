
# DCA & Limit Order Automations

Create recurring swaps (DCA) or conditional one-time swaps (limit orders) that execute automatically via `twak watch`.

**Important:** Automations only execute while a watcher is polling — either a standalone `twak watch` process, or an MCP server started with `twak serve --watch`. Without one, rules are saved but never fire. If the watcher is stopped, automations are paused until it is started again.

`automate add` requires exactly one of `--interval` (creates a DCA) or `--price` (creates a limit order) — both or neither is a `VALIDATION_ERROR`. Only EVM chains and Solana are supported; any other chain is rejected with `CHAIN_UNSUPPORTED` ("Use an EVM chain or Solana."). `--amount` must be a positive number.

Output of `add`: the full automation record (see Storage below; `runCount` starts at 0).

## Create a DCA Automation

Dollar-cost averaging — swap a fixed amount of the source token (`--from`) on a recurring schedule. `--amount` is always denominated in the source token.

```bash
twak automate add \
  --from BNB --to USDC \
  --chain bsc \
  --amount 0.01 \
  --interval 24h \
  --json

twak automate add \
  --from ETH --to USDC \
  --chain ethereum \
  --amount 0.005 \
  --interval 1h \
  --max-runs 10 \
  --json
```

Intervals accept `<number><s|m|h|d>` (e.g. `30s`, `5m`, `1h`, `7d`); decimals are allowed and a bare number means seconds. Minimum 5s.

## Create a Limit Order

One-time swap that executes when the destination token's USD spot price meets a condition.

`--condition` values:
- `below` (default) — executes when price <= target (buy the dip)
- `above` — executes when price >= target (take profit)

`--price` is the target USD price of the destination token (`--to`). `--amount` is in the source token (`--from`).

```bash
# Buy ETH when it drops below $1800 (spend 100 USDC)
twak automate add \
  --from USDC --to ETH \
  --chain ethereum \
  --amount 100 \
  --price 1800 \
  --json

# Sell BNB for USDT when BNB rises above $700
twak automate add \
  --from BNB --to USDT \
  --chain bsc \
  --amount 0.1 \
  --price 700 \
  --condition above \
  --json
```

## Optional Flags

| Flag | Description |
|------|-------------|
| `--max-runs <n>` | Stop after N executions (positive integer). Automation deactivates automatically. |
| `--expires <date>` | Expiry date in ISO 8601 format (e.g. `2026-04-01`). Automation deactivates after this date. |
| `--chain <chain>` | Chain key (default: `ethereum`). |
| `--json` | Structured JSON output. |

## List Automations

```bash
twak automate list --json
```

Output: array of automation records, each enriched with computed `nextRunAt` (ISO timestamp) and `nextRunIn` (e.g. `in 3h`, `overdue`). Both are populated for DCA automations only and are `null` for limit orders.

## Pause / Resume / Delete

```bash
twak automate pause <id> --json
twak automate resume <id> --json
twak automate delete <id>
```

`pause`/`resume` output the updated automation record. `delete` emits **no JSON on success** even with `--json` — the confirmation goes to stderr only; errors still emit `{ error, errorCode }` on stdout. Unknown id → `AUTOMATION_NOT_FOUND`.

When a limit order fires, it is deactivated (`active: false`), not deleted — `automate resume <id>` re-arms it.

## Errors

On failure, automate commands emit `{ error, errorCode }` on stdout (with `--json`) and exit with code 1. Error codes:

- `VALIDATION_ERROR` — `--interval`/`--price` both or neither, non-positive `--amount`, interval below 5s, non-positive-integer `--max-runs`, invalid `--expires` date
- `CHAIN_UNSUPPORTED` — unknown chain, a testnet chain, or a chain swaps cannot start on: twak signs swap transactions on EVM chains and Solana only (add)
- `AUTOMATION_NOT_FOUND` — unknown automation id (delete/pause/resume)

## Execute Automations

Automations run when `twak watch` is active. The watcher polls prices and executes automations whose conditions are met.

```bash
twak watch                    # polls every 60s, executes DCA + limit orders
twak watch --interval 5m     # custom poll interval
twak watch --dry-run         # check conditions without executing
twak watch --json            # structured output
```

`--interval` accepts `<number><s|m|h|d>`; a bare number means seconds. Minimum 5 seconds. `--auto-lock <minutes>` locks the wallet after N minutes of inactivity.

`watch` requires the wallet password to execute swaps. Resolution order: `--password <password>` flag → `TWAK_WALLET_PASSWORD` env var → OS keychain.

## Running under the MCP server

When driving twak over MCP (`twak serve`), automations created with the `create_automation` action only execute if the server was launched with `--watch`.

```bash
twak serve --watch                      # polls every 60s by default
twak serve --watch --watch-interval 5m  # custom poll interval
```

Without `--watch` (or a separate `twak watch` process), automations are saved but never fire.

- Automations execute using the local agent wallet; the watcher stays idle in WalletConnect mode, where each swap needs interactive approval.
- To execute a saved automation once immediately, use the `run_automation_now` action.
- Don't run both `twak serve --watch` and `twak watch` against the same wallet / `automations.json` — both loops would fire the same automation.

## Storage

Automations are stored in `automations.json` in the twak folder. A stored automation whose chain is no longer supported is skipped and reported as a warning (stderr for `automate list`, the watcher log). Each entry includes:
- `id` — unique identifier
- `type` — `dca` or `limit`
- `active` — whether the automation is currently enabled
- `fromToken`, `toToken`, `chain`, `amount`
- `intervalMs` (DCA) or `targetPrice` + `condition` (limit)
- `lastRunAt`, `runCount`
- `maxRuns`, `expiresAt` (optional)
