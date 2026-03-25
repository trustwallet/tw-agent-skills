
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
- `--token <assetId>` — Token asset ID (required)
- `--password <pw>` — Wallet password (resolved from OS keychain if omitted)
- `--json` — Output as JSON

## Supported Chains

Run `twak chains` for all supported chains and coin IDs.
