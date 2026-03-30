
# DCA & Limit Order Automations

Create recurring swaps (DCA) or conditional one-time swaps (limit orders) that execute automatically via `twak watch`.

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
  --interval 7d \
  --json
```

Intervals: `30s`, `1m`, `5m`, `1h`, `6h`, `12h`, `24h`, `7d`, `30d` (minimum 5s).

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

## List Automations

```bash
twak automate list --json
```

## Pause / Resume / Delete

```bash
twak automate pause <id>
twak automate resume <id>
twak automate delete <id>
```

## Execute Automations

Automations run when `twak watch` is active. The watcher polls prices and executes automations whose conditions are met.

```bash
twak watch                    # polls every 60s, executes DCA + limit orders
twak watch --interval 5m     # custom poll interval
twak watch --dry-run         # check conditions without executing
twak watch --json            # structured output
```

## Storage

Automations are stored in `~/.twak/automations.json`. Each entry includes:
- `id` — unique identifier
- `type` — `dca` or `limit`
- `status` — `active`, `paused`, or `completed`
- `fromToken`, `toToken`, `chain`, `amount`
- `interval` (DCA) or `targetPrice` + `condition` (limit)
- `lastExecuted`, `executionCount`
