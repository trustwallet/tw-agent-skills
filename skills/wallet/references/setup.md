
# Setup TWAK

Install and configure the Trust Wallet Agent Kit CLI for multichain crypto operations.

## Install

```bash
npm install -g @trustwallet/cli
```

Under the Trust Wallet plugin, whose MCP server pins a version, skip the install and use `npx -y @trustwallet/cli@0.24.3` instead of `twak`, with the server's `TWAK_HOME` (see the `trust-wallet-mcp` skill).

Verify installation:

```bash
twak --version
```

On failure, commands with `--json` emit `{ error, errorCode }` on stdout and exit 1.

## Guided Setup (Interactive)

```bash
twak setup
```

Interactive alternative to the manual env-var + `twak init` flow below: prompts for API credentials, wires twak into AI harnesses, and creates a wallet. With no flags it runs all three phases; flags restrict it to specific phases:

- `--reconfigure-creds` — re-prompt for API credentials even if already configured
- `--harness <name>` — run only the harness phase for one harness
- `--wallet` — run only the wallet phase

Set `TWAK_NONINTERACTIVE=1` or `NO_PROMPT=1` to force non-interactive mode (also auto-detected when neither stdin nor stderr is a TTY). For scripted/agent setups, prefer the manual flow below.

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

This reads from the environment and saves to `credentials.json` in the twak folder (mode 0600) with the HMAC secret additionally stored in the OS keychain (macOS Keychain / Linux Secret Service / Windows Credential Manager).

`twak init` options:

- `--wc-project-id <id>` — store a WalletConnect project ID override alongside the credentials (also read from `WALLETCONNECT_PROJECT_ID`); optional, twak uses Trust Wallet's project by default
- `--json` — JSON output: `{ configured: true, source: 'env' | 'cli' | 'file' }`; when `source` is `'file'` (existing config, nothing written) it also includes `accessIdPreview` and `walletConnectProjectId`
- `--api-key <key>` / `--api-secret <secret>` — pass credentials directly; avoid these (shell history exposure), env vars are preferred

With `--json` and no credentials available from flags, environment, or an existing config file, `init` fails with `errorCode: "VALIDATION_ERROR"`.

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

All files live in the twak folder: `$TWAK_HOME` when set, otherwise `~/.twak`. Set `TWAK_HOME` for the MCP server and for the commands you run alike (`twak setup` run with it set writes it into the MCP entries it configures). On hosts whose home folder is not durable, point it at a durable folder (Grok Bot: `/workspace/.twak`).

| Store | Path | Protection |
|-------|------|-----------|
| API credentials | `credentials.json` | File mode 0600, HMAC secret also in OS keychain |
| Wallet mnemonic | `wallet.json` | AES-256-GCM encrypted with user password |
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

JSON output fields: `chain` (the chain key, use as `--chain` argument), `name`, `symbol`, `namespace`, `coinId`. `--chain` also accepts aliases, CAIP-2 IDs (`eip155:56`) and EVM chain IDs (`56`); outputs always use the key.

Example entry:

```json
{ "chain": "ethereum", "name": "Ethereum", "symbol": "ETH", "namespace": "eip155", "coinId": 60 }
```

25+ chains are supported across EVM (eip155), Solana, Bitcoin (bip122), TRON, Cosmos, NEAR, Aptos, TON, and Sui namespaces.

### BSC Testnet

`bsctestnet` (BSC testnet, chain ID 97) is a special chain key that is **not** listed by `twak chains`. It is enabled only for ERC-20 transfer/approve/balance and ERC-8004 / ERC-8183 contract calls — not swaps, portfolio, market data, or onramp. Pass it via `--chain bsctestnet`. See `references/send.md` and `references/erc20.md` for usage.
