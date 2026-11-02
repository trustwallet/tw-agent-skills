---
name: trust-wallet-mcp
description: Use Trust Wallet through the `twak` MCP server (bundled with the Trust Wallet plugin, including in Grok Bot) - set it up, connect the user's Trust Wallet app (WalletConnect) or create a separate agent wallet, check balances, send, receive, swap, buy or sell crypto. Use whenever the user mentions Trust Wallet, their crypto wallet, balances, sending or swapping tokens, buying or selling crypto, or when a `twak` MCP tool is missing or fails with CREDENTIALS_MISSING, PASSWORD_MISSING or WALLET_NOT_BOUND.
---

# Trust Wallet through the `twak` MCP server

The `twak` MCP server (started by this plugin) exposes Trust Wallet actions as
tools: `get_wallet_status`, `switch_wallet_mode`, `list_addresses`,
`get_address`, `wallet_portfolio`, `wallet_balance`, `get_balance`,
`transfer`, `get_swap_quote`, `swap`, `get_onramp_quote`, `get_onramp_url`,
`get_offramp_quote`, `get_offramp_url`, `check_token_risk`,
`get_transaction_history` and more. The tools are listed even before setup.

When you run the CLI yourself, use the same version as the server:
`npx -y @trustwallet/cli@0.24.1 <command> --json`.

**On Grok Bot, read [On Grok Bot](#on-grok-bot) first**: setup differs there.

## 1. Make sure the server is ready

Call `get_wallet_status`.

- It returns `state` (`unbound`, `local`, `wc-pairing`, `wc-connected`) and
  `twakHome`, the folder the server keeps its files in (wallet, WalletConnect
  session, credentials).
- If a tool returns `code` `CREDENTIALS_MISSING`, the Trust Wallet API
  credentials are not set up. The user gets them at
  https://portal.trustwallet.com/dashboard/apps (an access ID and an HMAC
  secret). Ask the user to run `twak setup` (or `twak init`) in their own
  terminal. If they prefer you to do it, have them set `TWAK_ACCESS_ID` and
  `TWAK_HMAC_SECRET` in your environment without pasting them in chat, then
  run `npx -y @trustwallet/cli@0.24.1 init --json` (expected:
  `{ "configured": true, ... }`). The tools work as soon as the credentials
  are saved, with no restart.

## 2. Choose how transactions are signed

Two modes. Unless the user already chose one, explain both in a sentence each,
then recommend the Trust Wallet app and say why in the same sentence: their
keys never leave their phone and nothing moves without their approval, while
an agent wallet's funds can be moved by the agent alone. Let them choose; do
not pair or create a wallet before they do.

| | Trust Wallet app (WalletConnect) | Agent wallet |
|---|---|---|
| Keys | stay in the user's Trust Wallet app | a separate wallet created for you, encrypted in `twakHome` |
| Each send, swap or approval | approved by the user in the app | signed by you, no approval |
| Chains for transactions | EVM chains only | all supported chains |
| Automations (DCA, limit orders), which run unattended | no | yes |

### Trust Wallet app (WalletConnect)

You never hold keys.

1. If `get_wallet_status` shows `state` `wc-connected`, the app is already
   connected: go to section 3. A connection survives server restarts and
   lasts about 7 days, unless you switch modes (see below).
2. Call `switch_wallet_mode` with `{"mode": "walletconnect"}`.
3. Give the user `pairing.deepLink` as a clickable link (phone users), and
   show the returned QR image (desktop users scan it with their phone). The
   pairing expires after 5 minutes; call `switch_wallet_mode` again for a
   fresh one.
4. Tell the user the app shows the connection as `TWAK`
   (`portal.trustwallet.com`) marked "not verified": this is expected, since
   WalletConnect only verifies browser-based apps.
5. Poll `get_wallet_status` every few seconds until `state` is
   `wc-connected`.

Only the wallet's **EVM** accounts are connected (Ethereum, BNB Chain, Base,
Arbitrum, Polygon, ...). `list_addresses`, `wallet_portfolio` and
`wallet_balance` therefore cover EVM chains only: when you show balances,
say so, since the user's Trust Wallet may also hold Bitcoin, Solana, TRON or
other assets that are not visible here. For those, ask for the address and
use `get_balance`, which works for any address on any chain.

### Agent wallet

You hold the keys of a **new, separate** wallet, which the user funds.

Before creating it, tell the user the following and get their agreement:

