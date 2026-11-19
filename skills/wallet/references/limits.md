# Limits and settings

twak refuses some transactions to protect the user from mistakes: a wrong amount, token or decimals, or an unreasonable slippage tolerance. The limits are the user's settings. An agent never changes them on its own.

## USD limit per transaction

Every transfer, swap, off-ramp payout (`onramp sell-confirm`) and x402 payment is refused above a USD limit per transaction, **$10,000 by default**. The value is computed on the exact amount that will be signed.

| Outcome | `errorCode` | What to do |
|---------|-------------|------------|
| Worth more than the limit | `USD_LIMIT_EXCEEDED` | Tell the user the value and the limit. Only they can raise it (below). |
| twak has no data to value it: no USD price for the token, a token twak does not know, or decimals supplied with `--decimals` | `USD_VALUE_UNVERIFIED` | Tell the user why. They can allow such transactions with `allow-unverified-value` (below). Testnet tokens have no price, so testnet transfers and payments of tokens land here too. |
| A price or token lookup failed (network, outage) | `NETWORK_ERROR` | Retry later. This is never a reason to change a setting: allowing unverified values does not let it through. |

Transfers worth more than $1,000 print a high-value warning on stderr.

## Maximum slippage

A swap accepts any output down to `quote × (1 − slippage)`, so the slippage tolerance bounds what one swap can lose (sandwich bots take most of that margin). The default tolerance is 1%. A swap above the **maximum, 10% by default**, is refused with `SLIPPAGE_EXCEEDED`; the message gives the command to raise it. Volatile or fee-on-transfer tokens may need more, which only the user decides.

- The maximum can be raised to at most 50%. Above 50% is always refused.
- Quotes (`twak swap … --quote-only --slippage <pct>`, MCP `get_swap_quote` with `slippage`) sign nothing and are not limited by the maximum, only by the 50% limit. Their `minReceived` shows what that slippage allows; MCP `get_swap_quote` adds a `warning` when a swap at that slippage would be refused.
- Above 5%, a swap carries a high-slippage warning.

## Signing policy (`twak serve --allow-local-signing`)

`twak serve` does not sign with the local agent wallet unless it is started with `--allow-local-signing`; without it, signing tools return `LOCAL_SIGNING_DISABLED` (REST: 403). With it, the server decides each local signature against the user's policy, in the server process, not in the agent:

| What | Outcome |
|------|---------|
| Swap or x402 payment worth up to `auto-approve-max-usd` ($10 by default), while the rolling 24-hour total of such actions stays within `auto-approve-window-usd` ($50) | Runs without asking |
| Transfer to an `allowed-destination`, or finite approval to an `allowed-spender`, within the same limits | Runs without asking |
| Revoking an approval (amount 0) | Runs |
| Anything larger, anything twak cannot value in USD, any contract call or signature outside a swap or payment | Asks the user in a confirmation prompt |
| Unlimited approval (2^128 or more) | `SIGNING_DENIED`, unless `allow-unlimited-approvals` is set (then each one asks) |
| Total above `window-max-usd` in 24 hours ($10,000) | `SPEND_WINDOW_EXCEEDED` |

When the host cannot show a confirmation prompt (an MCP client without elicitation, REST, the watcher), what needs one returns `CONFIRMATION_REQUIRED`; a declined prompt returns `USER_REJECTED`. Automations run only after the user approves them (`twak automate approve <id>`).

```bash
twak config set auto-approve-max-usd 25               # per action, in USD (0 = ask every time)
twak config set auto-approve-window-usd 100           # rolling 24 hours, in USD
twak config set window-max-usd 5000                   # hard 24-hour cap
twak config set allow-unlimited-approvals true        # default false; each one still asks
twak config add allowed-destination 0x…               # transfers to this address can run unattended
twak config add allowed-spender 0x…                   # finite approvals to this spender can run unattended
twak config remove allowed-destination 0x…
```

These settings live in `settings.json` and change only through `twak config`; no MCP or REST tool reads or writes them.

## Settings: `twak config`

```bash
twak config get --json                            # values in effect, with where each comes from
twak config set max-usd 50000                     # USD limit per transaction
twak config set allow-unverified-value true       # allow values twak cannot check (default false)
twak config set max-slippage 20                   # maximum slippage, in percent (above 0, at most 50)
twak config unset max-usd                         # back to the default
```

- Saved in `settings.json` in the twak folder (`TWAK_HOME`, default `~/.twak`). A running `twak serve` (MCP server) applies a change to its next transaction, without a restart.
- `twak config get --json` returns `{ "max-usd": { value, source }, "allow-unverified-value": { value, source }, "max-slippage": { value, source }, file }`, where `source` is `option`, `env`, `settings` or `default`.
- Environment variables override the saved values: `TWAK_MAX_USD` and `TWAK_MAX_SLIPPAGE`. For one CLI command, `--max-usd <n>` overrides the USD limit, and `--skip-safety-check` skips the USD check (`transfer`, `swap`, `onramp sell-confirm`, `x402 request`). `twak serve --max-usd <n>` sets the USD limit for that server.
- No MCP tool reads or changes these settings.
- An invalid saved value, or a settings file other users can write, makes twak refuse transactions (`VALIDATION_ERROR` / `STORAGE_ERROR`) rather than fall back to the defaults.

## Rules for an agent

- **Never change a setting, add an allowlist entry, set `TWAK_MAX_USD` / `TWAK_MAX_SLIPPAGE`, pass `--max-usd` / `--skip-safety-check`, or restart the server with `--allow-local-signing` on your own initiative**, including to get a refused transaction through. When something is refused, tell the user what and why, and that they can change the setting if they want to.
- Change a setting only when the user explicitly asks for it. Then repeat the new value back to them (from `twak config get --json`), and mention it applies to every later transaction until changed.
- Prefer the narrowest change: a higher `max-usd` rather than `allow-unverified-value`, and `twak config unset` to go back to the default when the user is done.
