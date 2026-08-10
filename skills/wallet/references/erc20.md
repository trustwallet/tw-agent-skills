
# ERC-20 Token Approvals

Grant or inspect spending permissions for ERC-20 tokens on EVM chains. Required when a DeFi protocol needs permission to move tokens on your behalf.

## Specifying the token

Every `erc20` subcommand takes the token in one of two ways:

- **By asset ID** (default) — `--token c{coinId}_t{contractAddress}`, no `--chain`. The chain is derived from the coin ID.
- **By chain key** — `--chain <key> --token <contractAddress>`, where `--token` is a bare contract address (`0x…`).

Do not combine an asset ID with `--chain` — that is rejected. Native coins have no allowance, so an asset ID without a `_t<address>` part is also rejected.

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

`--amount` is in the token's smallest unit (e.g. wei for ETH-based tokens), or `unlimited` for max approval.

Examples:

```bash
# Approve 100000000 units (100 USDC, 6 decimals) for Uniswap V3
twak erc20 approve \
  --token c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 \
  --spender 0xE592427A0AEce92De3Edee1F18E0157C05861564 \
  --amount 100000000 --json

# Unlimited approval (requires --confirm-unlimited)
twak erc20 approve \
  --token c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 \
  --spender 0xE592427A0AEce92De3Edee1F18E0157C05861564 \
  --amount unlimited --confirm-unlimited --json
```

Output: `{ hash, chain, owner, spender, token, amount, explorer }`

## Revoke Approval

Dedicated command to set allowance to 0:

```bash
twak erc20 revoke \
  --token c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 \
  --spender 0xE592427A0AEce92De3Edee1F18E0157C05861564 \
  --json
```

## Check Allowance

```bash
twak erc20 allowance \
  --token <assetId> \
  --owner <ownerAddress> \
  --spender <spenderAddress> \
  --json
```

Output: `{ token, owner, spender, allowance }`

## Options

### `erc20 approve`
- `--token <assetIdOrAddress>` — Without `--chain`: ERC-20 asset ID. With `--chain`: the token contract address (required)
- `--spender <address>` — Spender contract address (required)
- `--amount <n>` — Amount in smallest unit, or `unlimited` (required)
- `--chain <key>` — Chain key (e.g. `base`, `bsctestnet`). When set, `--token` is the token contract address.
- `--confirm-unlimited` — Required when using `--amount unlimited` to acknowledge the risk
- `--password <pw>` — Wallet password (resolved from OS keychain if omitted)
- `--json` — Output as JSON

### `erc20 revoke`
- `--token <assetIdOrAddress>` — Without `--chain`: ERC-20 asset ID. With `--chain`: the token contract address (required)
- `--spender <address>` — Spender to revoke (required)
- `--chain <key>` — Chain key (e.g. `base`, `bsctestnet`). When set, `--token` is the token contract address.
- `--password <pw>` — Wallet password (resolved from OS keychain if omitted)
- `--json` — Output as JSON

### `erc20 allowance`
- `--token <assetIdOrAddress>` — Without `--chain`: ERC-20 asset ID. With `--chain`: the token contract address (required)
- `--owner <address>` — Owner address (required)
- `--spender <address>` — Spender address (required)
- `--chain <key>` — Chain key (e.g. `base`, `bsctestnet`). When set, `--token` is the token contract address.
- `--json` — Output as JSON

## Safety Notes

- Always verify the spender address is the correct contract
- Prefer exact amounts over `unlimited` — unlimited approvals are a common attack surface
- Use `erc20 revoke` to remove approvals you no longer need
- Check existing allowance before approving to avoid redundant transactions

## Asset ID Format

- ERC-20 tokens: `c{coinId}_t{contractAddress}`
  - `c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` — USDC on Ethereum
  - `c60_t0xdAC17F958D2ee523a2206206994597C13D831ec7` — USDT on Ethereum

## BSC Testnet

Pass `--chain bsctestnet` to approve/revoke/check allowances on BSC testnet (chain ID 97). The testnet key is not listed by `twak chains` and `--token` must be a contract address:

```bash
twak erc20 approve --chain bsctestnet --token 0x… --spender 0x… --amount unlimited --confirm-unlimited --json
```
