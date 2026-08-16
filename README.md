# Trust Wallet Agent Skills

AI agent skills for Trust Wallet — API endpoints, CLI tools, and open-source libraries across **100+ chains**.

A collection of skills that provide focused functionality (API actions, CLI commands, and SDK references) with progressive reference loading: short descriptions are provided in-context (~300 words) and detailed reference documents are loaded only when needed.

## Install

```bash
npx skills add trustwallet/tw-agent-skills
```

This auto-detects your coding agent. To install for a specific agent, run one of the following:

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

Install a single skill by ID or name (example uses the `api` skill):

```bash
npx skills add trustwallet/tw-agent-skills -s api
```

## Prerequisites

Trust Wallet API credentials from https://portal.trustwallet.com:

```env
TWAK_ACCESS_ID=your_access_id
TWAK_HMAC_SECRET=your_hmac_secret
```

> **Security:** Add `.env` to `.gitignore`. Never commit credentials.

## Skills

| Skill | Description | References |
|-------|-------------|------------|
| [`api`](skills/api/SKILL.md) | Trust Wallet REST API — token search, prices, swap quotes, market data, security | setup, token-info, swap-quote, market-data, security |
| [`wallet`](skills/wallet/SKILL.md) | `twak` CLI — wallet management, balances, swaps, transfers, transaction history, alerts, ERC-20 utilities | setup, wallet, balance, send, swap, market, history, alerts, erc20, token-risk |
| [`sdk`](skills/sdk/SKILL.md) | Open-source libraries — Wallet Core, Trust Web3 Provider, deep links, assets, barz | wallet-core, trust-web3-provider, trust-developer, assets, barz |

**14 API actions** across 3 skills with 21 reference documents covering 100+ chains.

## How It Works

Each skill uses a thin SKILL.md router (~30 lines) that maps incoming requests to the appropriate reference document or action. The router provides a short, context-rich description by default and only loads the longer reference files when the user's task requires detailed instructions. This progressive-loading approach keeps responses concise while still providing deep reference material on demand.

Example layout for a single skill:

```
skills/api/
├── SKILL.md              ← routing table
└── references/
    ├── setup.md          ← auth, supported chains, asset IDs
    ├── token-info.md     ← token search, asset metadata, coin status
    ├── swap-quote.md     ← quotes, step-by-step swap flow, providers
    ├── market-data.md    ← prices, trending, categories
    └── security.md       ← validation, risk analysis
```

## License

MIT