- **Never give an agent your main wallet's recovery phrase.** The agent
  wallet is a new, separate wallet, created for the agent: only send it what
  you can afford to lose.
- Anything that can run commands on this computer could use the wallet.
- Backups: by default, keep only small amounts there and, when done, ask you
  to send everything back to their main wallet. If they ask for a backup,
  give them the encrypted `wallet.json` from `twakHome`; restoring it needs
  `twak` and the password. There is no recovery-phrase export.

Then:

1. The wallet password must be in `TWAK_WALLET_PASSWORD`, set by the user in
   your environment and in the server's, never pasted in chat. It must have
   at least 8 characters, with a lowercase letter, an uppercase letter and a
   number; tell the user these rules before they choose it. Ask them to
   write it down: restoring a backup of the wallet needs it.
2. Create the wallet:
   `npx -y @trustwallet/cli@0.24.1 wallet create --no-keychain --json`.
   The output lists `{ address, chain }` per chain.
3. Call `switch_wallet_mode` with `{"mode": "local"}`: a wallet created after
   the server started is used only after this switch. `PASSWORD_MISSING`
   means the server does not have `TWAK_WALLET_PASSWORD`; `WALLET_NOT_FOUND`
   means it looks in another folder than the one you created the wallet in
   (compare `twakHome`).
4. Show the user the address to fund, from `get_address` or
   `list_addresses`.

To switch between modes later, call `switch_wallet_mode` (`local` or
`walletconnect`). Switching **ends the WalletConnect connection**: going back
to the Trust Wallet app always needs a new pairing (QR or deep link). This
is how twak works, not an error: tell the user before switching away from
the app, and present the new pairing as expected.

## 3. Operations

- **Balances**: `wallet_portfolio`, or `get_balance` with an address and
  chain (works for any address, without connecting).
- **Receive**: `get_address` (or `list_addresses`) for the requested chain.
- **Send**: `transfer`. **Swap**: `get_swap_quote` first, show the quote,
  then `swap`. **Buy/sell**: `get_onramp_quote` + `get_onramp_url`,
  `get_offramp_quote` + `get_offramp_url`.
- Chains are named by chain key (`ethereum`, `bsc`, `base`, `solana`, ...);
  every `chain` field in results uses the same keys.
- Swaps start only on EVM chains and Solana (`CHAIN_UNSUPPORTED` otherwise);
  they can end on other chains.

Before every send, swap, approval or off-ramp transfer, state exactly what
will be sent, to whom, on which chain, and get the user's go-ahead. In
WalletConnect mode, also:

- Ask the user to **open the Trust Wallet app** to approve. No push
  notification is shown: the request appears only once the app is open. It
  expires after about 5 minutes.
- `USER_REJECTED` means the user declined it in the app. Do not retry; ask
  them what to do.
- `WC_REQUEST_FAILED` means the wallet returned an error; report its message.
- `WALLET_NOT_BOUND` means the connection ended: reconnect.

## On Grok Bot

Grok Bot runs this server on the Bot's cloud computer. Three things differ.

**1. Keep twak's files in `/workspace`.** It is the folder Grok documents as
durable. Before anything else, ask the user to add a Bot secret named
`TWAK_HOME` with the value `/workspace/.twak`.

**2. Credentials and the wallet password are Bot secrets.** Ask the user to
add them as Bot secrets, never in chat: `TWAK_ACCESS_ID` and
`TWAK_HMAC_SECRET` (from https://portal.trustwallet.com/dashboard/apps), plus
`TWAK_WALLET_PASSWORD` for an agent wallet (at least 8 characters, with a
lowercase letter, an uppercase letter and a number). No `init` is needed. Treat secret
values as readable by anything running on this computer.

**3. Restart the connector after adding or changing a secret.** The server
reads secrets only when it starts. Offer to restart the Trust Wallet
connector, then check before writing anything:

- `get_wallet_status` must report `twakHome` `/workspace/.twak`. If it
  reports another folder, or a tool returns `CREDENTIALS_MISSING`, the
  secrets did not reach the server: check the secret names and restart the
  connector again. Do not pair or create a wallet until this check passes.
- Run every CLI command with the folder set explicitly:
  `TWAK_HOME=/workspace/.twak npx -y @trustwallet/cli@0.24.1 ...`.

Other notes:

- Show the pairing QR on a Page for desktop users; the deep link works from
  Grok on the phone.
- On a team Bot, each person's chat uses the wallet on that person's own
  computer.
