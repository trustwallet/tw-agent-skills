---
name: revettr
description: Revettr counterparty risk scoring API for agentic commerce. Scores wallets, domains, IPs, and company names from 0 to 100 using on-chain signals, WHOIS, sanctions lists, and cross-chain trust profiles via InsumerAPI. Use whenever the user asks about counterparty risk, wallet reputation, pre-transaction safety checks, x402 counterparty verification, risk attestation, sanctions screening, or wants to call the Revettr API at revettr.com. Covers free and x402-paid tiers, signed JWS attestations, and batch scoring.
---

# Revettr

Counterparty risk scoring API at `revettr.com`. Scores wallets, domains, IPs, and company names 0 to 100 before you send funds.

## Quick Start

Read `references/setup.md` first for endpoint discovery, payment setup, and the free tier.

## Reference Guide

Read the reference that matches the user's task:

| Task | Reference | When to read |
|------|-----------|--------------|
| Discovery, payment, free tier | `references/setup.md` | First time setup, x402 payment config, "how do I call Revettr" |
| Risk score, attestation, batch scoring | `references/risk-check.md` | "check this wallet", "is this counterparty safe", "pre-send check", "batch score", "signed attestation" |

Read `references/setup.md` alongside `references/risk-check.md` if the user hasn't configured x402 payment yet or needs the free tier.
