---
name: trust-wallet-api
description: Trust Wallet API for crypto data — token search, prices, trending tokens, swap quotes, market data, security checks, address validation, asset info, and coin status across 100+ blockchains. Use whenever the user asks about crypto prices, token info, swap rates, market cap, trending coins, token risk, honeypot detection, address validation, or wants to call the Trust Wallet / tws.trustwallet.com API directly. Covers HMAC-SHA256 authentication, supported chains, and all REST endpoints.
---

# Trust Wallet API

REST API at `tws.trustwallet.com` — HMAC-SHA256 authenticated. Covers token search, prices, swap quotes, market data, and security across 100+ chains.

## Quick Start

Read `references/setup.md` first for authentication, asset ID format, and the full chain list.

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
