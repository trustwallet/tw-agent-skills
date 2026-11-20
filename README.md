# Trust Wallet Agent Skills

AI agent skills for Trust Wallet — API endpoints, CLI tools, and open-source libraries across **100+ chains**.

4 skills with progressive reference loading: descriptions are always in context (~300 words), detailed references load only when needed.

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

## Cursor and Grok Bot plugin

This repository is also a Cursor Marketplace plugin (`.cursor-plugin/plugin.json`), which Grok Bot installs from its Connect apps. It bundles these skills and the `twak` MCP server (`npx -y @trustwallet/cli@<version> serve`, pinned in `mcp.json`). The [`mcp`](skills/mcp/SKILL.md) skill guides the agent through setup and two ways of signing:

- **Trust Wallet app (WalletConnect)**, recommended: keys stay in the user's Trust Wallet app, which approves every transaction.
- **Agent wallet**: a new, separate wallet the agent signs with, within a signing policy the user sets (small amounts run, anything larger asks for confirmation), and the user funds. Signing with it needs the server started with `--allow-local-signing`. Never give an agent your main wallet's recovery phrase.

On Grok Bot (personal Bots only), the skill has the user add Bot secrets (API credentials, `TWAK_HOME=/workspace/.twak` so twak's files stay in Grok's durable folder, and the agent wallet password), then checks the server picked them up before pairing or creating a wallet.

## Upgrading to twak 2.0

twak 2.0 changes how `twak serve` (the MCP and REST server) signs. This plugin uses `@trustwallet/cli@2`; anyone who stays on `@1` keeps the 1.x behaviour.

- **Local signing is off by default.** Without `--allow-local-signing`, the local agent wallet can be read (addresses, balances, history) but not used to sign. Signing tools return `LOCAL_SIGNING_DISABLED`.
- **With it on, signing follows a policy** set by the user with `twak config`: small valued swaps and payments, and transfers to allowlisted addresses, run within limits; everything else asks for the user's confirmation, and unlimited token approvals are refused. See [`limits.md`](skills/wallet/references/limits.md).
- **Third-party text is labelled.** Token names, swap routes, x402 responses and similar content come back under an `untrusted` field and are data, never instructions.
- **Automations** run only after the user approves them (`twak automate approve <id>`).

To let the agent sign with the local wallet, add `--allow-local-signing` to the server's arguments and restart the host:

```json
{
  "mcpServers": {
    "twak": {
      "command": "npx",
      "args": ["-y", "@trustwallet/cli@2", "serve", "--allow-local-signing"]
    }
  }
}
```

Outside this plugin, `npx -y @trustwallet/cli@2 setup` also asks whether to allow it. To approve every transaction on your phone instead, connect the Trust Wallet app (WalletConnect). CLI commands you run yourself, and the SDK, are unchanged.

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
| [`wallet`](skills/wallet/SKILL.md) | `twak` CLI — wallets, balances, swaps, transfers, alerts, ERC-20, x402 | setup, wallet, balance, send, swap, market, history, alerts, erc20, token-risk, x402, onramp, automations, compete, erc8004, erc8183 |
| [`sdk`](skills/sdk/SKILL.md) | Open-source libraries — Wallet Core, Web3 Provider, deep links, assets, Barz | wallet-core, trust-web3-provider, trust-developer, assets, barz |
| [`mcp`](skills/mcp/SKILL.md) | `twak` MCP server (plugin, Grok Bot) — setup, Trust Wallet app via WalletConnect or agent wallet, balances, send, swap, buy/sell | — |

**14 API actions** across 4 skills with 27 reference documents covering 100+ chains.

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
