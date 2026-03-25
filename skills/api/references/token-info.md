
# Token Info

Search for tokens and get asset details across all supported chains.

**Base URL:** `https://tws.trustwallet.com`
**Auth:** HMAC-SHA256 (see [setup](../setup/SKILL.md))

## Endpoints

### Search Assets

`GET /v1/search/assets`

Search for tokens by name, symbol, or contract address. Returns matching tokens with metadata, market data, and verification status.

**Query parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `query` | string | Yes | Search term (name, symbol, or address) |
| `networks` | string | No | Comma-separated SLIP-44 coin IDs to filter by chain (e.g., `60` for Ethereum, `60,714` for ETH+BSC) |
| `limit` | number | No | Max results (default: 20) |

**Example request:**

```
GET /v1/search/assets?query=USDC&networks=60
```

**Response:**

```json
{
  "total": 9,
  "docs": [
    {
      "name": "USD Coin",
      "symbol": "USDC",
      "type": "ERC20",
      "decimals": 6,
      "asset_id": "c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
      "verifiers": ["trustwallet"],
      "icon_url": "https://assets-cdn.trustwallet.com/...",
      "market_cap": 32000000000,
      "volume_24h": 5000000000,
      "price": 1.0,
      "tags": ["stablecoin"]
    }
  ]
}
```

The `v2/search/assets` endpoint is also available with expanded results.

---

### Get Assets

`GET /v1/assets`

Get asset details. Can be used to look up specific assets by ID or list assets for a chain.

**Query parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `assetId` | string | No | Specific asset ID (e.g., `c60` for ETH) |
| `coin` | number | No | SLIP-44 coin ID to list assets for a chain |

**Example request:**

```
GET /v1/assets?assetId=c60
```

---

### Get Coin Status

`GET /v1/coinstatus/{assetId}`

Get coin status including feature flags (buy/sell/swap/stake enabled), warning messages, and security info.

**Path parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `assetId` | string | Yes | Asset ID (e.g., `c60` for ETH, `c60_t0xA0b8...` for ERC-20) |

**Query parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `version` | string | No | API version (e.g., `8.4`) |
| `platform` | string | No | Platform (`android`, `ios`) |
| `include_security_info` | boolean | No | Include security analysis (default: `false`) |

**Example request:**

```
GET /v1/coinstatus/c60?include_security_info=true
```

**Response:**

```json
{
  "asset": {
    "name": "Ethereum",
    "symbol": "ETH",
    "type": "coin",
    "decimals": 18,
    "asset_id": "c60"
  },
  "isBuyCryptoEnabled": true,
  "isSellCryptoEnabled": true,
  "isSwapEnabled": true,
  "isSwapCrossChainEnabled": true,
  "isStakeEnabled": true,
  "isDappsEnabled": true,
  "messages": [],
  "security_info": {
    "is_scanned": true,
    "contract_security": {
      "num_risks": 0,
      "num_warnings": 0,
      "is_counterfeit": false
    },
    "honeypot_risk": {
      "num_risks": 0,
      "num_warnings": 0,
      "buy_tax": 0.0,
      "sell_tax": 0.0
    }
  }
}
```

The `v2/coinstatus/{assetId}` variant additionally includes native token payment info.
