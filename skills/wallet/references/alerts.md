
# Price Alerts

Set up price alerts that trigger when tokens reach target prices. Alerts are stored locally and checked on demand or by the watcher.

## Create an Alert

Accepts token symbols (auto-detects chain for native tokens) or asset IDs:

```bash
twak alert create --token ETH --above 5000 --json
twak alert create --token BTC --below 50000 --json
twak alert create --token USDC --chain bsc --above 1.1 --json
twak alert create --token c60 --chain ethereum --below 2000 --json
```

## List Alerts

```bash
twak alert list --json
twak alert list --active --json
```

## Check Alerts

Check active alerts against current prices:

```bash
twak alert check --json
```

## Delete an Alert

```bash
twak alert delete <alertId>
```

## Continuous Monitoring

Use `twak watch` to continuously poll alerts and execute DCA/limit order automations:

```bash
twak watch                    # polls every 60s
twak watch --interval 5m     # custom interval
twak watch --dry-run         # check conditions without executing
```

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
