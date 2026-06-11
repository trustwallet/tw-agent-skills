
# Price Alerts

Set up price alerts that trigger when tokens reach target prices. Alerts are stored locally in `~/.twak/alerts.json` and checked on demand or by the watcher.

Alerts are **one-shot**: when an alert triggers (via `alert check` or `twak watch`), it is deactivated — `active` becomes `false` and `triggeredAt` is set. It is not deleted.

## Create an Alert

Accepts token symbols (auto-detects chain for native tokens) or asset IDs:

```bash
twak alert create --token ETH --above 5000 --json
twak alert create --token BTC --below 50000 --json
twak alert create --token USDC --chain bsc --above 1.1 --json
twak alert create --token c60 --chain ethereum --below 2000 --json
```

Exactly one of `--above` or `--below` is required — both or neither is a `VALIDATION_ERROR`. The price must be a positive number.

Output: the full alert record `{ id, tokenId, chainKey, condition, targetPrice, createdAt, active }` (`condition` is `above` or `below`; triggered records also carry `triggeredAt`).

## List Alerts

```bash
twak alert list --json
twak alert list --active --json
```

Output: array of alert records, each enriched with `tokenLabel` (resolved symbol) and `chainLabel` (chain key). `active: false` means the alert already triggered.

## Check Alerts

Check active alerts against current prices:

```bash
twak alert check --json
```

Output: `{ checked, triggered, alerts }` — `checked` and `triggered` are counts; `alerts` contains the triggered records, each with `currentPrice` added. Triggered alerts are deactivated (one-shot).

## Delete an Alert

```bash
twak alert delete <alertId> --json
```

Output: `{ "success": true }`. Unknown id → `ALERT_NOT_FOUND`.

## Errors

On failure, alert commands emit `{ error, errorCode }` on stdout (with `--json`) and exit with code 1. Error codes:

- `VALIDATION_ERROR` — both/neither of `--above`/`--below`, non-positive price, or token that can't be resolved without `--chain` (create)
- `CHAIN_UNSUPPORTED` — unknown chain key (create)
- `TOKEN_NOT_FOUND` — unknown token symbol on the given chain (create)
- `ALERT_NOT_FOUND` — unknown alert id (delete)

## Continuous Monitoring

Use `twak watch` to continuously poll alerts and execute DCA/limit order automations:

```bash
twak watch                    # polls every 60s
twak watch --interval 5m     # custom interval
twak watch --dry-run         # check conditions without executing
twak watch --json            # structured JSON output per tick
```

`--interval` accepts `<number><s|m|h|d>` (e.g. `30s`, `5m`, `1h`, `1d`); a bare number means seconds. Minimum 5 seconds.

Other flags: `--password <password>` (wallet password for executing swaps; falls back to the `TWAK_WALLET_PASSWORD` env var, then the OS keychain) and `--auto-lock <minutes>` (lock the wallet after N minutes of inactivity).

See `references/automations.md` for DCA and limit order setup.

## Token IDs

- Native: `c{coinId}` (e.g., `c60` for ETH, `c501` for SOL)
- Token: `c{coinId}_t{address}`

## Common Coin IDs

| Chain | coinId | Symbol |
|-------|--------|--------|
| Ethereum | 60 | ETH |
| BSC | 20000714 | BNB |
| Solana | 501 | SOL |
| Polygon | 966 | MATIC |
| Bitcoin | 0 | BTC |
