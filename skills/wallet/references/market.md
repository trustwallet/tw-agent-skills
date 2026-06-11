
# Market Data

Query token prices, trending tokens by category, and featured DApps. All commands support `--json`.

On error, all commands emit `{ error, errorCode }` on stdout (with `--json`) and exit with code 1.

## Token Price

```bash
twak price ETH --json
twak price BNB --json                          # auto-detects bsc
twak price SOL --json
twak price USDC --chain ethereum --json
```

Output: `{ token, chain, priceUsd }`

Chain auto-detect (when `--chain` is omitted), in order: token matches a chain name (e.g. `solana`) → token matches a chain's native symbol (ETH→ethereum, BNB→bsc) → token is a well-known token mapped to its home chain (OP→optimism, ARB→arbitrum) → silently defaults to `ethereum`. Pass `--chain` explicitly for tokens on other chains. Unknown `--chain` → `CHAIN_UNSUPPORTED`.

### Price History

```bash
twak price ETH --history --json          # default period: week
twak price BNB --history month --json    # hour, day, week, month, year, all
```

Adds a `history` array of `{ price, date }` to the output: `{ token, chain, priceUsd, history }`.

### Batch Prices

Comma-separated tokens fetch in one call:

```bash
twak price ETH,BNB,SOL,USDC --json
```

Output: array of `{ token, chain, priceUsd }` — `priceUsd` is `null` for tokens the price API couldn't resolve.

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

Results are deduplicated by symbol — when the same symbol appears multiple times, the entry with the highest market cap is kept.

## DApps & Protocols

Browse DeFi protocols and DApps (data from DeFi Llama):

```bash
twak dapps --json                                # top by TVL
twak dapps --categories --json                   # list available category names
twak dapps --category Lending --json
twak dapps --category "Liquid Staking" --json
twak dapps --search aave --json                  # search by name, symbol, or category
twak dapps --limit 50 --json
```

- `--category <name>` — Case-insensitive SUBSTRING match against DeFi Llama category names, NOT an enum. Beware: `defi` matches only the "CeDeFi" category. Use real category names — e.g. Lending, Dexs, Liquid Staking, Bridge, Yield — and run `twak dapps --categories` to list all available values.
- `--search <query>` — Matches name substring, exact symbol, or category substring
- `--categories` — List available category names
- `--limit <n>` — Max results (default: 20)

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
