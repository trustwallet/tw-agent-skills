
# Wallet Management

Non-custodial HD (BIP39) wallet that derives addresses across 25+ chains. Keys remain local — signing happens on-device and private keys never leave the machine.

On failure, commands with `--json` emit `{ error, errorCode }` on stdout and exit 1.

## Prerequisites

- Authenticated (`twak auth status`)

## Create a Wallet

```bash
twak wallet create --password <pw>
twak wallet create --password <pw> --no-keychain            # skip keychain
twak wallet create --password <pw> --skip-password-check    # skip strength validation (test only)
```

Password must be at least 8 characters with mixed case and a number. Use `--skip-password-check` only for test wallets.

With `--json`, output is `{ addresses: [{ chainId, address }] }` — the derived address for every supported chain. Human output shows only the chain count. Fails with `WALLET_EXISTS` if a wallet already exists (back up and delete `~/.twak/wallet.json` to recreate).

## Get Addresses

```bash
twak wallet address --chain ethereum --json
twak wallet addresses --json                # all chains
```

Both accept `--password <pw>` (falls back to `TWAK_WALLET_PASSWORD` / OS keychain).

## Check Status

```bash
twak wallet status --json
```

Output: `{ agentWallet: 'configured' | 'not configured', keychainPassword: 'stored' | 'not stored', chains, supportedChains, createdAt?, addressCount? }` — `chains` and `supportedChains` are numbers (count of supported chains); `createdAt` and `addressCount` appear only when a wallet exists.

## Register with Backend

```bash
twak wallet register --json
```

Re-registers the wallet's addresses with the Trust Wallet backend (enables token holdings / portfolio tracking — `wallet create` does this automatically, but it can fail silently). Accepts `--password <pw>`. Output: `{ registered: true, chains }` (`chains` = number of registered addresses).

## Sign a Message

```bash
twak wallet sign-message --chain ethereum --message "hello world" --json
```

Output: `{ chain, address, message, signature, digest }` — on EVM chains the signature is `0x`-prefixed and `digest` is the EIP-191 hash the signature recovers against (verifiable with `cast hash-message` / `cast wallet verify`); non-EVM chains omit `digest`.

## Keychain Management

The wallet password can be stored in the OS keychain so `--password` is not needed on every command:

```bash
twak wallet keychain save --password <pw>
twak wallet keychain check
twak wallet keychain delete
```

`keychain check --json` output: `{ available, stored }` (booleans — keychain availability on this system, and whether a password is stored).

## Password Resolution Order

1. `--password <pw>` CLI flag
2. `TWAK_WALLET_PASSWORD` environment variable
3. OS keychain (macOS Keychain / Linux Secret Service / Windows Credential Manager)

## WalletConnect

Connect an external wallet (e.g. Trust Wallet mobile) for interactive transaction approvals:

```bash
twak wallet connect --project-id <id>
twak wallet connect --project-id <id> --chains "eip155:1,eip155:56"
twak wallet connect --project-id <id> --timeout 120
```

- `--project-id <id>` — WalletConnect project ID (or set `WALLETCONNECT_PROJECT_ID` env var)
- `--chains <list>` — Comma-separated CAIP-2 chain IDs (default: major EVM chains)
- `--timeout <seconds>` — Connection timeout (default: 300)
