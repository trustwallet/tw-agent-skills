---
description: Get real-time token prices and discover trending tokens across 16+ categories (AI, DeFi, memes, Layer 1, ecosystem-specific). Use this whenever someone asks about crypto prices, market cap, volume, trending coins, top tokens in a category, or any "what's the price of X" question. Also covers price changes across multiple timeframes (1h to 90d).
---

# Market Data

Real-time token prices, trending asset discovery, and category-based rankings.

## Get Token Prices — `POST /v2/market/tickers`

**Base URL:** `https://tws.trustwallet.com`
**Auth:** HMAC-SHA256 (run `/setup` first)

Get current USD prices for up to 50 tokens at once. Prices are an index aggregated from CoinMarketCap and CoinGecko.

```json
{
  "currency": "USD",
  "assets": ["c60", "c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"]
}
```

Returns `price`, `change_24h`, `market_cap`, `volume_24h`, `total_supply` per asset.

## Get Trending / Category Listings — `GET /v1/assets/listings`

**Base URL:** `https://tws.trustwallet.com`
**Auth:** HMAC-SHA256 (run `/setup` first)

Rich market data with multi-timeframe price changes (1h, 24h, 7d, 30d, 60d, 90d), market cap, volume, and supply.

| Param | Required | Description |
|-------|----------|-------------|
| `version` | Yes | Use `27` |
| `currency` | Yes | Price currency (e.g., `USD`) |
| `category_id` | No | Category filter (see below) |
| `sort` | No | `price24h`, `mcap`, `volume` |
| `limit` | No | Max results (default: 20, max: 100) |
| `networks` | No | Comma-separated SLIP-44 coin IDs |
| `cursor` | No | Pagination cursor |

**Categories:** `trending`, `ai`, `memes`, `rwa-assets`, `x402`, `layer_1`, `dex`, `defi-2`, `eth-ecosystem`, `bnb-ecosystem`, `solana-ecosystem`, `binance-launchpad`, `binance-launchpool`, `binance-megadrop`, `pump-fun`, `bonk`

Example: `GET /v1/assets/listings?version=27&currency=USD&category_id=ai&sort=mcap&limit=20`

## List Categories — `GET /v1/assets/listing-categories`

Get the current list of available categories (they're dynamic and may change).

For full response schemas, read `skills/api/references/market-data.md`.
