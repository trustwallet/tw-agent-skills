---
name: automations
description: Set up DCA (dollar-cost averaging) recurring buys and limit orders that execute swaps when price conditions are met. Use this whenever someone wants to DCA into a token, set up recurring buys, create limit orders, buy/sell at a specific price, or automate their trading strategy.
---

# Automations — DCA & Limit Orders

Create automated trading rules that execute swaps on a schedule (DCA) or when a price condition is met (limit orders). Automations are stored locally at `~/.tw-agent/automations.json` and execute swaps through the Amber aggregator.

## Automation Types

| Type | Description | Required Fields |
|------|-------------|-----------------|
| **DCA** | Recurring swap on a fixed interval | `intervalMs` |
| **Limit** | One-time swap when price crosses a threshold | `targetPrice`, `condition` |

## Actions

### Create Automation

Create a DCA (recurring buy) or limit order.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | Yes | `"dca"` or `"limit"` |
| `fromToken` | string | Yes | Source token symbol or address |
| `toToken` | string | Yes | Destination token symbol or address |
| `chain` | string | No | Chain name (default: `ethereum`) |
| `amount` | string | Yes | Amount of fromToken per execution |
| `intervalMs` | number | DCA only | Interval in milliseconds (e.g., `86400000` for daily) |
| `targetPrice` | number | Limit only | Target price in USD |
| `condition` | string | Limit only | `"above"` or `"below"` |

**Example — DCA $10 USDC into ETH every day:**

```json
{
  "type": "dca",
  "fromToken": "USDC",
  "toToken": "ETH",
  "chain": "ethereum",
  "amount": "10",
  "intervalMs": 86400000
}
```

**Response:**

```json
{
  "success": true,
  "id": "auto-abc123",
  "summary": "DCA: 10 USDC → ETH every 24h",
  "record": {
    "id": "auto-abc123",
    "type": "dca",
    "fromToken": "USDC",
    "toToken": "ETH",
    "chain": "ethereum",
    "amount": "10",
    "intervalMs": 86400000,
    "active": true,
    "createdAt": "2026-03-11T12:00:00Z"
  }
}
```

**Example — limit order: buy ETH when AVAX drops below $9:**

```json
{
  "type": "limit",
  "fromToken": "USDC",
  "toToken": "AVAX",
  "chain": "avalanche",
  "amount": "50",
  "targetPrice": 9,
  "condition": "below"
}
```

**Response:**

```json
{
  "success": true,
  "id": "auto-def456",
  "summary": "Limit: swap 50 USDC → AVAX when price below $9"
}
```

### Common Intervals

| Interval | Milliseconds |
|----------|-------------|
| Every hour | `3600000` |
| Every 4 hours | `14400000` |
| Daily | `86400000` |
| Weekly | `604800000` |

---

### List Automations

List all automation rules, optionally filtered to active only.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `activeOnly` | boolean | No | Only show active automations (default: `true`) |

**Response:**

```json
{
  "success": true,
  "count": 2,
  "automations": [
    {
      "id": "auto-abc123",
      "type": "dca",
      "fromToken": "USDC",
      "toToken": "ETH",
      "chain": "ethereum",
      "amount": "10",
      "intervalMs": 86400000,
      "active": true,
      "lastRunAt": "2026-03-11T12:00:00Z"
    },
    {
      "id": "auto-def456",
      "type": "limit",
      "fromToken": "USDC",
      "toToken": "AVAX",
      "chain": "avalanche",
      "amount": "50",
      "targetPrice": 9,
      "condition": "below",
      "active": true
    }
  ]
}
```

---

### Delete Automation

Deactivate and remove an automation rule.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Automation ID to delete |

**Response:**

```json
{
  "success": true,
  "message": "Automation auto-abc123 deleted"
}
```

---

### Run Automation Now

Manually trigger an automation immediately, bypassing the schedule or price condition. Executes the swap through the Amber aggregator and records the result.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Automation ID to execute |

**Response:**

```json
{
  "success": true,
  "txHash": "0x688c6129a6bf8fa8bdf39d50ad9a328b4cd1ad088947c7a9fb7712d091387abf",
  "automationId": "auto-abc123",
  "swapped": "10 USDC → ETH",
  "explorer": "https://etherscan.io/tx/0x688c..."
}
```

Requires an agent wallet with funds. The automation's `lastRunAt` is updated after execution.

## Execution

- **DCA automations** run at the specified interval. Use `tw-agent watch` in the CLI for continuous monitoring, or call `run_automation_now` to execute manually.
- **Limit orders** execute once when the price condition is met, then deactivate.
- All swaps route through the Amber aggregator (same providers as `swap` and `get_swap_quote`).
- The agent wallet must have sufficient funds in `fromToken` for execution.
