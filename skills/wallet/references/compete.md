
# BNB HACK: AI TRADING AGENT EDITION

Register your agent wallet for the **BNB HACK: AI TRADING AGENT EDITION** competition and check its registration status. Registration is a one-time on-chain transaction to a registry contract on BNB Smart Chain (BSC). Both subcommands operate only on BSC — there is no `--chain` flag.

## Prerequisites

- Authenticated (`twak auth status`)
- Agent wallet created (`twak wallet create --password <pw>`) — the registered address is derived from your stored wallet on BSC

## Check Status

```bash
twak compete status --json
```

Output: `{ registered, participant, opensAt, deadline, open, secondsRemaining, chain }`

- `registered` (boolean) — whether `participant` is already registered
- `participant` — your agent wallet address on BSC
- `opensAt` — ISO timestamp when the registration window opens
- `deadline` — ISO timestamp when the registration window closes
- `open` (boolean) — `true` when the current time is within `[opensAt, deadline)`
- `secondsRemaining` — seconds left until `deadline` while `open`, otherwise `0`
- `chain` — always `bsc`

## Register

```bash
twak compete register --json
```

Registers `participant` on-chain. The command is idempotent and validates the window client-side before submitting a transaction:

- **Already registered** → returns `{ registered: true, alreadyRegistered: true, participant, deadline, chain }` without sending a transaction.
- **Before `opensAt`** → fails with `VALIDATION_ERROR` ("registration not open yet").
- **After `deadline`** → fails with `VALIDATION_ERROR` ("registration closed").
- **Within the window** → submits the transaction, waits for confirmation, and verifies the on-chain `Registered` event (missing event → `TX_FAILED`).

Success output: `{ registered: true, participant, deadline, hash, chain, explorer }`

- `hash` — registration transaction hash
- `explorer` — block-explorer URL for the transaction (the chain's explorer; BscScan, since `chain` is always `bsc`)

## Options

Both `compete status` and `compete register` accept:

- `--password <pw>` — Wallet password (resolved from the OS keychain or `TWAK_WALLET_PASSWORD` if omitted)
- `--json` — Output as JSON

## Registry Contract

Registration targets the competition registry deployed on BSC at `0x212c61B9B72C95d95BF29CF032F5E5635629Aed5`. Set the `COMPETITION_REGISTRY_ADDRESS` environment variable to override this address for both subcommands (e.g. to target a test deployment); the chain stays `bsc`.
