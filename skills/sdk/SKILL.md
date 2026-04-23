---
name: trust-wallet-sdk
description: Trust Wallet open-source libraries — Wallet Core (HD wallets, address derivation, tx signing in Swift/Kotlin/TypeScript/Go for 140+ chains), Web3 Provider (dApp connection for Ethereum/Solana/Cosmos/Bitcoin/Aptos/TON/Tron), deep linking, browser extension integration, WalletConnect, token assets repository, and Barz ERC-4337 smart wallet. Use when working with trustwallet/wallet-core, @trustwallet/wallet-core, trust-web3-provider, Trust Wallet deep links, token logos/metadata from trustwallet/assets, or Barz account abstraction.
---

# Trust Wallet SDK & Libraries

Open-source libraries for wallet integration, dApp connectivity, and smart wallets.

## Quick Start — Wallet Core (TypeScript)

```ts
import { HDWallet, CoinType, AnyAddress } from '@trustwallet/wallet-core';

const wallet = HDWallet.createWithMnemonic('your twelve word mnemonic ...');
const key    = wallet.getKeyForCoin(CoinType.ethereum);
const addr   = AnyAddress.createWithPublicKey(key.getPublicKeySecp256k1(false), CoinType.ethereum);
console.log(addr.description());
```

Core flow: **mnemonic → HDWallet → PrivateKey → Address → sign transaction bytes**. Wallet Core handles keys and signing only — it does not connect to nodes or broadcast transactions.

## Reference Guide

Read the reference that matches the user's task:

| Task | Reference | When to read |
|------|-----------|--------------|
| HD wallet, address derivation, tx signing | `references/wallet-core.md` | "wallet core", "derive address", "sign transaction", "key generation" |
| Web3 provider, dApp connection | `references/trust-web3-provider.md` | "web3 provider", "dApp integration", "provider API" |
| Deep links, extension, WalletConnect | `references/trust-developer.md` | "deep link", "browser extension", "WalletConnect" |
| Token logos, metadata, CDN | `references/assets.md` | "token logo", "add asset", "trustwallet/assets" |
| ERC-4337 smart wallet | `references/barz.md` | "smart wallet", "account abstraction", "ERC-4337", "Barz" |
