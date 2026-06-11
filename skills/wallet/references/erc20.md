
# ERC-20 Token Approvals

Grant or inspect spending permissions for ERC-20 tokens on EVM chains. Required when a DeFi protocol needs permission to move tokens on your behalf.

## Specifying the token

Every `erc20` subcommand takes the token in one of two ways:

- **By asset ID** (default) — `--token c{coinId}_t{contractAddress}`, no `--chain`. The chain is derived from the coin ID.
- **By chain key** — `--chain <key> --token <contractAddress>`, where `--token` is a bare contract address (`0x…`).

Do not combine an asset ID with `--chain` — that is rejected. Native coins have no allowance, so an asset ID without a `_t<address>` part is also rejected.

## Prerequisites

- Authenticated (`twak auth status`)
- Agent wallet created (`twak wallet create --password <pw>`) — needed for `approve` and `revoke` only; `allowance` is a read and requires no wallet or password

## Approve a Spender

```bash
twak erc20 approve \
  --token <assetId> \
  --spender <contractAddress> \
  --amount <n> \
  --json
```

`--amount` is in the token's own smallest unit — decimals vary per token (e.g. `100000000` = 100 USDC at 6 decimals; an 18-decimal token would need `100000000000000000000`). Or pass `unlimited` for max approval (requires `--confirm-unlimited`).

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

Output: `{ hash, chain, owner, spender, token, amount, explorer }` — `chain` is the resolved chain key, `owner` the wallet address, `token` echoes the raw `--token` input (asset ID or contract address, whichever you passed), `amount` echoes the literal input (including the string `"unlimited"`, not the expanded max uint256), `explorer` is the explorer tx URL or `''` when the chain has no explorer mapping.

## Revoke Approval

Dedicated command to set allowance to 0:

```bash
twak erc20 revoke \
  --token c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 \
  --spender 0xE592427A0AEce92De3Edee1F18E0157C05861564 \
  --json
```

Output: `{ hash, chain, owner, spender, token, explorer }` — same keys as `approve` minus `amount`; `token` echoes the raw `--token` input, `explorer` is `''` when the chain has no explorer mapping.

## Check Allowance

```bash
twak erc20 allowance \
  --token <assetId> \
  --owner <ownerAddress> \
  --spender <spenderAddress> \
  --json
```

Output: `{ token, owner, spender, allowance }` — `token`, `owner`, `spender` echo the inputs; `allowance` is a decimal string in the token's smallest unit (e.g. `"100000000"`).

## Options

### `erc20 approve`
- `--token <assetIdOrAddress>` — Without `--chain`: ERC-20 asset ID. With `--chain`: the token contract address (required)
- `--spender <address>` — Spender contract address (required)
- `--amount <n>` — Amount in smallest unit, or `unlimited` (required)
- `--chain <key>` — Chain key (e.g. `base`, `bsctestnet`). When set, `--token` is the token contract address.
- `--confirm-unlimited` — Required when using `--amount unlimited` to acknowledge the risk
- `--password <pw>` — Wallet password (falls back to `TWAK_WALLET_PASSWORD` env var, then OS keychain)
- `--json` — Output as JSON

### `erc20 revoke`
- `--token <assetIdOrAddress>` — Without `--chain`: ERC-20 asset ID. With `--chain`: the token contract address (required)
- `--spender <address>` — Spender to revoke (required)
- `--chain <key>` — Chain key (e.g. `base`, `bsctestnet`). When set, `--token` is the token contract address.
- `--password <pw>` — Wallet password (falls back to `TWAK_WALLET_PASSWORD` env var, then OS keychain)
- `--json` — Output as JSON

### `erc20 allowance`
- `--token <assetIdOrAddress>` — Without `--chain`: ERC-20 asset ID. With `--chain`: the token contract address (required)
- `--owner <address>` — Owner address (required)
- `--spender <address>` — Spender address (required)
- `--chain <key>` — Chain key (e.g. `base`, `bsctestnet`). When set, `--token` is the token contract address.
- `--json` — Output as JSON

## Errors

With `--json`, errors emit a single `{ error, errorCode }` object to stdout and exit with code 1.

| errorCode | Trigger |
|---|---|
| `VALIDATION_ERROR` | Asset ID (`c…`) combined with `--chain`; malformed token ID; `--amount unlimited` without `--confirm-unlimited`; invalid contract address inside the asset ID (`allowance`) |
| `NOT_ERC20` | Asset ID without a `_t<address>` part — native coins have no allowance |
| `CHAIN_UNSUPPORTED` | Unknown `--chain` key, or unsupported coin ID in the asset ID |

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
