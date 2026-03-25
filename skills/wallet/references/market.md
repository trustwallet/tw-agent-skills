
# Market Data

Query token prices, trending tokens by category, and featured DApps. All commands support `--json`.

## Token Price

Chain is auto-detected from native token symbols:

```bash
twak price ETH --json
twak price BNB --json                          # auto-detects bsc
twak price SOL --json
twak price USDC --chain ethereum --json
```

## Trending Tokens

Get trending tokens by market activity, filterable by category:

```bash
twak trending --json
twak trending --limit 50 --json

# By category
twak trending --category ai --json             # AI tokens
twak trending --category memes --json           # Meme coins
twak trending --category defi --json            # DeFi protocols
twak trending --category rwa --json             # Real World Assets
twak trending --category dex --json             # DEX tokens

# By ecosystem
twak trending --category sol --json             # Solana ecosystem
twak trending --category eth --json             # Ethereum ecosystem
twak trending --category bnb --json             # BNB ecosystem
twak trending --category layer1 --json          # L1 chains

# Binance listings
twak trending --category launchpad --json
twak trending --category launchpool --json

# High-volume memes
twak trending --category pumpfun --json
twak trending --category bonk --json

# Override sort (price_change | market_cap | volume)
twak trending --category memes --sort volume --limit 10 --json
```

## DApps & Protocols

Browse featured DApps and on-chain protocols:

```bash
twak dapps --json
twak dapps --category defi --json
twak dapps --category dex --json
twak dapps --category nft --json
twak dapps --category lending --json
twak dapps --category gaming --json
```

## Token Search

```bash
twak search "USDC" --limit 10 --json
twak search "pepe" --json
```

## Asset Info

```bash
twak asset c60 --json
twak asset c501 --json
```
