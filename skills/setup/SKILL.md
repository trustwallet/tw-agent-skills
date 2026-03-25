---
name: setup
description: Trust Wallet API authentication — HMAC-SHA256 signing, API keys, base URLs, asset ID format, and the full list of 100+ supported chains. Read this first before using any other skill.
---

# Setup — Authentication & Configuration

## Get API Keys

Register at [portal.trustwallet.com](https://portal.trustwallet.com) to obtain:

- **Access ID** — identifies your application
- **HMAC Secret** — used to sign requests

## Base URLs

| Base URL | Auth | Used By |
|----------|------|---------|
| `https://tws.trustwallet.com` | HMAC-SHA256 | Token prices, security, swap quotes, market listings, assets |

## Rate Limits

The free tier is limited to **1 request per second** across all authenticated endpoints. Exceeding this returns `429 Too Many Requests`. Space sequential API calls at least 1 second apart.

## HMAC-SHA256 Signing

Every request to the `tws.trustwallet.com` base URL must include four headers computed from the request.

### Required Headers

| Header | Value |
|--------|-------|
| `X-TW-CREDENTIAL` | Your Access ID |
| `X-TW-NONCE` | Random UUID (v4), unique per request |
| `X-TW-DATE` | Current UTC date in RFC 2822 format (e.g., `Thu, 27 Feb 2026 12:00:00 GMT`) |
| `Authorization` | `HMAC-SHA256 Signature={base64_signature}` |
| `Content-Type` | `application/json` |

### Signature Algorithm

1. **Build the plaintext** by joining these 6 fields with semicolons (`;`):

```
METHOD;PATH;SORTED_QUERY;ACCESS_ID;NONCE;DATE
```

| Field | Description | Example |
|-------|-------------|---------|
| `METHOD` | HTTP method, uppercase | `GET`, `POST` |
| `PATH` | URL path without host or query string | `/v1/balance` |
| `SORTED_QUERY` | Query parameters sorted alphabetically by key, joined with `&`. Empty string if no query params. Raw values (not URL-encoded). | `address=0xabc&coin=60` |
| `ACCESS_ID` | Your Access ID | `870dfxaa...` |
| `NONCE` | Same UUID from `X-TW-NONCE` header | `a1b2c3d4-e5f6-...` |
| `DATE` | Same date from `X-TW-DATE` header | `Thu, 27 Feb 2026 12:00:00 GMT` |

2. **Compute the HMAC-SHA256** of the plaintext using your HMAC Secret as the key.

3. **Base64-encode** the result.

4. Set the `Authorization` header to `HMAC-SHA256 Signature={base64_result}`.

### Pseudocode

```
nonce    = random_uuid_v4()
date     = utc_date_rfc2822()

// Sort query params alphabetically by key
sorted_query = sort_by_key(query_params).map(k + "=" + v).join("&")

plaintext = METHOD + ";" + path + ";" + sorted_query + ";" + access_id + ";" + nonce + ";" + date

signature = base64(hmac_sha256(hmac_secret, plaintext))

headers = {
  "X-TW-CREDENTIAL": access_id,
  "X-TW-NONCE":      nonce,
  "X-TW-DATE":       date,
  "Authorization":   "HMAC-SHA256 Signature=" + signature,
  "Content-Type":    "application/json"
}
```

### Example (JavaScript / Node.js)

```javascript
import { createHmac, randomUUID } from 'node:crypto';

function signRequest(method, path, query, accessId, hmacSecret) {
  const date = new Date().toUTCString();
  const nonce = randomUUID();

  // Sort query params by key (raw values, not URL-encoded)
  const sortedQuery = query
    ? [...new URLSearchParams(query).entries()]
        .sort((a, b) => a[0].localeCompare(b[0]))
        .map(([k, v]) => `${k}=${v}`)
        .join('&')
    : '';

  const plaintext = [method.toUpperCase(), path, sortedQuery, accessId, nonce, date].join(';');
  const signature = createHmac('sha256', hmacSecret).update(plaintext).digest('base64');

  return {
    'X-TW-CREDENTIAL': accessId,
    'X-TW-NONCE': nonce,
    'X-TW-DATE': date,
    'Authorization': `HMAC-SHA256 Signature=${signature}`,
    'Content-Type': 'application/json',
  };
}
```

### Example (Python)

```python
import hmac, hashlib, base64, uuid
from datetime import datetime, timezone
from urllib.parse import parse_qs

def sign_request(method, path, query, access_id, hmac_secret):
    date = datetime.now(timezone.utc).strftime('%a, %d %b %Y %H:%M:%S GMT')
    nonce = str(uuid.uuid4())

    # Sort query params by key
    if query:
        params = parse_qs(query, keep_blank_values=True)
        sorted_query = '&'.join(
            f'{k}={v[0]}' for k, v in sorted(params.items())
        )
    else:
        sorted_query = ''

    plaintext = ';'.join([method.upper(), path, sorted_query, access_id, nonce, date])
    signature = base64.b64encode(
        hmac.new(hmac_secret.encode(), plaintext.encode(), hashlib.sha256).digest()
    ).decode()

    return {
        'X-TW-CREDENTIAL': access_id,
        'X-TW-NONCE': nonce,
        'X-TW-DATE': date,
        'Authorization': f'HMAC-SHA256 Signature={signature}',
        'Content-Type': 'application/json',
    }
```

## Asset ID Format

Trust Wallet uses a compact asset ID across all APIs:

- **Native coin**: `c{coinId}` — e.g., `c60` (ETH), `c714` (BNB), `c501` (SOL)
- **Token**: `c{coinId}_t{contractAddress}` — e.g., `c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` (USDC on Ethereum)

The `coinId` follows the [SLIP-44](https://github.com/satoshilabs/slips/blob/master/slip-0044.md) standard.

## Supported Chains

Trust Wallet supports 100+ chains. Below is the list grouped by type. Chains marked with `—` for Coin ID are supported but do not have a SLIP-44 coin ID assigned in this reference; use the chain ID or domain ID for those chains instead.

### EVM Chains

| Chain | Coin ID | Symbol | Chain ID |
|-------|---------|--------|----------|
| Ethereum | 60 | ETH | 1 |
| BNB Smart Chain (BSC) | 714 | BNB | 56 |
| Polygon | 966 | MATIC | 137 |
| Avalanche C-Chain | 10009000 | AVAX | 43114 |
| Arbitrum | 10042221 | ETH | 42161 |
| Optimism | 10000070 | ETH | 10 |
| Base | 10008453 | ETH | 8453 |
| Fantom | 10000250 | FTM | 250 |
| Sonic | — | S | — |
| Linea | — | ETH | 59144 |
| zkSync Era | — | ETH | 324 |
| Scroll | — | ETH | 534352 |
| Blast | — | ETH | 81457 |
| Manta Pacific | — | ETH | 169 |
| Mantle | — | MNT | 5000 |
| Polygon zkEVM | — | ETH | 1101 |
| Cronos | — | CRO | 25 |
| Gnosis (xDai) | — | xDAI | 100 |
| Celo | — | CELO | 42220 |
| Aurora | — | ETH | 1313161554 |
| Moonbeam | — | GLMR | 1284 |
| Moonriver | — | MOVR | 1285 |
| Boba | — | ETH | 288 |
| Metis | — | METIS | 1088 |
| KuCoin Community Chain | — | KCS | 321 |
| Klaytn (Kaia) | — | KLAY | 8217 |
| IoTeX (EVM) | — | IOTX | 4689 |
| Ronin | — | RON | 2020 |
| Viction | — | VIC | 88 |
| Neon | — | NEON | 245022934 |
| opBNB | — | BNB | 204 |
| Merlin | — | BTC | 4200 |
| Acala (EVM) | — | ACA | 787 |
| Conflux eSpace | — | CFX | 1030 |
| Kava (EVM) | — | KAVA | 2222 |
| ZetaChain (EVM) | — | ZETA | 7000 |
| BounceBit | — | BB | — |
| zkLink Nova | — | ETH | — |
| Ethereum Classic | — | ETC | 61 |
| ThunderCore | — | TT | 108 |
| Wanchain | — | WAN | 888 |
| GoChain | — | GO | 60 |
| Callisto | — | CLO | 820 |
| Harmony | — | ONE | — |
| Evmos (EVM) | — | EVMOS | 9001 |
| Monad | — | MON | — |
| MegaETH | — | ETH | — |
| Plasma | — | — | — |

### Solana

| Chain | Coin ID | Symbol |
|-------|---------|--------|
| Solana | 501 | SOL |

### Bitcoin & UTXO Chains

| Chain | Coin ID | Symbol |
|-------|---------|--------|
| Bitcoin | 0 | BTC |
| Litecoin | 2 | LTC |
| Dogecoin | 3 | DOGE |
| Bitcoin Cash | 145 | BCH |
| Zcash | 133 | ZEC |
| Dash | 5 | DASH |
| Ravencoin | 175 | RVN |
| DigiByte | 20 | DGB |
| Decred | 42 | DCR |
| Qtum | 2301 | QTUM |
| Groestlcoin | 17 | GRS |
| Viacoin | 14 | VIA |
| Firo | 136 | FIRO |
| Flux (Zelcash) | 19167 | FLUX |

### Cosmos Ecosystem

| Chain | Coin ID | Symbol |
|-------|---------|--------|
| Cosmos Hub | 118 | ATOM |
| Osmosis | 10000118 | OSMO |
| THORChain | 931 | RUNE |
| Kava | 459 | KAVA |
| Terra | 330 | LUNA |
| Injective | — | INJ |
| Sei | — | SEI |
| Stride | — | STRD |
| Axelar | — | AXL |
| Neutron | — | NTRN |
| Akash | — | AKT |
| Agoric | — | BLD |
| Juno | — | JUNO |
| Stargaze | — | STARS |
| Crypto.org | — | CRO |
| Evmos (Cosmos) | — | EVMOS |
| Greenfield | — | BNB |
| ZetaChain (Cosmos) | — | ZETA |

### Other L1 Chains

| Chain | Coin ID | Symbol |
|-------|---------|--------|
| Tron | 195 | TRX |
| Aptos | 637 | APT |
| TON | 607 | TON |
| Sui | 784 | SUI |
| NEAR | 397 | NEAR |
| Polkadot | 354 | DOT |
| Kusama | 434 | KSM |
| Cardano | 1815 | ADA |
| XRP Ledger | 144 | XRP |
| Stellar | 148 | XLM |
| Algorand | 283 | ALGO |
| Tezos | 1729 | XTZ |
| Internet Computer | 223 | ICP |
| MultiversX | 508 | EGLD |
| VeChain | 818 | VET |
| Filecoin | 461 | FIL |
| Zilliqa | 313 | ZIL |
| ICON | 74 | ICX |
| Waves | 5741564 | WAVES |
| Nano | 165 | XNO |
| Ontology | 1024 | ONT |
| Theta | 500 | THETA |
| Nebulas | 2718 | NAS |
| Aion | 425 | AION |
| Aeternity | 457 | AE |
| IoTeX | 304 | IOTX |
| FIO | 235 | FIO |
| Nimiq | 242 | NIM |

## Chain Key vs Chain ID

When using domain-based endpoints (e.g., swap), use the **chain key** (the identifier used in API routing), not the internal chain ID. For most chains they are the same, but notably:

| Chain Key (use this) | Internal Chain ID |
|----------------------|-------------------|
| `bsc` | `smartchain` |
| `ethereum` | `ethereum` |
| `polygon` | `polygon` |
| `solana` | `solana` |
