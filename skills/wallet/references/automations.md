
# DCA & Limit Order Automations

Create recurring swaps (DCA) or conditional one-time swaps (limit orders) that execute automatically via `twak watch`.

## Create a DCA Automation

Dollar-cost averaging — swap a fixed amount on a recurring schedule.

```bash
twak automate add \
  --type dca \
  --from-token BNB --to-token USDC \
  --chain bsc \
  --amount 0.01 \
  --interval 24h \
  --json

twak automate add \
  --type dca \
  --from-token ETH --to-token USDC \
  --chain ethereum \
  --amount 0.005 \
  --interval 7d \
  --json
```

Intervals: `1h`, `6h`, `12h`, `24h`, `7d`, `30d`.

## Create a Limit Order

One-time swap that executes when price reaches a target.

```bash
twak automate add \
  --type limit \
  --from-token USDC --to-token ETH \
  --chain ethereum \
  --amount 100 \
  --target-price 1800 \
  --json

twak automate add \
  --type limit \
  --from-token USDC --to-token BNB \
  --chain bsc \
  --amount 50 \
  --target-price 400 \
  --condition below \
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
