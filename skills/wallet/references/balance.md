
# Check Balances

Query native balances, token holdings, and full portfolio with USD values across all supported chains.

On error, all commands emit `{ error, errorCode }` on stdout (with `--json`) and exit with code 1.

## Prerequisites

- Authenticated (`twak auth status`)

## Own Wallet Balance

Native balance + token holdings per chain (password auto-resolved from OS keychain):

```bash
twak wallet balance --chain ethereum --json
twak wallet balance --chain solana --json
twak wallet balance --chain bsc --json
twak wallet balance --all --json
twak wallet balance --chain ethereum --no-tokens --json  # native only, skip token lookup
```

- `--chain <key>` — Single chain (chain key, e.g. `bsc`)
- `--all` — All chains with funds. Exactly one of `--chain`/`--all` is required; passing both or neither → `VALIDATION_ERROR`
- `--no-tokens` — Skip token balance lookup (faster, native balance only)
- `--password <pw>` — Wallet password (falls back to keychain / `TWAK_WALLET_PASSWORD`)

Output: `{ chain, address, symbol, available, staked?, total, totalUsd, tokens }`

- `chain` — the chain key you passed (e.g. `bsc`)
- `staked` — omitted when zero
- `totalUsd` — number or `null` when no fiat value available
- `tokens` — array of `{ symbol, contract, balance }` (zero balances excluded)
- With `--all`, output is an ARRAY of these objects, filtered to chains with a non-zero native balance or tokens

## Full Portfolio

Native balances + ERC-20/token holdings + USD values across all chains in one command:

```bash
twak wallet portfolio --json
twak wallet portfolio --chains ethereum,base,bsc,solana --json
```

Default chains: ethereum, arbitrum, optimism, polygon, bsc, avalanche, base, fantom, linea, scroll, zksync, blast, sonic, celo, aurora, solana, bitcoin, litecoin, dogecoin, tron, cosmos, near, aptos, ton, sui.

There is no `twak holdings` command — use `twak wallet balance` (native + token holdings per chain) or `twak wallet portfolio` for the agent wallet, or `twak balance --token <contract>` for a single token on any address.

## Any Address Balance

Query balance for any address (no wallet required). One of `--coin`/`--chain` is required, else `VALIDATION_ERROR`:

```bash
twak balance --address <addr> --coin 60 --json        # Ethereum (SLIP44 coin ID)
twak balance --address <addr> --chain bsc --json      # chain key alternative to --coin
twak balance --address <addr> --coin 0 --json         # Bitcoin
twak balance --address <addr> --chain ethereum --token 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 --json  # ERC-20
```

- `--coin <coinId>` — SLIP44 coin ID (native token)
- `--chain <key>` — Chain key (alternative to `--coin`)
- `--token <address>` — Token contract address (for ERC-20 balances)

Output: `{ address, chain, symbol, token?, available, staked?, total, totalUsd, raw }`

- `chain` — the chain's internal id, which can differ from the chain key (e.g. `smartchain` for BSC)
- `token` — present only when `--token` was passed
- `staked` — omitted when zero; `totalUsd` — number or `null`

## Search Tokens

Find tokens by name, symbol, or contract address:

```bash
twak search "USDC" --limit 10 --json
twak search "pepe" --json
twak search "USDC" --networks ethereum,bsc --json
```

- `--networks <names>` — Comma-separated chain names or numeric coin IDs; unknown name → `CHAIN_UNSUPPORTED`
- `--limit <n>` — Max results (default: 10)

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
