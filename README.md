# Trust Wallet Agent Skills

AI agent skills for Trust Wallet APIs and open-source libraries — swaps, market data, security, wallet-core, Web3 provider, assets, and smart contract wallets — across **100+ chains**.

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
| [`setup`](skills/setup/SKILL.md) | — | Authentication (HMAC-SHA256), base URLs, 100+ supported chains |
| [`cli-setup`](skills/cli-setup/SKILL.md) | — | Install and authenticate the TWAK CLI for multichain crypto wallet operations |
| [`token-info`](skills/token-info/SKILL.md) | 3 | Token search, asset details, and coin status |
| [`swap-quote`](skills/swap-quote/SKILL.md) | 6 | Swap quotes, step transactions, providers, and domains via Amber |
| [`swap`](skills/swap/SKILL.md) | — | Execute same-chain and cross-chain token swaps via the CLI |
| [`market-data`](skills/market-data/SKILL.md) | 3 | Token prices (CMC + CoinGecko index), trending listings by 16+ categories |
| [`market`](skills/market/SKILL.md) | — | Real-time token prices, trending tokens across 16+ categories, and DApps via the CLI |
| [`security`](skills/security/SKILL.md) | 2 | Address validation and token risk analysis |
| [`token-risk`](skills/token-risk/SKILL.md) | — | Token risk checks (honeypot, audit, freeze authority) and address validation via the CLI |
| [`wallet-core`](skills/wallet-core/SKILL.md) | — | HD wallet creation, address derivation, and transaction signing across 140+ blockchains |
| [`wallet`](skills/wallet/SKILL.md) | — | Non-custodial HD wallet management — addresses, signing, keychain, and WalletConnect |
| [`balance`](skills/balance/SKILL.md) | — | Wallet balances, token holdings, and portfolio across any blockchain |
| [`send`](skills/send/SKILL.md) | — | Send tokens or native assets to any address or ENS name across 25+ chains |
| [`history`](skills/history/SKILL.md) | — | Transaction history and details for any wallet address |
| [`alerts`](skills/alerts/SKILL.md) | — | Price alerts that trigger when tokens reach target prices |
| [`erc20`](skills/erc20/SKILL.md) | — | ERC-20 token spending approvals and allowance checks |
| [`x402`](skills/x402/SKILL.md) | — | HTTP micropayments via x402 protocol — client and server |
| [`trust-web3-provider`](skills/trust-web3-provider/SKILL.md) | — | Web3 provider library for Ethereum, Solana, Cosmos, Bitcoin, Aptos, TON, Tron |
| [`trust-developer`](skills/trust-developer/SKILL.md) | — | Deep links, browser extension detection, and WalletConnect integration |
| [`assets`](skills/assets/SKILL.md) | — | Token logos and metadata for thousands of tokens across 180+ blockchains |
| [`barz`](skills/barz/SKILL.md) | — | Modular ERC-4337 smart contract wallet (Diamond proxy pattern) |

**14 actions** across 21 skills covering 100+ supported chains.

## Workflow

Skills build on each other:

```
setup → token-info
      → swap-quote
      → market-data
      → security
```

1. Start with `setup` to understand authentication
2. Use `market-data` for prices and token discovery
3. Use `security` to validate addresses and check token risk before transacting
4. Use `swap-quote` to get quotes and transaction data

## Base URLs

| Base URL | Auth | Purpose |
|----------|------|---------|
| `https://tws.trustwallet.com` | HMAC-SHA256 | Token prices, security, swap quotes, market listings, assets |

> **Rate limit:** Free tier is limited to **1 request per second**. Exceeding this returns `429 Too Many Requests`.

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

- Custom smart contract deployment
- NFT-specific operations

## License

MIT
