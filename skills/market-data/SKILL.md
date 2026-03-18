---
name: market-data
description: Get real-time token prices (index from CoinMarketCap + CoinGecko), discover trending tokens across 16+ categories (AI, DeFi, memes, Layer 1, ecosystem-specific), with multi-timeframe price changes, market cap, volume, and supply data. Use this whenever someone asks about crypto prices, market cap, volume, trending coins, top tokens in a category, or any "what's the price of X" question.
---

# Market Data

Real-time token prices, trending asset discovery, and category-based rankings.

## Endpoints

### Get Token Prices (Index)

`POST /v2/market/tickers`

Get current USD prices for one or more tokens. Prices are aggregated from CoinMarketCap and CoinGecko, serving as an index price.

**Base URL:** `https://tws.trustwallet.com`
**Auth:** HMAC-SHA256 (see [setup](../setup/SKILL.md))

**Request body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `currency` | string | Yes | Target currency code (e.g., `"USD"`) |
| `assets` | array | Yes | Array of asset ID strings (up to 50) |

**Example — get ETH and USDC prices:**

```json
{
  "currency": "USD",
  "assets": ["c60", "c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"]
}
```

**Response:**

```json
{
  "currency": "USD",
  "tickers": [
    {
      "id": "c60",
      "price": 3456.78,
      "change_24h": 2.34,
      "market_cap": 415000000000,
      "volume_24h": 12000000000,
      "total_supply": "120000000"
    }
  ]
}
```

---

### Get Trending / Listed Assets

`GET /v1/assets/listings`

Get trending or categorized token listings with rich market data — multi-timeframe price changes, market cap, volume, and supply.

**Base URL:** `https://tws.trustwallet.com`
**Auth:** HMAC-SHA256 (see [setup](../setup/SKILL.md))

**Query parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `version` | number | Yes | API version, use `27` |
| `currency` | string | Yes | Price currency (e.g., `USD`) |
| `category_id` | string | No | Filter by category (see table below) |
| `sort` | string | No | Sort order: `price24h`, `mcap`, `volume` |
| `limit` | number | No | Max results (default: 20, max: 100) |
| `networks` | string | No | Comma-separated SLIP-44 coin IDs |
| `cursor` | string | No | Pagination cursor from previous response |
| `use_pagination` | boolean | No | Enable cursor-based pagination |

**Categories:**

| `category_id` | Description | Default Sort |
|---------------|-------------|-------------|
| `trending` | Trending tokens (default) | — |
| `ai` | AI and machine learning tokens | `price24h` |
| `memes` | Meme coins | `price24h` |
| `rwa-assets` | Real-world assets | `price24h` |
| `x402` | x402 protocol tokens | `price24h` |
| `layer_1` | Layer 1 blockchains | `mcap` |
| `dex` | DEX tokens | `mcap` |
| `defi-2` | DeFi protocols | `mcap` |
| `eth-ecosystem` | Ethereum ecosystem | `mcap` |
| `bnb-ecosystem` | BNB Chain ecosystem | `mcap` |
| `solana-ecosystem` | Solana ecosystem | `mcap` |
| `binance-launchpad` | Binance Launchpad projects | `mcap` |
| `binance-launchpool` | Binance Launchpool projects | `mcap` |
| `binance-megadrop` | Binance Megadrop projects | `mcap` |
| `pump-fun` | PumpFun tokens | `volume` |
| `bonk` | BONK ecosystem | `volume` |

Categories are dynamic — use the listing-categories endpoint below to get the current list.

**Example request:**

```
GET /v1/assets/listings?version=27&currency=USD&category_id=ai&sort=mcap&limit=20
```

**Response:**

Each item in `docs[]` has three sub-objects: `asset`, `market`, and `price`.

```json
{
  "docs": [
    {
      "asset": {
        "asset_id": "c60_t0x...",
        "name": "Token Name",
        "symbol": "TKN",
        "type": "token",
        "decimals": 18,
        "network": 60,
        "icon_url": "https://assets.trustwalletapp.com/...",
        "is_verified": true
      },
      "market": {
        "market_cap": 1234567890,
        "volume_24h": 123456789,
        "circulating_supply": 500000000,
        "total_supply": 1000000000,
        "max_supply": 1000000000
      },
      "price": {
        "price": 12.34,
        "percent_change_1h": 0.5,
        "percent_change_24h": 5.67,
        "percent_change_7d": -2.1,
        "percent_change_30d": 15.3,
        "percent_change_60d": 22.0,
        "percent_change_90d": 45.5
      }
    }
  ],
  "total": 150,
  "cursor": "eyJsYXN0X2lkIjoiYWJjMTIzIn0="
}
```

**Price change timeframes:** 1h, 24h, 7d, 30d, 60d, 90d — all returned in a single response.

Use `cursor` from the response in the next request's `cursor` parameter to paginate.

---

### List Categories

`GET /v1/assets/listing-categories`

Get the current list of available asset listing categories. Categories are dynamic and may change over time.

**Base URL:** `https://tws.trustwallet.com`
**Auth:** HMAC-SHA256 (see [setup](../setup/SKILL.md))

**Query parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `networks` | string | No | Comma-separated SLIP-44 coin IDs to filter categories by chain |

**Example request:**

```
GET /v1/assets/listing-categories
```

**Response:**

```json
{
  "docs": [
    { "id": "trending", "name": "Trending" },
    { "id": "ai", "name": "AI" },
    { "id": "memes", "name": "Meme Coins" },
    { "id": "rwa-assets", "name": "Real World Assets" },
    { "id": "layer_1", "name": "Layer 1" },
    { "id": "dex", "name": "DEX" },
    { "id": "defi-2", "name": "DeFi" },
    { "id": "eth-ecosystem", "name": "Ethereum Ecosystem" },
    { "id": "bnb-ecosystem", "name": "BNB Ecosystem" },
    { "id": "solana-ecosystem", "name": "Solana Ecosystem" }
  ]
}
```
