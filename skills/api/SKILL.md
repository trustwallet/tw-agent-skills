---
name: trust-wallet-api
description: Trust Wallet API for crypto data — token search, prices, trending tokens, swap quotes, market data, security checks, address validation, asset info, and coin status across 100+ blockchains. Use whenever the user asks about crypto prices, token info, swap rates, market cap, trending coins, token risk, honeypot detection, address validation, or wants to call the Trust Wallet / tws.trustwallet.com API directly. Covers HMAC-SHA256 authentication, supported chains, and all REST endpoints.
---

# Trust Wallet API

REST API at `tws.trustwallet.com` — HMAC-SHA256 authenticated. Covers token search, prices, swap quotes, market data, and security across 100+ chains.

## Quick Start

**Example** — get ETH price (Python):

```python
import hmac, hashlib, base64, uuid, requests
from datetime import datetime, timezone

access_id  = "YOUR_ACCESS_ID"
secret     = "YOUR_HMAC_SECRET"
method, path = "POST", "/v2/market/tickers"
date  = datetime.now(timezone.utc).strftime("%a, %d %b %Y %H:%M:%S GMT")
nonce = str(uuid.uuid4())
sig   = base64.b64encode(hmac.new(secret.encode(), f"{method};{path};;{access_id};{nonce};{date}".encode(), hashlib.sha256).digest()).decode()

resp = requests.post(f"https://tws.trustwallet.com{path}",
    headers={"X-TW-CREDENTIAL": access_id, "X-TW-NONCE": nonce, "X-TW-DATE": date,
             "Authorization": f"HMAC-SHA256 Signature={sig}", "Content-Type": "application/json"},
    json={"currency": "USD", "assets": ["c60"]})
print(resp.json()["tickers"][0]["price"])  # ETH price in USD
```

**Asset ID format**: `c{coin}` for native tokens (e.g., `c60` = ETH), `c{coin}_t{contract}` for tokens.

**Error handling**: If 401 → re-check signing string format and secret. If 429 → wait 1s and retry (free tier: 1 req/s). If 200 → parse response body.

Read `references/setup.md` for the full signing algorithm, chain list, and auth details.

## Reference Guide

Read the reference that matches the user's task:

| Task | Reference | When to read |
|------|-----------|--------------|
| Auth, chains, asset IDs | `references/setup.md` | First time setup, unknown chain/asset format |
| Token search, asset details, coin status | `references/token-info.md` | "find token", "asset info", "is this chain active" |
| Swap quotes, routes, step transactions | `references/swap-quote.md` | "swap X for Y", "bridge", "DEX quote", "swap rate" |
| Prices, trending tokens, categories | `references/market-data.md` | "price of ETH", "trending", "top AI tokens", "market cap" |
| Address validation, token risk | `references/security.md` | "is this safe", "validate address", "honeypot", "rug check" |

Read `references/setup.md` alongside any other reference if the user hasn't authenticated yet or you need chain/asset ID info.
