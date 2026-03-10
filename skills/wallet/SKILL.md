---
name: wallet
description: Manage agent wallets and WalletConnect sessions — create wallets, get addresses across 25+ chains, check balances, and connect external wallets via QR code. Use this whenever someone asks about their wallet address, wants to create a new wallet, check connection status, or connect an external wallet.
---

# Wallet Management

Create and manage agent wallets, retrieve addresses across chains, and connect external wallets via WalletConnect.

The agent wallet is an HD wallet derived from an encrypted mnemonic stored at `~/.tw-agent/wallet.json`. It supports 25+ chains from a single seed phrase.

## Password Resolution

MCP tools that access the agent wallet require a password to decrypt the mnemonic. The password is resolved in this order:

1. **`password` parameter** — passed directly in the tool call
2. **`TWAK_WALLET_PASSWORD` environment variable** — for CI / headless environments
3. **OS Keychain** — stored automatically when the wallet is created (service: `tw-agent`, account: `wallet`)

## Encryption

The mnemonic is encrypted with **AES-256-GCM** using PBKDF2 key derivation (600,000 iterations, SHA-256). The plaintext mnemonic is never stored on disk.

## Actions

### Create Wallet

Create a new agent wallet with a generated mnemonic.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `password` | string | Yes | Password to encrypt the wallet (min 8 characters) |

**Response:**

```json
{
  "message": "Agent wallet created successfully",
  "addresses": [
    { "address": "0xABC...", "chainId": "ethereum" },
    { "address": "0xABC...", "chainId": "bsc" },
    { "address": "9cwz...", "chainId": "solana" }
  ]
}
```

The password is saved to the OS keychain by default. Use `--no-keychain` when creating via CLI to skip keychain storage.

---

### Get Address

Get the agent wallet address for a specific chain.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `chainKey` | string | Yes | Chain key (e.g., `ethereum`, `bsc`, `solana`, `bitcoin`) |
| `password` | string | Yes | Wallet password |

**Response:**

```json
{
  "chainKey": "ethereum",
  "address": "0xD4BC2539F3127925614FEdE66B6f10E2a466bb9B"
}
```

---

### List Addresses

List all agent wallet addresses across all supported chains.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `password` | string | Yes | Wallet password |

**Response:**

```json
{
  "addresses": [
    { "address": "0xD4BC...", "chainId": "ethereum" },
    { "address": "0xD4BC...", "chainId": "bsc" },
    { "address": "9cwz...", "chainId": "solana" },
    { "address": "bc1q...", "chainId": "bitcoin" },
    { "address": "TBF3...", "chainId": "tron" }
  ],
  "count": 25
}
```

---

### Wallet Balance

Get the native token balance for the agent wallet on a specific chain.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `chainKey` | string | Yes | Chain key (e.g., `ethereum`, `bsc`) |
| `password` | string | Yes | Wallet password |

**Response:**

```json
{
  "chainKey": "ethereum",
  "address": "0xD4BC2539F3127925614FEdE66B6f10E2a466bb9B",
  "balance": {
    "available": "3126775296453912",
    "total": "3126775296453912"
  }
}
```

Balance is in the smallest unit (wei for ETH, lamports for SOL, satoshis for BTC). Divide by `10^decimals` for human-readable amounts.

---

### Get Wallet Status

Check connection status for both agent wallet and WalletConnect.

**Parameters:** None

**Response:**

```json
{
  "agent": {
    "connected": true,
    "addresses": [
      { "address": "0xD4BC...", "chainId": "ethereum" },
      { "address": "9cwz...", "chainId": "solana" }
    ]
  }
}
```

---

### Connect Wallet (WalletConnect)

Connect an external wallet via WalletConnect. Returns a QR code URI and deep links.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `chains` | string[] | No | Chains to connect (default: `["eip155:1"]`) |

Requires `WALLETCONNECT_PROJECT_ID` environment variable and `--walletconnect` flag when starting the MCP server.

**Response:**

```json
{
  "success": true,
  "uri": "wc:abc123...",
  "deepLinks": {
    "native": "trust://wc?uri=...",
    "universal": "https://link.trustwallet.com/wc?uri=..."
  },
  "qrCode": {
    "terminal": "▄▄▄▄▄...",
    "imageUrl": "https://..."
  },
  "expiresAt": 1709500000
}
```

## Supported Chains

The agent wallet derives addresses for 25+ chains including all EVM chains, Solana, Bitcoin, Litecoin, Dogecoin, Tron, Cosmos, NEAR, Aptos, TON, and Sui. See [setup](../setup/SKILL.md) for the complete chain list.
