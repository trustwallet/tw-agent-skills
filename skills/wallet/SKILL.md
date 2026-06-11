---
name: trust-wallet-cli
description: Trust Wallet CLI (`twak`) — install, create wallets, check balances, send tokens, swap, view history, set price alerts, DCA automations, limit orders, manage ERC-20 approvals, check token risk, browse trending/DApps, and run x402 micropayments. Use whenever the user wants to use the twak CLI, manage a crypto wallet from the terminal, send or swap tokens via command line, check portfolio, create price alerts, set up DCA, create limit orders, approve ERC-20 spenders, or interact with Trust Wallet from a shell. Also covers MCP server setup for AI agents.
---

# Trust Wallet CLI (`twak`)

Command-line interface for multichain crypto wallet operations. Install with `npm install -g @trustwallet/cli`.

## Quick Start

Read `references/setup.md` for installation and authentication.

## Reference Guide

Read the reference that matches the user's task:

| Task | Reference | When to read |
|------|-----------|--------------|
| Install, auth, env vars | `references/setup.md` | First time setup, "install twak", "configure API keys" |
| List supported chains, chain keys | `references/setup.md` | "what chains are supported", "list chains", "show chain keys", "what is the chain key for X" |
| Create wallet, keychain, sign, register | `references/wallet.md` | "create wallet", "keychain", "sign message", "wallet status", "register wallet with backend" |
| Balance, holdings, portfolio | `references/balance.md` | "check balance", "portfolio", "token holdings" |
| Send tokens, ENS transfers | `references/send.md` | "send ETH", "transfer to", "vitalik.eth" |
| Swap tokens, cross-chain | `references/swap.md` | "swap ETH for USDC", "bridge", "cross-chain swap" |
| Buy/sell crypto with fiat | `references/onramp.md` | "buy ETH with USD", "onramp", "offramp", "fiat", "sell crypto for cash" |
| Prices, trending, DApps | `references/market.md` | "price of", "trending tokens", "dapps" |
| Transaction history | `references/history.md` | "tx history", "transaction details" |
| Price alerts | `references/alerts.md` | "alert when ETH", "price alert", "notify me" |
| DCA & limit orders | `references/automations.md` | "DCA", "dollar cost average", "limit order", "recurring swap", "buy when price" |
| ERC-20 approve/revoke | `references/erc20.md` | "approve spender", "check allowance", "revoke" |
| Token risk checks | `references/token-risk.md` | "is this token safe", "honeypot check", "audit status" |
| x402 micropayments | `references/x402.md` | "x402", "micropayment", "payment-gated API", "preview payment", "quote endpoint cost", "how much does this API charge" |
| BNB Hack competition register/status | `references/compete.md` | "register for the competition", "BNB hack", "AI trading agent edition", "compete", "registration status" |
| Register/manage ERC-8004 agent identities | `references/erc8004.md` | "register agent identity", "erc8004", "agent NFT", "agentURI", "agent metadata", "identity registry", "mint agent" |
| Agent job escrows (ERC-8183 Agentic Commerce) | `references/erc8183.md` | "erc8183", "agentic commerce", "job escrow", "create job", "fund job", "submit deliverable", "settle job", "dispute policy", "policy-info", "agent payment escrow", "evaluator router" |
| Run MCP / REST server for AI agents | MCP server section below | "MCP server", "twak serve", "connect an agent", "REST API" |

Read `references/setup.md` alongside any other reference if the CLI isn't installed yet.

## MCP server

`twak serve` starts an MCP server on stdio exposing wallet actions to AI agents. Flags:

- `--rest` — start a REST HTTP server instead of the MCP stdio server
- `--port <n>` — REST server port (default `3000`)
- `--host <host>` — REST bind host (default `127.0.0.1`; use `0.0.0.0` to expose externally)
- `--password <password>` — wallet password (falls back to `TWAK_WALLET_PASSWORD` env var, then OS keychain)
- `--auto-lock <minutes>` — auto-lock the wallet after N minutes of inactivity
- `--wc-project-id <id>` — WalletConnect project ID (or set `WALLETCONNECT_PROJECT_ID`)
- `--watch` — background watcher that fires DCA/limit automations; requires the local agent wallet (see `references/automations.md`)
- `--watch-interval <duration>` — automation poll interval when `--watch` is set, e.g. `30s`, `5m`, `1h` (default 60s, min 5s)
