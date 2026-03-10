---
name: onramp
description: Buy crypto with fiat (USD, EUR, GBP) or sell crypto for fiat — get quotes from multiple providers and checkout URLs to complete purchases.
---

# Fiat On-Ramp & Off-Ramp

Buy crypto with fiat currency or sell crypto for fiat. Get quotes from multiple providers and redirect URLs for checkout.

**Base URL:** `https://gateway.us.trustwallet.com`
**Auth:** HMAC-SHA256 (see [setup](../setup/SKILL.md))

## Endpoints

### Get Buy Quote

`GET /v1/buycrypto/quote/{cryptoAsset}`

Get quotes for buying crypto with fiat currency from available providers.

**Path parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `cryptoAsset` | string | Yes | Target asset ID (e.g., `c60` for ETH, `c60_t0xA0b8...` for ERC-20) |

**Query parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `amount` | number | Yes | Amount in fiat currency to spend |
| `currency` | string | Yes | Fiat currency code (`USD`, `EUR`, `GBP`) |
| `address` | string | Yes | Destination wallet address |

**Example request:**

```
GET /v1/buycrypto/quote/c60?amount=100&currency=USD&address=0xYourAddress
```

**Response:**

```json
{
  "quotes": [
    {
      "id": "quote-uuid-1",
      "provider": {
        "name": "MoonPay",
        "logo_url": "https://..."
      },
      "digital_money": {
        "amount": "0.028",
        "currency": "ETH"
      },
      "fiat_money": {
        "amount": "100.00",
        "currency": "USD"
      },
      "payment_method": {
        "payment_method": "credit_card"
      }
    },
    {
      "id": "quote-uuid-2",
      "provider": {
        "name": "Mercuryo"
      },
      "digital_money": {
        "amount": "0.027",
        "currency": "ETH"
      },
      "fiat_money": {
        "amount": "100.00",
        "currency": "USD"
      },
      "payment_method": {
        "payment_method": "credit_card"
      }
    }
  ]
}
```

---

### Get Buy Checkout URL

`GET /v1/buycrypto/request/{quoteId}`

Get a redirect URL for the user to complete the fiat-to-crypto purchase in their browser.

**Path parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `quoteId` | string | Yes | Quote ID from the buy quote response |

**Query parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `address` | string | Yes | Destination wallet address |

**Example request:**

```
GET /v1/buycrypto/request/quote-uuid-1?address=0xYourAddress
```

**Response:**

```json
{
  "url": "https://buy.moonpay.com/...",
  "redirect_url": "https://buy.moonpay.com/..."
}
```

The `url` or `redirect_url` field contains the checkout page. Open it in a browser for the user to complete the purchase.

---

### Get Sell Quote

`GET /v1/sellcrypto/quote/{cryptoAsset}`

Get quotes for selling crypto to receive fiat currency.

**Path parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `cryptoAsset` | string | Yes | Asset ID to sell (e.g., `c60` for ETH) |

**Query parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `amount` | number | Yes | Amount of crypto to sell (in human-readable units) |
| `currency` | string | Yes | Target fiat currency code (`USD`, `EUR`, `GBP`) |
| `address` | string | Yes | Source wallet address |
| `payment_method` | string | No | Payout method: `bank_transfer` (default), `card` |

**Example request:**

```
GET /v1/sellcrypto/quote/c60?amount=0.5&currency=USD&address=0xYourAddress&payment_method=bank_transfer
```

**Response:**

```json
{
  "quotes": [
    {
      "id": "sell-quote-uuid",
      "provider": {
        "name": "MoonPay"
      },
      "fiat_money": {
        "amount": "1728.39",
        "currency": "USD"
      },
      "digital_money": {
        "amount": "0.5",
        "currency": "ETH"
      },
      "fee": {
        "fees": [
          {
            "amount": "25.00",
            "currency": "USD",
            "type": "network_fee"
          }
        ]
      },
      "is_recommended": true
    }
  ]
}
```

---

### Get Sell Checkout URL

`GET /v1/sellcrypto/request/{quoteId}`

Get a redirect URL for the user to complete the crypto-to-fiat sale.

**Path parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `quoteId` | string | Yes | Quote ID from the sell quote response |

**Query parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `address` | string | Yes | Source wallet address |

**Example request:**

```
GET /v1/sellcrypto/request/sell-quote-uuid?address=0xYourAddress
```

**Response:**

```json
{
  "url": "https://sell.moonpay.com/...",
  "redirect_url": "https://sell.moonpay.com/..."
}
```

Open the URL in a browser for the user to complete the sale and receive fiat.
