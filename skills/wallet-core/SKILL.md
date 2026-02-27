---
name: wallet-core
description: Build with Trust Wallet Core — HD wallet creation, address derivation, and transaction signing across 140+ blockchains. Use when working with trustwallet/wallet-core, @trustwallet/wallet-core, or implementing key generation and signing in Swift, Kotlin, TypeScript, or Go.
---

Cross-platform, cross-blockchain wallet library. Handles key generation, address derivation, and transaction signing for 140+ blockchains. Does **not** handle networking or broadcasting.

**Repo**: `github.com/trustwallet/wallet-core`
**NPM**: `@trustwallet/wallet-core`
**Docs**: `developer.trustwallet.com/developer/wallet-core`

> **Development convention**: New blockchain implementations and core logic should be written in **Rust** where possible. The C++ layer is primarily a routing/integration layer. Rust code lives in `rust/` and is the preferred location for new address derivation, signing, and cryptographic logic.

---

## Architecture

```
Language Bindings (Swift / Kotlin / JS-WASM / Go / Rust)
        ↓
C Interface Layer (TrustWalletCore/TW*.h)
        ↓
C++ routing + Rust core logic
        ↓
Crypto libs + Signing logic + Address derivation
```

Core workflow: **mnemonic → HDWallet → PrivateKey → Address → sign transaction bytes**

Wallet Core does not connect to nodes, check balances, or broadcast transactions.

---

## Installation

### Swift (iOS)
```ruby
# CocoaPods
pod 'TrustWalletCore'
```
Or Swift Package Manager — add `github.com/trustwallet/wallet-core` as a package dependency.

### Kotlin (Android)
```kotlin
// build.gradle — requires GitHub Packages token
repositories {
    maven {
        url = uri("https://maven.pkg.github.com/trustwallet/wallet-core")
        credentials { username = "..."; password = githubToken }
    }
}
dependencies {
    implementation("com.trustwallet:wallet-core:<version>")
}
```
```kotlin
// Required at app startup
System.loadLibrary("TrustWalletCore")
```

### JavaScript / TypeScript (WASM)
```bash
npm install @trustwallet/wallet-core
```
```typescript
import WalletCore from '@trustwallet/wallet-core';
const { HDWallet, CoinType, AnyAddress, AnySigner } = await WalletCore.load();
```

### Go (server-side, cgo)
```go
import "github.com/trustwallet/wallet-core/wasm/go/walletcore"
```

---

## Core API

### HDWallet — key generation

```swift
// Swift
let wallet = HDWallet(strength: 128, passphrase: "")!    // new wallet
let wallet = HDWallet(mnemonic: phrase, passphrase: "")!  // restore

let mnemonic = wallet.mnemonic
let addressETH = wallet.getAddressForCoin(coin: .ethereum)
let addressBTC = wallet.getAddressForCoin(coin: .bitcoin)
let addressSOL = wallet.getAddressForCoin(coin: .solana)
```

```kotlin
// Kotlin
val wallet = HDWallet(128, "")                        // new
val wallet = HDWallet(mnemonic, "")                   // restore

val ethAddress = wallet.getAddressForCoin(CoinType.ETHEREUM)
val btcAddress = wallet.getAddressForCoin(CoinType.BITCOIN)
```

```typescript
// TypeScript
const wallet = HDWallet.create(128, '');              // new
const wallet = HDWallet.createWithMnemonic(mnemonic, ''); // restore

const ethAddress = wallet.getAddressForCoin(CoinType.ethereum);
```

### Custom derivation paths

```swift
// m/44'/60'/0'/0/0
let key = wallet.getKey(coin: .ethereum, derivationPath: "m/44'/60'/0'/0/0")
let address = CoinType.ethereum.deriveAddress(privateKey: key)
```

```kotlin
val key = wallet.getKey(CoinType.ETHEREUM, "m/44'/60'/0'/0/0")
val address = CoinType.ETHEREUM.deriveAddress(key)
```

### Address validation

```swift
let isValid = AnyAddress.isValid(string: "0x...", coin: .ethereum)  // → Bool
let address = AnyAddress(string: "0x...", coin: .ethereum)!
```

```kotlin
val isValid = AnyAddress.isValid("0x...", CoinType.ETHEREUM)
```

---

## Transaction Signing

### Ethereum

```swift
// Swift
let input = EthereumSigningInput.with {
    $0.chainID = Data(hexString: "01")!         // mainnet = 1
    $0.nonce = Data(hexString: "00")!
    $0.gasPrice = Data(hexString: "d693a400")!  // 3.6 Gwei
    $0.gasLimit = Data(hexString: "5208")!      // 21000
    $0.toAddress = "0xRecipient..."
    $0.transaction = .with {
        $0.transfer = .with { $0.amount = Data(hexString: "0de0b6b3a7640000")! } // 1 ETH
    }
    $0.privateKey = key.data
}
let output = AnySigner.sign(input: input, coin: .ethereum)
let txHex = output.encoded.hexString  // broadcast this
```

