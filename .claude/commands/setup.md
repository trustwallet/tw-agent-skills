---
description: Trust Wallet API authentication — HMAC-SHA256 signing, API keys, base URLs, asset ID format, and the full list of 100+ supported chains. Use this whenever you need to authenticate with any Trust Wallet API, look up a chain's coin ID, or understand the asset ID format (e.g., c60 for ETH). Read this first before using any other TW skill.
---

# Setup — Authentication & Configuration

This is the foundation skill. Every other Trust Wallet API skill depends on it for auth headers, base URLs, and chain identifiers.

## Quick Reference

| Base URL | Auth | Used By |
|----------|------|---------|
| `https://tws.trustwallet.com` | HMAC-SHA256 | Token prices, security, swap quotes, market listings, assets |

## Asset ID Format

- **Native coin**: `c{coinId}` — e.g., `c60` (ETH), `c714` (BNB), `c501` (SOL)
- **Token**: `c{coinId}_t{contractAddress}` — e.g., `c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` (USDC on Ethereum)

The `coinId` follows the SLIP-44 standard.

## Common Chain IDs

| Chain | Coin ID | Symbol |
|-------|---------|--------|
| Ethereum | 60 | ETH |
| BNB Smart Chain | 714 | BNB |
| Solana | 501 | SOL |
| Bitcoin | 0 | BTC |
| Polygon | 966 | MATIC |
| Arbitrum | 10042221 | ETH |
| Optimism | 10000070 | ETH |
| Base | 10008453 | ETH |
| Tron | 195 | TRX |
| Avalanche | 10009000 | AVAX |

For the full list of 100+ supported chains and the complete HMAC-SHA256 signing algorithm with code examples (JS and Python), read the detailed reference:

**Read `skills/api/references/setup.md`** for:
- Full HMAC-SHA256 signing algorithm and pseudocode
- JavaScript and Python code examples for request signing
- Complete list of all supported EVM, UTXO, Cosmos, Solana, and other L1 chains
- Chain key vs chain ID mapping for swap endpoints
