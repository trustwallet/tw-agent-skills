---
name: swap-quote
description: Get swap quotes and transaction data for token swaps across any chain — same-chain and cross-chain via the Amber aggregator with 10+ DEX and bridge providers including 1inch, Jupiter, KyberSwap, THORChain, Stargate, and more. Use this whenever someone wants to swap tokens, bridge between chains, get a swap quote, compare DEX rates, or execute any kind of token exchange.
---

# Swap Quotes

Get quotes and transaction data for same-chain and cross-chain token swaps via the Amber aggregator.

**Base URL:** `https://tws.trustwallet.com`
**Auth:** HMAC-SHA256 (see [setup](../setup/SKILL.md))

## Providers

The Amber aggregator routes through 10+ DEX and bridge providers plus its own LiquidMesh routing engine:

**DEX providers (same-chain):**

| Provider | Chains |
|----------|--------|
| 1inch | Ethereum, BSC, Polygon, Arbitrum, Optimism, Avalanche, Base, zkSync |
| KyberSwap | Ethereum, BSC, Polygon, Arbitrum, Optimism, Avalanche, Base, Linea, zkSync |
| 0x | Ethereum, BSC, Polygon, Arbitrum, Fantom |
| Jupiter | Solana |
| THORChain | Bitcoin, Litecoin, Dogecoin, Bitcoin Cash |

**Bridge providers (cross-chain):**

| Provider | Description |
|----------|-------------|
| Stargate Finance | LayerZero-based bridge |
| Synapse Protocol | Cross-chain messaging + bridge |
| Squid Router | Axelar-based cross-chain |
| Rango Exchange | Multi-bridge aggregator |
| SWFT Bridgers | Tron, TON, XRP bridging |

**Internal:**

| Provider | Description |
|----------|-------------|
| LiquidMesh | Amber's internal liquidity aggregation engine |

## Concepts

### Domain IDs

The Amber API uses **domain IDs** to identify chains. Common ones:

| Domain ID | Chain |
|-----------|-------|
| `ethereum` | Ethereum |
| `bsc` | BNB Smart Chain |
| `polygon` | Polygon |
| `arbitrum` | Arbitrum |
| `optimism` | Optimism |
| `base` | Base |
| `avalanche` | Avalanche |
| `solana` | Solana |
| `bitcoin` | Bitcoin |
| `tron` | Tron |

### Token Addresses

- **EVM native tokens**: Use `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`
- **Solana native (SOL)**: Use `So11111111111111111111111111111111111111112` (wrapped SOL mint)
- **All other tokens**: Use the contract/mint address

## Endpoints

### List Domains

`GET /amber-api/v1/domains?ton=true`

Get all supported chain domains with chain IDs, finality times, and available DEX providers per chain. Pass `ton=true` to include TON.

**Response:**

```json
{
  "domains": [
    {
      "id": "ethereum",
      "name": "Ethereum",
      "type": "EVM",
      "chainId": "0x1",
      "finalityTime": "60",
      "dex": ["1inch", "kyberswap", "0x"]
    }
  ]
}
```

---

### List Providers

`GET /amber-api/v1/providers`

Get all available swap and bridge providers.

---

### Get Bridge Provider

`GET /amber-api/v1/providers/bridge/{id}`

Get details for a specific bridge provider by ID.

---

### Get DEX Provider

`GET /amber-api/v1/providers/dex/{id}`

Get details for a specific DEX provider by ID.

---

### Get Swap Quote

`POST /amber-api/v1/route`

Get swap routes with price quotes. Returns one or more routes ranked by output amount.

