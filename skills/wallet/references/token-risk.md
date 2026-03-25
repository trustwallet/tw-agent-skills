
# Token Security & Validation

Check token risk signals and validate wallet addresses before interacting with unfamiliar assets.

## Token Risk Check

Checks for honeypot detection, audit status, freeze authority, and other security signals:

```bash
twak risk <assetId> --json
```

Examples:

```bash
twak risk c60_t0xdAC17F958D2ee523a2206206994597C13D831ec7 --json  # USDT
twak risk c60_t0x6982508145454Ce325dDbE47a25d4ec3d2311933 --json  # PEPE
```

## Address Validation

Validate that an address is well-formed for its chain:

```bash
twak validate --address <addr> --json
```

## When to Use

Run a risk check before:
- Swapping to an unfamiliar token
- Approving a token spender
- Interacting with a new contract
- The user asks about a token's safety

Key risk signals to watch for:
- **Honeypot**: Token cannot be sold after buying
- **No audit**: Contract has not been independently audited
- **Freeze authority**: Issuer can freeze your tokens (common on Solana)
- **High tax**: Buy/sell tax above normal levels

## Asset ID Format

- Native tokens: `c{coinId}` (e.g., `c60` for ETH)
- ERC-20 tokens: `c{coinId}_t{contractAddress}`

Use `twak search <query>` to find a token's asset ID if you don't know it.
