---
name: trust-developer
description: Build on the Trust Wallet developer platform. Use when integrating Trust Wallet deep links, detecting the browser extension, or setting up WalletConnect.
---

Reference for building on the Trust Wallet developer platform: deep links, browser extension detection, and WalletConnect integration.

**Portal**: `developer.trustwallet.com`
**Support**: `developer.trustwallet.com/developer/get-support`

---

## Deep Links

Trust Wallet supports deep links for launching the app directly into specific flows. Useful for mobile dApps and marketing campaigns.

### Open a dApp inside Trust Wallet browser
```
https://link.trustwallet.com/open_url?coin_id=60&url=https%3A%2F%2Fyourdapp.com
```
- `coin_id` — SLIP44 coin ID (60 = Ethereum, 714 = BNB, 501 = Solana)
- `url` — URL-encoded dApp URL

### Send transaction
```
trust://send?asset=c60&address=0xRecipient&amount=0.1&memo=optional
```
- `asset` — asset ID (`c<coinId>` for native, `c<coinId>_t<contractAddress>` for tokens)
- `address` — recipient address
- `amount` — amount in display units

### Buy crypto (on-ramp)
```
https://link.trustwallet.com/buy?asset=c60
```

### WalletConnect deep link (pairing)
```
https://link.trustwallet.com/wc?uri=<url-encoded-wc-uri>
```

---

## Browser Extension Detection

Detect Trust Wallet browser extension in dApps:

```typescript
// Check for Trust Wallet specifically
function isTrustWallet(): boolean {
  const { ethereum } = window as any;
  if (!ethereum) return false;
  if (ethereum.isTrust || ethereum.isTrustWallet) return true;
  // Multi-provider array (EIP-5749)
  if (ethereum.providers?.some((p: any) => p.isTrust || p.isTrustWallet)) return true;
  return false;
}

// Get Trust Wallet provider from multi-provider array
function getTrustProvider() {
  const { ethereum } = window as any;
  if (!ethereum) return null;
  if (ethereum.isTrust) return ethereum;
  return ethereum.providers?.find((p: any) => p.isTrust) ?? null;
}
```

Trust Wallet extension sets:
- `window.ethereum.isTrust = true`
- `window.ethereum.isTrustWallet = true`

For Solana:
```typescript
const isTrustSolana = window.solana?.isTrust === true;
const isTrustSolana2 = window.trustwallet?.solana != null;
```

---

## WalletConnect Integration

Trust Wallet fully supports WalletConnect v2. Recommended for dApps targeting mobile.

```typescript
import { EthereumProvider } from '@walletconnect/ethereum-provider';

const provider = await EthereumProvider.init({
  projectId: 'YOUR_WC_PROJECT_ID',  // https://cloud.walletconnect.com
  chains: [1],                       // Ethereum mainnet
  optionalChains: [56, 137],         // BNB, Polygon
  showQrModal: true,
});

await provider.connect();
const accounts = provider.accounts;

// Trust Wallet will appear in the WalletConnect modal automatically
```

For mobile: use the deep link `https://link.trustwallet.com/wc?uri=<wc-uri>` to open directly in Trust Wallet.

---

## Manifest / dApp Listing

To appear in the Trust Wallet dApp browser, submit your dApp to the official DApp list:
`github.com/trustwallet/dapp-list`

Required `manifest.json` fields:
```json
{
  "name": "Your dApp",
  "iconUrl": "https://yourdapp.com/icon.png",
  "url": "https://yourdapp.com",
  "categories": ["defi", "nft"],
  "chains": ["ethereum", "binance"]
}
```

---

## Common Integration Patterns

### Auto-connect to Trust Wallet on mobile
```typescript
// On mobile, if Trust Wallet is installed, deep-link directly
const isMobile = /iPhone|Android/i.test(navigator.userAgent);
const dappUrl = encodeURIComponent('https://yourdapp.com');

if (isMobile && !window.ethereum) {
  window.location.href =
    `https://link.trustwallet.com/open_url?coin_id=60&url=${dappUrl}`;
}
```

### Request accounts (EIP-1193)
```typescript
const provider = getTrustProvider();
if (!provider) throw new Error('Trust Wallet not found');

const accounts = await provider.request({ method: 'eth_requestAccounts' });
```

### Switch / add chain
```typescript
await provider.request({
  method: 'wallet_switchEthereumChain',
  params: [{ chainId: '0x38' }],  // BNB Chain
});

// If chain not known by wallet:
await provider.request({
  method: 'wallet_addEthereumChain',
  params: [{
    chainId: '0x38',
    chainName: 'BNB Smart Chain',
    rpcUrls: ['https://bsc-dataseed.binance.org'],
    nativeCurrency: { name: 'BNB', symbol: 'BNB', decimals: 18 },
    blockExplorerUrls: ['https://bscscan.com'],
  }],
});
```
