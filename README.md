# Trust Wallet Agent Skills

AI agent skills for Trust Wallet — API endpoints, CLI tools, and open-source libraries across **100+ chains**.

3 skills with progressive reference loading: descriptions are always in context (~300 words), detailed references load only when needed.

## Install

```bash
npx skills add trustwallet/tw-agent-skills
```

This auto-detects your coding agent. To install for a specific agent:

```bash
npx skills add trustwallet/tw-agent-skills -a claude-code
npx skills add trustwallet/tw-agent-skills -a cursor
npx skills add trustwallet/tw-agent-skills -a codex
npx skills add trustwallet/tw-agent-skills -a windsurf
npx skills add trustwallet/tw-agent-skills -a github-copilot
npx skills add trustwallet/tw-agent-skills -a cline
npx skills add trustwallet/tw-agent-skills -a opencode
npx skills add trustwallet/tw-agent-skills -a roo
```

Install a single skill:

```bash
npx skills add trustwallet/tw-agent-skills -s api
```

## Prerequisites

Trust Wallet API credentials from [portal.trustwallet.com](https://portal.trustwallet.com):

```env
TWAK_ACCESS_ID=your_access_id
TWAK_HMAC_SECRET=your_hmac_secret
```

> **Security:** Add `.env` to `.gitignore`. Never commit credentials.

## Skills

| Skill | Description | References |
|-------|-------------|------------|
| [`api`](skills/api/SKILL.md) | Trust Wallet REST API — token search, prices, swap quotes, market data, security | setup, token-info, swap-quote, market-data, security |
| [`wallet`](skills/wallet/SKILL.md) | `twak` CLI — wallets, balances, swaps, transfers, alerts, ERC-20, x402 | setup, wallet, balance, send, swap, market, history, alerts, erc20, token-risk, x402 |
| [`sdk`](skills/sdk/SKILL.md) | Open-source libraries — Wallet Core, Web3 Provider, deep links, assets, Barz | wallet-core, trust-web3-provider, trust-developer, assets, barz |

**14 API actions** across 3 skills with 21 reference documents covering 100+ chains.

## How It Works

Each skill uses a thin SKILL.md router (~30 lines) that points to the right reference based on the user's task. Claude reads only the relevant reference file — same content as before, but with 7x less always-in-context overhead (3 descriptions vs 21).

```
api/
├── SKILL.md              ← routing table
└── references/
    ├── setup.md          ← auth, chains, asset IDs
    ├── token-info.md     ← search, assets, coin status
    ├── swap-quote.md     ← quotes, step tx, providers
    ├── market-data.md    ← prices, trending, categories
    └── security.md       ← validation, risk analysis
```

## License

MIT
