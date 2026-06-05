
# Send Tokens

Transfer native tokens or ERC-20 tokens across supported chains. Supports ENS names and human-readable addresses. Keys remain local — signing happens on-device.

## Prerequisites

- Authenticated (`twak auth status`)
- Agent wallet created (`twak wallet create --password <pw>`)

## Safety: Always Verify Before Sending

1. Confirm the destination address is correct
2. Check balance before sending
3. Start with a small test transfer for new addresses

## Steps

1. Check wallet address on the target chain:
   ```bash
   twak wallet address --chain <chainKey> --json
   ```

2. Check balance:
   ```bash
   twak wallet balance --chain <chainKey> --json
   ```

3. Execute the transfer:
   ```bash
   twak transfer --to <address> --amount <n> --token <assetId> --json
   ```

Password is auto-resolved from OS keychain. Use `--password <pw>` to override.

## Selecting the chain & token

Two equivalent ways to specify what to send:

1. **By asset ID** (default) — `--token <assetId>`, no `--chain`. The chain is derived from the asset ID's coin ID:
   ```bash
   twak transfer --to 0x… --amount 1.5 --token c60 --json                  # native ETH
   twak transfer --to 0x… --amount 100 --token c60_t0xA0b8…eB48 --json      # USDC on Ethereum
   ```

2. **By chain key** — `--chain <key>` plus an optional bare token contract address (omit `--token` for the native coin):
   ```bash
   twak transfer --to 0x… --amount 1.5 --chain base --json                          # native coin on Base
   twak transfer --to 0x… --amount 100 --chain base --token 0x833589…2913 --json    # token by address on Base
   ```

Do not combine an asset ID with `--chain` (e.g. `--chain base --token c60`) — that is rejected. Use one form or the other.

## ENS & Human-Readable Names

The `--to` field resolves ENS names automatically:

```bash
twak transfer --to vitalik.eth --amount 0.01 --token c60 --json
twak transfer --to myname.crypto --amount 100 --token c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 --json
```

## Amount Format

Amounts are human-readable (not smallest unit):

```bash
--amount 1.5       # 1.5 ETH
--amount 100       # 100 USDC
--amount 0.001     # 0.001 BTC
```

Decimals are resolved automatically via the API.

## Asset IDs

- Native tokens: `c{coinId}` (e.g., `c60` for ETH, `c20000714` for BNB, `c501` for SOL)
- ERC-20 tokens: `c{coinId}_t{contractAddress}`

## Options

- `--to <address>` — Destination address or ENS name (required)
- `--amount <n>` — Amount in human-readable format (required)
- `--token <assetIdOrAddress>` — Without `--chain`: the asset ID (e.g. `c60`, `c60_t0x…`) — required in this form. With `--chain`: a bare token contract address (`0x…`); omit it to send the native coin.
- `--chain <key>` — Chain key (e.g. `base`, `ethereum`, `bsctestnet`). When set, `--token` is a token contract address. See **Selecting the chain & token** above.
- `--confirm-to <address>` — Pin the expected resolved address. Transfer is rejected if ENS resolution returns a different address.
- `--max-usd <n>` — Maximum allowed transfer value in USD (default: 10000). Transfer is rejected if value exceeds this.
- `--skip-safety-check` — Bypass the USD value safety check
- `--password <pw>` — Wallet password (resolved from OS keychain if omitted)
- `--json` — Output as JSON

## Supported Chains

Run `twak chains` for all supported chains and coin IDs.

## BSC Testnet

`--chain bsctestnet` targets BSC testnet (chain ID 97). This testnet key is intentionally **not** listed by `twak chains` — it is enabled only for a limited set of operations: ERC-20 transfer/approve/balance and ERC-8004 / ERC-8183 contract calls. Swaps, portfolio, market data, and onramp stay mainnet-only.

```bash
# Native tBNB transfer
twak transfer --to 0x… --amount 0.01 --chain bsctestnet --json

# ERC-20 token transfer (token by contract address)
twak transfer --to 0x… --amount 1 --chain bsctestnet --token 0x… --json
```

The testnet wallet address is the same as the mainnet BSC address (`twak wallet address --chain bsc`); fund it from a BSC testnet faucet. Note: `twak wallet balance --chain bsctestnet` is **not** supported (the CLI balance command reads a mainnet data gateway). To read testnet balances, use the MCP `token_balance` tool with `chain: "bsctestnet"`, which queries the testnet RPC directly.
