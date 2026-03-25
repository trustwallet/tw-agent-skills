---
name: wallet
description: Create and manage a non-custodial HD wallet — addresses, status, signing, keychain, and WalletConnect.
---

# Wallet Management

Non-custodial HD (BIP39) wallet that derives addresses across 25+ chains. Keys remain local — signing happens on-device and private keys never leave the machine.

## Prerequisites

- Authenticated (`twak auth status`)

## Create a Wallet

```bash
twak wallet create --password <pw>
twak wallet create --password <pw> --no-keychain  # skip keychain
```

Output includes derived addresses for all major chains.

## Get Addresses

```bash
twak wallet address --chain ethereum --json
twak wallet addresses --json                # all chains
```

## Check Status

```bash
twak wallet status --json
```

Output: `{ agentWallet: bool, keychainPassword: bool, walletConnect: { connected, address } }`

## Sign a Message

```bash
twak wallet sign-message --chain ethereum --message "hello world" --json
```

Output: `{ chain, address, message, signature }`

## Keychain Management

The wallet password can be stored in the OS keychain so `--password` is not needed on every command:

```bash
twak wallet keychain save --password <pw>
twak wallet keychain check
twak wallet keychain delete
```

## Password Resolution Order

1. `--password <pw>` CLI flag
2. `TWAK_WALLET_PASSWORD` environment variable
3. OS keychain (macOS Keychain / Linux Secret Service / Windows Credential Manager)

## WalletConnect

Connect an external wallet (e.g. Trust Wallet mobile) for interactive transaction approvals:

```bash
twak wallet connect
```

Requires `WALLETCONNECT_PROJECT_ID`.