```kotlin
// Kotlin
val input = Ethereum.SigningInput.newBuilder().apply {
    chainId = ByteString.copyFrom(BigInteger("1").toByteArray())
    nonce = ByteString.copyFrom(BigInteger("0").toByteArray())
    gasPrice = ByteString.copyFrom(BigInteger("3600000000").toByteArray())
    gasLimit = ByteString.copyFrom(BigInteger("21000").toByteArray())
    toAddress = "0xRecipient..."
    privateKey = ByteString.copyFrom(key.data())
    transaction = Ethereum.Transaction.newBuilder().apply {
        transfer = Ethereum.Transaction.Transfer.newBuilder().apply {
            amount = ByteString.copyFrom(BigInteger("1000000000000000000").toByteArray())
        }.build()
    }.build()
}.build()
val output = AnySigner.sign(input, CoinType.ETHEREUM, Ethereum.SigningOutput.parser())
```

### Bitcoin

```swift
let input = BitcoinSigningInput.with {
    $0.hashType = BitcoinSigHashType.all.rawValue
    $0.amount = 546
    $0.toAddress = "1MityqAKBEKHPkBpwDCqPMBNbYPxbNbKzr"
    $0.changeAddress = "1HtEMqpQAFbMATFEEDVFAfGNGBzQS9vqkq"
    $0.utxo = [utxo]
    $0.scripts = [redeemScriptHash: redeemScript.data]
}
let output = AnySigner.sign(input: input, coin: .bitcoin)
```

### Cosmos / ATOM

```swift
let input = CosmosSigningInput.with {
    $0.signingMode = .protobuf
    $0.accountNumber = 1037
    $0.chainID = "cosmoshub-4"
    $0.memo = ""
    $0.sequence = 7
    $0.messages = [CosmosMessage.with {
        $0.sendCoinsMessage = .with {
            $0.fromAddress = "cosmos1..."
            $0.toAddress = "cosmos1..."
            $0.amounts = [CosmosAmount.with { $0.amount = "75000"; $0.denom = "uatom" }]
        }
    }]
    $0.fee = CosmosFee.with { $0.gas = 200000; $0.amounts = [...] }
    $0.privateKey = key.data
}
```

---

## Adding a New Blockchain

Requirements before submitting:
- Mainnet live and stable 3–6 months
- Top 100 CoinMarketCap native coin
- Public RPC/API accessible with load balancing
- Extensive developer documentation

Implementation steps:
```bash
# 1. Add coin entry to registry.json (SLIP44 coin ID, symbol, derivation)
# 2. Generate skeleton files
./tools/generate-files

# 3. Implement in Rust (primary logic)
# packages/core/src/<chain>/
#   address.rs   — parse, validate, encode, derive from public key
#   signer.rs    — build and sign transactions

# 4. Add C++ integration layer (generated from .proto definitions)
# 5. Add tests: Rust unit tests + C++ integration tests
cargo test -p wallet-core

# 6. Validate on Android + iOS
```

The `CoinEntry` Rust trait is the main interface:
```rust
pub trait CoinEntry {
    fn derive_address(&self, public_key: &PublicKey) -> String;
    fn sign(&self, input: &Data) -> Data;
    fn validate_address(&self, address: &str) -> bool;
}
```

---

## Build & Test

```bash
# Full setup (macOS primary, Linux for C++/Wasm only)
./bootstrap.sh all          # install all deps
./bootstrap.sh android ios  # specific platforms

# Generate protobuf + code
./tools/generate-files

# Native build + test
cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Debug
make -Cbuild -j12 tests TrezorCryptoTests
./build/tests/tests tests

# Rust only
cd rust && cargo test
./tools/rust-lints

# WASM
./bootstrap.sh wasm
source emsdk/emsdk_env.sh
tools/wasm-build
cd wasm && npm install && npm run copy:wasm && npm run build && npm run test

# Docker (easiest)
docker build docker/wallet-core --tag wallet-core-dev
docker run -it wallet-core-dev /bin/bash
./tools/build-and-test
```

CMake flags:
- `TW_UNITY_BUILD=ON` — faster builds
- `TW_CODE_COVERAGE=ON` — coverage
- `TW_CLANG_ASAN=ON` — memory debugging
- `TW_WARNINGS_AS_ERRORS=ON` — strict mode

---

## Key CoinType values

| Chain     | CoinType           | SLIP44 |
|-----------|--------------------|--------|
| Bitcoin   | `.bitcoin`         | 0      |
| Ethereum  | `.ethereum`        | 60     |
| BNB Chain | `.smartChain`      | 20000714 |
| Solana    | `.solana`          | 501    |
| Cosmos    | `.cosmos`          | 118    |
| Aptos     | `.aptos`           | 637    |
| TON       | `.ton`             | 607    |
| Tron      | `.tron`            | 195    |
| Polygon   | `.polygon`         | 966    |

Full list: `src/registry.json` in the wallet-core repo.
