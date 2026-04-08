
# Setup TWAK

Install and configure the Trust Wallet Agent Kit CLI for multichain crypto operations.

## Install

```bash
npm install -g @trustwallet/cli
```

Verify installation:

```bash
twak --version
```

## Authenticate

### Step 1: Check existing credentials

```bash
twak auth status --json
```

If `configured: true`, authentication is already set up — skip to **Create a Wallet**.

### Step 2: Check environment variables

```bash
echo "${TWAK_ACCESS_ID:+set}" "${TWAK_HMAC_SECRET:+set}"
```

If both print `set`, credentials are available via environment — skip to verification.

### Step 3: Guide the user to set environment variables

If credentials are not configured, ask the user to obtain API keys from **https://portal.trustwallet.com** and set them as environment variables. Never ask the user to pass secrets directly as CLI arguments — environment variables are safer (no shell history exposure).

Tell the user to add these to their shell profile (`~/.zshrc`, `~/.bashrc`, or equivalent):

```bash
export TWAK_ACCESS_ID=your_access_id
export TWAK_HMAC_SECRET=your_hmac_secret
```

Then reload:

```bash
source ~/.zshrc  # or ~/.bashrc
```

### Step 4: Persist to local config

Once env vars are set, run init to persist credentials to the encrypted local store and OS keychain:

```bash
twak init
```

This reads from the environment and saves to `~/.twak/credentials.json` (mode 0600) with the HMAC secret additionally stored in the OS keychain (macOS Keychain / Linux Secret Service / Windows Credential Manager).

### Step 5: Verify

```bash
twak auth status --json
```

Expected output:

```json
{ "configured": true, "source": "file", "accessId": "abc12345" }
```

## Security Rules

- **Never pass `--api-key` or `--api-secret` as CLI arguments** — they appear in shell history
- **Never echo, log, or display** the HMAC secret or mnemonic phrases
- **Never store secrets in code, commits, or chat messages**
- Environment variables and OS keychain are the only safe channels

## Create a Wallet

After authentication, create a non-custodial HD wallet:

```bash
twak wallet create --password <pw>
```

This derives addresses for 25+ chains and saves the encrypted wallet locally. The password is auto-saved to the OS keychain.

## Verify Full Setup

```bash
twak auth status --json
twak wallet status --json
twak wallet balance --chain ethereum --json
```

## Credential Storage

| Store | Path | Protection |
|-------|------|-----------|
| API credentials | `~/.twak/credentials.json` | File mode 0600, HMAC secret also in OS keychain |
| Wallet mnemonic | `~/.twak/wallet.json` | AES-256-GCM encrypted with user password |
| Wallet password | OS keychain | macOS Keychain / Linux Secret Service / Windows Credential Manager |

## Supported Chains

List all supported chains:

```bash
twak chains
```

For structured output (useful for scripting or agents):

```bash
twak chains --json
```

JSON output fields: `key` (use as `--chain` argument), `name`, `symbol`, `namespace`, `chainId`, `coinId`.

Example entry:

```json
{ "key": "ethereum", "name": "Ethereum", "symbol": "ETH", "namespace": "eip155", "chainId": "ethereum", "coinId": 60 }
```

25 chains are supported across EVM (eip155), Solana, Bitcoin (bip122), TRON, Cosmos, NEAR, Aptos, TON, and Sui namespaces.
