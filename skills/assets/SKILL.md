---
name: assets
description: Work with the Trust Wallet assets repository — look up token logos and metadata, list assets by blockchain, and contribute new assets (add logo, info.json, update tokenlist). Use when the user asks about token logos, asset listings, adding a token to Trust Wallet, or querying trustwallet/assets.
---

# Trust Wallet Assets

Comprehensive collection of token logos and metadata for thousands of crypto tokens across 180+ blockchains. Used by Trust Wallet, and many other projects, as the canonical source for token info and logos.

**Repo**: `github.com/trustwallet/assets`
**Web app**: `assets.trustwallet.com`
**Docs**: `developer.trustwallet.com/listing-new-assets`

---

## Repository Structure

```
blockchains/
└── <chain>/                    e.g. ethereum, binance, solana, polygon
    ├── assets/
    │   └── <address>/          checksum address for EVM; native ID for others
    │       ├── logo.png        token logo (required)
    │       └── info.json       token metadata (optional but recommended)
    ├── tokenlist.json          trading pairs / curated list
    └── tokenlist-extended.json extended token list
```

Chain directory names use lowercase slugs: `ethereum`, `smartchain` (BNB), `polygon`, `solana`, `cosmos`, `arbitrum`, `optimism`, `base`, `avalanchec`, `tron`, `ton`, etc.

---

## Listing Assets by Chain

```bash
# List all assets for a chain (GitHub API)
gh api repos/trustwallet/assets/contents/blockchains/ethereum/assets --jq '.[].name'

# Check if a specific token exists
gh api repos/trustwallet/assets/contents/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7 --jq '.[].name'

# Read token metadata
gh api repos/trustwallet/assets/contents/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7/info.json \
  --jq '.content' | base64 -d
```

```bash
# List all supported chains
gh api repos/trustwallet/assets/contents/blockchains --jq '.[].name'
```

---

## info.json Format

```json
{
    "name": "Tether",
    "website": "https://tether.to",
    "description": "Short description of the token.",
    "explorer": "https://etherscan.io/token/0xdAC17F958D2ee523a2206206994597C13D831ec7",
    "type": "ERC20",
    "symbol": "USDT",
    "decimals": 6,
    "status": "active",
    "id": "0xdAC17F958D2ee523a2206206994597C13D831ec7",
    "tags": ["stablecoin"],
    "links": [
        { "name": "x", "url": "https://x.com/Tether_to/" },
        { "name": "coinmarketcap", "url": "https://coinmarketcap.com/currencies/tether/" },
        { "name": "coingecko", "url": "https://coingecko.com/en/coins/tether" },
        { "name": "facebook", "url": "https://facebook.com/tether.to/" },
        { "name": "github", "url": "https://github.com/tetherto" },
        { "name": "discord", "url": "https://discord.gg/..." },
        { "name": "telegram", "url": "https://t.me/..." }
    ]
}
```

**`type` values**: `ERC20`, `BEP20`, `BEP2`, `SPL`, `TRC20`, `CW20`, `POLYGON`, `ARBITRUM`, `OPTIMISM`, `BASE`, `AVAXC`, `TON_JET`

**`status` values**: `active`, `abandoned`, `spam`

**`tags` values**: `stablecoin`, `wrapped`, `defi`, `nft`, `governance`, `meme`, `bridge`

---

## Contributing a New Asset

### Requirements (read before starting)
- Token must **not** be brand new — project needs sound fundamentals and non-minimal circulation
- Full requirements: `developer.trustwallet.com/listing-new-assets/requirements`
- No spam tokens — mass-airdropped tokens are rejected

### Option 1 — Web app (easiest)
Use `assets.trustwallet.com` (GitHub account required). Handles validation automatically.

### Option 2 — Manual PR

**Step 1**: Create the asset template
```bash
make add-token asset_id=c60_t0x<ContractAddress>
# Creates blockchains/ethereum/assets/0x<Address>/info.json
```

**Step 2**: Add your files
```
blockchains/<chain>/assets/<address>/
├── logo.png    ← required: 256×256px PNG, transparent background, <100KB
└── info.json   ← fill in all fields
```

**Logo requirements**:
- Format: PNG with transparency
- Size: exactly 256×256 pixels
- File size: under 100KB
- High contrast, recognizable at small sizes

**Step 3**: Add to tokenlist (optional, for trading pair visibility)
```bash
make add-tokenlist asset_id=c60_t0x<ContractAddress>
make add-tokenlist-extended asset_id=c60_t0x<ContractAddress>
```

**Step 4**: Validate
```bash
make check   # full validation — also runs in CI
make fix     # auto-fix common issues (image resizing, JSON formatting)
```

**Step 5**: Open a PR against `master` branch

### Common Validation Errors

| Error | Fix |
|-------|-----|
| Logo wrong size | Resize to exactly 256×256px |
| Logo too large | Compress PNG, must be <100KB |
| Address not checksummed | Use EIP-55 checksum for EVM addresses |
| Missing required fields | Fill `name`, `symbol`, `decimals`, `type`, `status`, `id` in info.json |
| Token not found on-chain | Verify contract address on explorer |

---

## Scripts Reference

```bash
make check                           # Validate entire repo (runs in CI)
make fix                             # Auto-fix issues
make update-auto                     # Sync from external sources (DEX pools, etc.)
make add-token asset_id=<id>         # Scaffold info.json for a token
make add-tokenlist asset_id=<id>     # Add to tokenlist.json
make add-tokenlist-extended asset_id=<id>  # Add to tokenlist-extended.json
```
