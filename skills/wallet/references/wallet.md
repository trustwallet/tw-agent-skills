
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

With `--json`, output is `{ addresses: [{ address, chain }] }` — the derived address for every supported chain (`chain` is the chain key). Human output shows only the chain count. Fails with `WALLET_EXISTS` if a wallet already exists (back up and delete `wallet.json` in the twak folder to recreate).

The password can also come from `TWAK_WALLET_PASSWORD` instead of `--password`.

## Get Addresses

```bash
twak wallet address --chain ethereum --json
twak wallet addresses --json                # all chains
```

Both accept `--password <pw>` (falls back to `TWAK_WALLET_PASSWORD` / OS keychain). `--json` output: `{ chain, address }` for `address`, `{ addresses: [{ address, chain }] }` for `addresses`.

## Check Status

```bash
twak wallet status --json
```

Output: `{ agentWallet: 'configured' | 'not configured', keychainPassword: 'stored' | 'not stored', chains, supportedChains, createdAt?, addressCount?, walletConnect }` — `chains` and `supportedChains` are numbers (count of supported chains); `createdAt` and `addressCount` appear only when a wallet exists. `walletConnect` is `{ connected: false }` or `{ connected: true, peer, address, expiresAt }` (ISO timestamp) for the stored WalletConnect session (see below). Accepts `--project-id <id>`.

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

Connect an external wallet (e.g. Trust Wallet mobile) for interactive transaction approvals. The private keys stay in that wallet; every transaction is approved there.

```bash
twak wallet connect
twak wallet connect --chains "ethereum,bsc"
twak wallet connect --timeout 120
twak wallet disconnect
```

`connect` prints a QR code and deep links, then waits for approval. `--json` output: `{ connected, address, chain, peer }` (`chain` is the chain key of the session's first account).

- `--project-id <id>` — WalletConnect project ID override (default: Trust Wallet's project; also `WALLETCONNECT_PROJECT_ID` or `twak init --wc-project-id`). No configuration is needed.
- `--chains <list>` — Comma-separated chains: chain keys, aliases or CAIP-2 IDs (default: all supported EVM chains); an unknown chain is rejected with `CHAIN_UNSUPPORTED`
- `--timeout <seconds>` — Connection timeout, a positive whole number (default: 300); anything else fails with `VALIDATION_ERROR`

Session behaviour:

- **One shared session.** The session is stored in `walletconnect.json` in the twak folder and shared by every `twak` command: a session paired with `twak wallet connect` is reused by `twak serve`, and survives restarts until it expires (about 7 days) or is revoked.
- **Pairing replaces the previous session.** `connect` revokes any stored session first.
- **`twak wallet disconnect`** revokes the stored session. `--json` output: `{ disconnected }` (`false` when there was no session). Accepts `--project-id <id>`.
- **EVM chains only.** Non-EVM chains cannot be used through WalletConnect.
- **Approvals.** Trust Wallet does not send a push notification for signing requests: the user must open the app to see and approve them. Requests expire after about 5 minutes.
- **Pairing outcome.** `connect` fails as soon as the pairing ends without a connection: `USER_REJECTED` (declined in the wallet), `WC_PAIRING_EXPIRED` (not approved within 5 minutes) or `WC_PAIRING_FAILED`; `WC_NOT_CONNECTED` when `--timeout` passes first.
- **Rejections.** A request declined in the wallet fails with `errorCode: "USER_REJECTED"`; other wallet-side failures with `WC_REQUEST_FAILED`. Do not retry a rejected request without asking the user.
- **"Not verified".** The wallet shows the connection (`TWAK`, `portal.trustwallet.com`) as not verified. This is expected: WalletConnect only verifies browser-based apps.
