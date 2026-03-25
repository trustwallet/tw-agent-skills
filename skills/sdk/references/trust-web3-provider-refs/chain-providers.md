# Chain-specific Provider Setup

## Table of Contents

- [Ethereum (EIP-1193)](#ethereum-eip-1193)
- [Solana (Wallet Standard)](#solana-wallet-standard)
- [Cosmos (Keplr-compatible)](#cosmos-keplr-compatible)
- [Bitcoin](#bitcoin)
- [Aptos](#aptos)
- [TON](#ton)
- [Tron](#tron)
- [Multi-Chain Setup](#multi-chain-setup)

---

## Ethereum (EIP-1193)

```typescript
import { EthereumProvider } from '@trustwallet/web3-provider-ethereum';

const ethereum = new EthereumProvider({
  chainId: '0x1',          // hex chain ID
  rpcUrl: 'https://...',   // fallback RPC for read calls
  overwriteMetamask: false, // set true to spoof isMetaMask
  isTrust: true,
  disableMobileAdapter: false,
  supportedMethods: [],    // allow-list; empty = all allowed
  unsupportedMethods: [],  // deny-list
});

// Runtime mutations
ethereum.setChainId('0x38');       // switch chain
ethereum.setRPCUrl('https://...');
ethereum.setAddress('0x...');      // update current account
ethereum.setOverwriteMetamask(true);

// Static reads (no handler needed)
ethereum.getChainId();       // '0x1'
ethereum.getAddress();       // '0x...' (set after eth_requestAccounts)
ethereum.getNetworkVersion(); // 1

// Events (EIP-1193)
ethereum.on('connect', ({ chainId }) => {});
ethereum.on('chainChanged', (chainId) => {});
ethereum.on('accountsChanged', (accounts) => {});
ethereum.on('disconnect', (error) => {});
```

## Solana (Wallet Standard)

```typescript
import { SolanaProvider } from '@trustwallet/web3-provider-solana';

const solana = new SolanaProvider({
  cluster: 'https://api.mainnet-beta.solana.com',
  isTrust: true,
  enableAdapter: true,       // register with Wallet Standard
  useLegacySign: false,
  disableMobileAdapter: false,
});

// Methods (called by dApps via Wallet Standard or window.solana)
await solana.connect();
await solana.disconnect();
await solana.signTransaction(tx);
await solana.signAllTransactions([tx1, tx2]);
await solana.signAndSendTransaction(tx, { skipPreflight: false });
await solana.signMessage(uint8ArrayMessage);
await solana.signRawTransactionMulti([tx]);
```

Handler method names for Solana:
- `connect` → `connect`
- `disconnect` → `disconnect`
- `signTransaction` → `signTransaction`
- `signAllTransactions` → `signAllTransactions`
- `signMessage` → `signMessage`
- `signAndSendTransaction` → `signAndSendTransaction`

## Cosmos (Keplr-compatible)

```typescript
import { CosmosProvider } from '@trustwallet/web3-provider-cosmos';

const cosmos = new CosmosProvider({
  isKeplr: true,   // expose as window.keplr
  isTrust: true,
  disableMobileAdapter: false,
});

// Methods available to dApps
await cosmos.enable('cosmoshub-4');
await cosmos.enable(['cosmoshub-4', 'osmosis-1']);
const key = await cosmos.getKey('cosmoshub-4');
await cosmos.signAmino('cosmoshub-4', signer, signDoc);
await cosmos.signDirect('cosmoshub-4', signerAddress, signDoc);
const offlineSigner = cosmos.getOfflineSigner('cosmoshub-4');
const offlineSignerDirect = cosmos.getOfflineSignerDirect('cosmoshub-4');
const offlineSignerAmino = cosmos.getOfflineSignerAmino('cosmoshub-4');
await cosmos.sendTx('cosmoshub-4', txBytes, BroadcastMode.Sync);
await cosmos.signArbitrary('cosmoshub-4', signerAddress, 'hello');
```

## Bitcoin

```typescript
import { BitcoinProvider } from '@trustwallet/web3-provider-bitcoin';

const bitcoin = new BitcoinProvider({ enableAdapter: true });

// Methods
await bitcoin.connect();
await bitcoin.requestAccounts();
await bitcoin.getAccounts();
await bitcoin.signMessage({ message: 'hello', address: '...' });
await bitcoin.signPSBT({ psbt: '...hex...', signInputs: {} });
await bitcoin.pushPSBT({ psbt: '...hex...' });
bitcoin.isConnected();
```

## Aptos

```typescript
import { AptosProvider } from '@trustwallet/web3-provider-aptos';

const aptos = new AptosProvider({ network: 'mainnet', chainId: '1' });

await aptos.connect();
await aptos.disconnect();
const account = await aptos.account();
const network = await aptos.network();
await aptos.signMessage({ message: 'hello', nonce: 'random' });
await aptos.signTransaction(txPayload);
await aptos.signAndSubmitTransaction(txPayload);
```

## TON

```typescript
import { TonProvider } from '@trustwallet/web3-provider-ton';

const ton = new TonProvider({ version: 'v4R2', disableMobileAdapter: false });

await ton.send('ton_requestAccounts', {});
await ton.send('ton_sendTransaction', { to: '...', value: '...' });
await ton.disconnect();
ton.isConnected();
```

## Tron

```typescript
import { TronProvider } from '@trustwallet/web3-provider-tron';

const tron = new TronProvider();
// Wraps TronWeb — exposes window.tronWeb compatible interface
await tron.connect();
await tron.sign(transaction);
await tron.signMessageV2(data);
tron.setNode(nodeUrl);
```

---

## Multi-Chain Setup

```typescript
import { Web3Provider, AdapterStrategy, IHandlerParams } from '@trustwallet/web3-provider-core';
import { EthereumProvider } from '@trustwallet/web3-provider-ethereum';
import { SolanaProvider } from '@trustwallet/web3-provider-solana';
import { CosmosProvider } from '@trustwallet/web3-provider-cosmos';
import { BitcoinProvider } from '@trustwallet/web3-provider-bitcoin';

const web3 = new Web3Provider({
  strategy: AdapterStrategy.PROMISES,
  handler: async (params: IHandlerParams) => {
    switch (params.network) {
      case 'ethereum': return handleEthereum(params);
      case 'solana':   return handleSolana(params);
      case 'cosmos':   return handleCosmos(params);
      case 'bitcoin':  return handleBitcoin(params);
      default: throw new Error(`Unknown network: ${params.network}`);
    }
  },
});

const ethereum = new EthereumProvider({ chainId: '0x1' });
const solana = new SolanaProvider({ enableAdapter: true });
const cosmos = new CosmosProvider({ isKeplr: true });
const bitcoin = new BitcoinProvider({ enableAdapter: true });

web3.registerProviders([ethereum, solana, cosmos, bitcoin]);

// Expose to dApps
window.ethereum = ethereum;
window.solana = solana;
window.keplr = cosmos;
```
