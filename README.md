# Trust Wallet Agent Skills

AI agent skills for Trust Wallet APIs — wallet management, token transfers, swaps, DCA, limit orders, price alerts, balances, market data, history, security, and fiat on/off-ramp — across **100+ chains**.

## Install

```bash
npx skills add trustwallet/tw-agent-skills
```

This auto-detects your coding agent. To install for a specific agent:

```bash
# Claude Code
npx skills add trustwallet/tw-agent-skills -a claude-code

# Cursor
npx skills add trustwallet/tw-agent-skills -a cursor

# Codex CLI
npx skills add trustwallet/tw-agent-skills -a codex

# Windsurf
npx skills add trustwallet/tw-agent-skills -a windsurf

# GitHub Copilot
npx skills add trustwallet/tw-agent-skills -a github-copilot

# Cline
npx skills add trustwallet/tw-agent-skills -a cline

# OpenCode
npx skills add trustwallet/tw-agent-skills -a opencode

# Roo
npx skills add trustwallet/tw-agent-skills -a roo

# Any other supported agent
npx skills add trustwallet/tw-agent-skills -a <agent-name>
```

Install a single skill:

```bash
npx skills add trustwallet/tw-agent-skills -s swap-quote
```

List available skills without installing:

```bash
npx skills add trustwallet/tw-agent-skills -l
```

## Prerequisites

You need Trust Wallet API credentials. Get them at [portal.trustwallet.com](https://portal.trustwallet.com).

Set them as environment variables or in a `.env` file:

```env
TWAK_ACCESS_ID=your_access_id
TWAK_HMAC_SECRET=your_hmac_secret
```

> **Security:** Add `.env` to `.gitignore`. Never commit credentials.

See the [setup skill](skills/setup/SKILL.md) for the full HMAC-SHA256 signing algorithm with code examples in JavaScript and Python.

## Skills

| Skill | Actions | Description |
|-------|---------|-------------|
| [`setup`](skills/setup/SKILL.md) | — | Authentication (HMAC-SHA256), wallet password, base URLs, 100+ supported chains |
| [`wallet`](skills/wallet/SKILL.md) | 5 | Create wallet, get addresses, check balances, WalletConnect |
| [`balance`](skills/balance/SKILL.md) | 4 | Native balance, token holdings, asset search, asset info |
| [`transfer`](skills/transfer/SKILL.md) | 3 | Token transfers with ENS resolution, ERC-20 approvals, allowances |
| [`swap-quote`](skills/swap-quote/SKILL.md) | 4 | Swap quotes, step transactions, providers, and domains via Amber |
| [`market-data`](skills/market-data/SKILL.md) | 3 | Token prices (CMC + CoinGecko index), trending listings by 16+ categories |
| [`history`](skills/history/SKILL.md) | 2 | Transaction history and details |
| [`security`](skills/security/SKILL.md) | 2 | Address validation and token risk analysis |
| [`onramp`](skills/onramp/SKILL.md) | 4 | Fiat buy/sell quotes and checkout URLs |
| [`alerts`](skills/alerts/SKILL.md) | 4 | Price alerts with above/below conditions |
| [`automations`](skills/automations/SKILL.md) | 4 | DCA recurring buys and limit orders |

**35 actions** across 11 skills covering 100+ supported chains.

## Workflow

Skills build on each other:

```
setup → wallet → balance → transfer
                        → swap-quote → automations (DCA / limit orders)
                        → market-data → alerts
                        → history
                        → security
                        → onramp
```

1. Start with `setup` to understand authentication and wallet password
2. Use `wallet` to create or connect a wallet and get addresses
3. Use `balance` to check wallet holdings
4. Use `market-data` for prices and token discovery
5. Use `security` to validate addresses and check token risk before transacting
6. Use `swap-quote` to get quotes and transaction data
7. Use `transfer` to send tokens or manage approvals
8. Use `alerts` to set price notifications
9. Use `automations` to set up DCA or limit orders
10. Use `onramp` for fiat buy/sell flows

## Base URLs

| Base URL | Auth | Purpose |
|----------|------|---------|
| `https://gateway.us.trustwallet.com` | HMAC-SHA256 | Balance, assets, security, history, on/off-ramp, market listings |
| `https://api.trustwallet.com` | HMAC-SHA256 | Swap quotes, transactions, providers, domains (Amber) |
| `https://market.trustwallet.com` | None | Token prices (index from CoinMarketCap + CoinGecko) |

## Asset ID Format

Trust Wallet uses a compact asset ID format across all APIs:

- **Native coin**: `c{coinId}` — e.g., `c60` (ETH), `c714` (BNB), `c501` (SOL)
- **Token**: `c{coinId}_t{contractAddress}` — e.g., `c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` (USDC on Ethereum)

The `coinId` follows the [SLIP-44](https://github.com/satoshilabs/slips/blob/master/slip-0044.md) standard.

### Common Coin IDs

| Chain | Coin ID | Symbol |
|-------|---------|--------|
| Ethereum | 60 | ETH |
| BSC | 714 | BNB |
| Polygon | 966 | MATIC |
| Solana | 501 | SOL |
| Bitcoin | 0 | BTC |
| Arbitrum | 10042221 | ETH |
| Base | 10008453 | ETH |
| Optimism | 10000070 | ETH |
| Avalanche | 10009000 | AVAX |
| Tron | 195 | TRX |

See the [setup skill](skills/setup/SKILL.md) for the complete list of 100+ supported chains.

## Swap Providers

The Amber aggregator routes through 10+ DEX and bridge providers:

**DEX:** 1inch, KyberSwap, 0x, Jupiter (Solana), THORChain (Bitcoin/UTXO)
**Bridges:** Stargate, Synapse, Squid Router, Rango, SWFT
**Internal:** LiquidMesh (Amber's routing engine)

See the [swap-quote skill](skills/swap-quote/SKILL.md) for per-chain provider availability.

## What's NOT Included

These skills document the Trust Wallet agent APIs. The following are out of scope:

- Raw private key management (the agent wallet handles this securely)
- Custom smart contract deployment
- NFT-specific operations

## License

MIT
