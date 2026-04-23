---
name: trust-wallet-cli
description: Trust Wallet CLI (`twak`) — install, create wallets, check balances, send tokens, swap, view history, set price alerts, DCA automations, limit orders, manage ERC-20 approvals, check token risk, browse trending/DApps, and run x402 micropayments. Use whenever the user wants to use the twak CLI, manage a crypto wallet from the terminal, send or swap tokens via command line, check portfolio, create price alerts, set up DCA, create limit orders, approve ERC-20 spenders, or interact with Trust Wallet from a shell. Also covers MCP server setup for AI agents.
---

# Trust Wallet CLI (`twak`)

Command-line interface for multichain crypto wallet operations. Install with `npm install -g @trustwallet/cli`.

## Quick Start

```bash
npm install -g @trustwallet/cli
twak auth status --json          # check credentials
twak wallet balance --chain ethereum --json
twak send --chain ethereum --to 0x... --amount 0.01 --token ETH
```

Read `references/setup.md` for full installation and authentication steps.

## Safety

Always confirm addresses and amounts before executing `send`, `swap`, or `approve` commands. Start with a small test transfer for new addresses. Keys remain local — signing happens on-device.

## Reference Guide

Read the reference that matches the user's task:

| Task | Reference | When to read |
|------|-----------|--------------|
| Install, auth, env vars | `references/setup.md` | First time setup, "install twak", "configure API keys" |
| List supported chains, chain keys | `references/setup.md` | "what chains are supported", "list chains", "show chain keys", "what is the chain key for X" |
| Create wallet, keychain, sign | `references/wallet.md` | "create wallet", "keychain", "sign message", "wallet status" |
| Balance, holdings, portfolio | `references/balance.md` | "check balance", "portfolio", "token holdings" |
| Send tokens, ENS transfers | `references/send.md` | "send ETH", "transfer to", "vitalik.eth" |
| Swap tokens, cross-chain | `references/swap.md` | "swap ETH for USDC", "bridge", "cross-chain swap" |
| Prices, trending, DApps | `references/market.md` | "price of", "trending tokens", "dapps" |
| Transaction history | `references/history.md` | "tx history", "transaction details" |
| Price alerts | `references/alerts.md` | "alert when ETH", "price alert", "notify me" |
| DCA & limit orders | `references/automations.md` | "DCA", "dollar cost average", "limit order", "recurring swap", "buy when price" |
| ERC-20 approve/revoke | `references/erc20.md` | "approve spender", "check allowance", "revoke" |
| Token risk checks | `references/token-risk.md` | "is this token safe", "honeypot check", "audit status" |
| x402 micropayments | `references/x402.md` | "x402", "micropayment", "payment-gated API" |

Read `references/setup.md` alongside any other reference if the CLI isn't installed yet.