**Request body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `fromAsset` | string | Yes | Source token address |
| `fromAddress` | string | Yes | Sender wallet address |
| `fromDomain` | string | Yes | Source chain domain ID |
| `amount` | string | Yes | Amount in smallest unit (wei, lamports, etc.) |
| `toAsset` | string | Yes | Destination token address |
| `toAddress` | string | No | Receiver address (defaults to `fromAddress`) |
| `toDomain` | string | Yes | Destination chain domain ID |
| `slippage` | string | No | Slippage tolerance in percent (default: `"1"`) |
| `sortBy` | string | No | Sort routes by `"outcome"` (default) or `"fee"` |
| `contractCall` | boolean | No | Set `false` for EOA wallets (default: `false`) |
| `preferredProviders` | string[] | No | Provider IDs to prefer (e.g., `["1inch", "jupiter"]`) |
| `ignoredProviders` | string[] | No | Provider IDs to exclude |
| `thorchain` | object | No | `{ "streaming": true }` to enable THORChain streaming swaps |

**Example — swap 0.1 ETH to USDC on Base:**

```json
{
  "fromAsset": "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE",
  "fromAddress": "0xYourAddress",
  "fromDomain": "base",
  "amount": "100000000000000000",
  "toAsset": "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
  "toAddress": "0xYourAddress",
  "toDomain": "base",
  "slippage": "1",
  "sortBy": "outcome",
  "contractCall": false
}
```

**Response:**

```json
{
  "routes": [
    {
      "id": "route-uuid",
      "expirationDate": "2026-03-03T12:05:00Z",
      "steps": [
        {
          "id": "step-uuid",
          "type": "STEP_TYPE_SWAP",
          "from": {
            "asset": "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE",
            "address": "0xYourAddress",
            "amount": "100000000000000000"
          },
          "to": {
            "asset": "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
            "address": "0xYourAddress",
            "amount": "234560000",
            "minAmountOut": "232214400"
          },
          "slippage": "1",
          "priceImpact": "0.01",
          "provider": {
            "id": "1inch",
            "name": "1inch Network"
          },
          "networkFee": {
            "amount": "0.0001",
            "asset": "ETH"
          }
        }
      ],
      "warnings": []
    }
  ],
  "config": {
    "refreshInterval": "60"
  }
}
```

**Step types:** `STEP_TYPE_SWAP`, `STEP_TYPE_BRIDGE`, `STEP_TYPE_WRAP`, `STEP_TYPE_UNWRAP`

---

### Get Step Transaction

`POST /amber-api/v1/route/step`

Get the executable transaction data for a specific swap step. Call this for each step in a route.

**Request body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `stepId` | string | Yes | Step ID from the route response |

```json
{
  "stepId": "step-uuid"
}
```

**Response:**

```json
{
  "stepId": "step-uuid",
  "transaction": {
    "domainId": "base",
    "type": "swap",
    "evmTx": {
      "to": "0xRouterContract",
      "value": "100000000000000000",
      "data": "0xcalldata...",
      "gasLimit": "250000"
    }
  },
  "approve": {
    "to": "0xTokenContract",
    "value": "0",
    "data": "0xapproveCalldata...",
    "gasLimit": "60000"
  },
  "revokeApproval": null
}
```

**Transaction fields:**

| Field | Description |
|-------|-------------|
| `transaction` | The main swap transaction |
| `approve` | ERC-20 approval transaction (if spending a token, not native) |
| `revokeApproval` | Revoke previous unlimited approval (if needed for security) |

For non-EVM chains (e.g., Solana), the `transaction` field contains a `data` string (base64 encoded raw transaction) instead of `evmTx`.

## Execution Flow

1. **Get quote** — `POST /amber-api/v1/route` to get routes
2. **Select route** — pick the best route (first is sorted by `sortBy`)
3. **Get transactions** — for each step, call `POST /amber-api/v1/route/step`
4. **Execute in order:**
   - If `revokeApproval` exists → send it first, wait for confirmation
   - If `approve` exists → send approval, wait for confirmation
   - Send the main `transaction`

Cross-chain swaps may have multiple steps (e.g., swap + bridge). Execute each step's transactions sequentially.
