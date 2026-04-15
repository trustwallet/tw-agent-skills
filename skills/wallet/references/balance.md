
# Check Balances

Query native balances, token holdings, and full portfolio with USD values across all supported chains.

## Prerequisites

- Authenticated (`twak auth status`)

## Own Wallet Balance

Native token balance on a specific chain (password auto-resolved from OS keychain):

```bash
twak wallet balance --chain ethereum --json
twak wallet balance --chain solana --json
twak wallet balance --chain bsc --json
twak wallet balance --all --json                # all chains with funds
twak wallet balance --chain ethereum --no-tokens --json  # native only, skip token lookup
```

- `--all` — Show balances across all chains with funds
- `--no-tokens` — Skip token balance lookup (faster, native balance only)

Output: `{ chain, address, symbol, available, staked, pending, total }`

## Full Portfolio

Native balances + ERC-20/token holdings + USD values across all chains in one command:

```bash
twak wallet portfolio --json
twak wallet portfolio --chains ethereum,base,bsc,solana --json
```

Default chains: all 25 supported chains. Use `--chains` to narrow scope.

## Any Address Balance

Query native balance for any address (no wallet required):

```bash
twak balance --address <addr> --coin 60 --json        # Ethereum
twak balance --address <addr> --coin 501 --json       # Solana
twak balance --address <addr> --coin 20000714 --json  # BSC
twak balance --address <addr> --coin 0 --json         # Bitcoin
```

## Token Holdings

List all token holdings for an address:

```bash
twak holdings --address <addr> --chain ethereum --json
```

## Search Tokens

Find tokens by name, symbol, or contract address:

```bash
twak search "USDC" --limit 10 --json
twak search "pepe" --json
```

## Asset Info

Get details about a specific asset:

```bash
twak asset c60 --json            # ETH
twak asset c501 --json           # SOL
```

## Common Asset IDs

| Asset | ID |
|-------|----|
| ETH | `c60` |
| BTC | `c0` |
| BNB | `c20000714` |
| SOL | `c501` |
| MATIC | `c966` |
| USDC (Ethereum) | `c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` |
| USDT (Ethereum) | `c60_t0xdAC17F958D2ee523a2206206994597C13D831ec7` |

## Asset ID Format

- Native tokens: `c{coinId}` (e.g., `c60` for ETH)
- ERC-20 tokens: `c{coinId}_t{contractAddress}`
