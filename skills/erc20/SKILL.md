---
name: erc20
description: Approve ERC-20 token spending and check existing allowances for DeFi protocols.
---

# ERC-20 Token Approvals

Grant or inspect spending permissions for ERC-20 tokens on EVM chains. Required when a DeFi protocol needs permission to move tokens on your behalf.

## Prerequisites

- Authenticated (`twak auth status`)
- Agent wallet created (`twak wallet create --password <pw>`)

## Approve a Spender

```bash
twak erc20 approve \
  --token <assetId> \
  --spender <contractAddress> \
  --amount <n> \
  --json
```

Examples:

```bash
# Approve 100 USDC for Uniswap V3
twak erc20 approve \
  --token c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 \
  --spender 0xE592427A0AEce92De3Edee1F18E0157C05861564 \
  --amount 100 --json

# Revoke approval (set to 0)
twak erc20 approve \
  --token c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 \
  --spender 0xE592427A0AEce92De3Edee1F18E0157C05861564 \
  --amount 0 --json
```

Output: `{ hash, chain, owner, spender, token, amount, explorer }`

## Check Allowance

```bash
twak erc20 allowance \
  --token <assetId> \
  --owner <ownerAddress> \
  --spender <spenderAddress> \
  --json
```

Output: `{ token, owner, spender, allowance }`

## Safety Notes

- Always verify the spender address is the correct contract
- Prefer exact amounts over `unlimited` — unlimited approvals are a common attack surface
- Check existing allowance before approving to avoid redundant transactions
- To revoke, approve with `--amount 0`

## Asset ID Format

- ERC-20 tokens: `c{coinId}_t{contractAddress}`
  - `c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` — USDC on Ethereum
  - `c60_t0xdAC17F958D2ee523a2206206994597C13D831ec7` — USDT on Ethereum
