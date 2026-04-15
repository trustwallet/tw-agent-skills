
# Token Swap

Execute same-chain or cross-chain token swaps via Trust Wallet. Supports all EVM chains and Solana.

## Prerequisites

- Authenticated (`twak auth status`)
- Agent wallet created (`twak wallet create --password <pw>`)

## Safety: Always Quote First

Always get a quote before executing to confirm rates and price impact:

```bash
# By amount: twak swap <amount> <from> <to>
twak swap 1 ETH USDC --chain ethereum --quote-only --json
twak swap 10 SOL USDC --chain solana --quote-only --json
twak swap 100 USDC USDC --chain ethereum --to-chain arbitrum --quote-only --json

# By USD value: twak swap <from> <to> --usd <amount>
twak swap ETH USDC --chain ethereum --usd 100 --quote-only --json
```

Only execute after the user confirms the quote.

## Execute a Swap

Password is auto-resolved from OS keychain:

```bash
# Same-chain EVM
twak swap 1 ETH USDC --chain ethereum --json

# Solana
twak swap 5 SOL BONK --chain solana --json

# Cross-chain (Ethereum → Arbitrum)
twak swap 100 USDC USDC --chain ethereum --to-chain arbitrum --json

# Cross-chain (ETH → BSC)
twak swap 0.01 ETH BNB --chain ethereum --to-chain bsc --json
```

## Options

- `--chain <key>` — Source chain (default: ethereum)
- `--to-chain <key>` — Destination chain for cross-chain swaps
- `--slippage <pct>` — Slippage tolerance % (default: 1)
- `--usd <amount>` — Swap a USD-equivalent amount of the source token (e.g. `twak swap ETH USDC --usd 100`)
- `--quote-only` — Get quote without executing
- `--password <pw>` — Wallet password (resolved from OS keychain if omitted)
- `--json` — Output as JSON

## Token Resolution

Use token symbols (ETH, USDC, USDT, DAI, WETH, WBTC, SOL, BONK, JUP) or contract addresses. The CLI resolves symbols to addresses automatically.

## Chain Key vs Chain ID

Always use the **map key** for `--chain` arguments (e.g., `bsc`, `ethereum`, `base`). BSC uses `chain.id = smartchain` internally — the CLI handles this automatically. Run `twak chains` for valid keys.

## Supported Chains

Ethereum, Arbitrum, Optimism, Polygon, BSC, Avalanche, Base, Fantom, Linea, Scroll, zkSync, Blast, Sonic, Celo, Aurora, Solana.
