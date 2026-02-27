---
name: barz
description: Build with, use, and contribute to Barz — Trust Wallet's modular ERC-4337 smart contract wallet. Use when working with trustwallet/barz, implementing account abstraction, adding wallet facets, writing tests for smart contract wallets, or integrating Barz into a dApp.
---

# Barz — Modular Smart Contract Wallet

A secure, modular, upgradeable ERC-4337 smart contract wallet built on the [EIP-2535 Diamond, Multi-Facet Proxy](https://eips.ethereum.org/EIPS/eip-2535) standard. Each feature is an independent facet that can be attached or detached by the wallet owner.

**Repo**: `github.com/trustwallet/barz`

---

## Architecture

Barz uses the Diamond proxy pattern — a single `Barz.sol` proxy that delegates calls to modular facets:

```
Barz (Diamond Proxy)
├── AccountFacet              — execution, ERC-4337 validateUserOp
├── Secp256k1VerificationFacet — ECDSA (standard EOA-style signing)
├── Secp256r1VerificationFacet — P256 / Passkey (WebAuthn)
├── MultiSigFacet             — multi-signature support
├── DiamondCutFacet           — add/replace/remove facets
├── DiamondLoupeFacet         — introspection
├── SignatureMigrationFacet   — switch signature scheme without migration
├── GuardianFacet             — social recovery guardians
├── AccountRecoveryFacet      — guardian-based account recovery
├── LockFacet                 — lock/unlock account
├── RestrictionsFacet         — transaction restrictions
└── TokenReceiverFacet        — ERC-721/1155 receiver hooks
```

**Storage isolation**: Each facet has its own `FacetStorage` struct — no shared storage slots, no collision risk across upgrades.

**Modular upgradeability**: Replace individual facets without touching the rest of the wallet. Only the relevant module changes.

---

## Signature Schemes

Barz supports swappable signature verification:

| Facet | Scheme | Use case |
|-------|--------|----------|
| `Secp256k1VerificationFacet` | ECDSA (K1) | Hardware wallets, conventional EOA |
| `Secp256r1VerificationFacet` | P256 (Passkey) | WebAuthn, iCloud Keychain, biometrics |
| `MultiSigFacet` | Multi-sig | Team wallets, high-value accounts |

Switching signature schemes:
1. Validate signature of owner + guardians
2. Verify new facet is registered in `FacetRegistry`
3. Zero out old signature storage
4. Initialize new signature storage with new signer

---

## Project Setup

```bash
yarn              # install dependencies (Hardhat + Foundry)
yarn compile      # compile all contracts
yarn test         # run Hardhat tests
yarn size         # check contract sizes against EIP-170 limit
forge test        # run Foundry tests (faster, fuzz-friendly)
```

---

## Contract Layout

```
contracts/
├── Barz.sol                        # main Diamond proxy
├── BarzFactory.sol                 # counterfactual deployment factory
├── facets/
│   ├── AccountFacet.sol
│   ├── AccountRecoveryFacet.sol
│   ├── GuardianFacet.sol
│   ├── LockFacet.sol
│   ├── RestrictionsFacet.sol
│   ├── SignatureMigrationFacet.sol
│   ├── TokenReceiverFacet.sol
│   ├── base/
│   │   ├── DiamondCutFacet.sol
│   │   └── DiamondLoupeFacet.sol
│   └── verification/
│       ├── MultiSigFacet.sol
│       ├── secp256k1/
│       │   └── Secp256k1VerificationFacet.sol
│       └── secp256r1/
│           └── Secp256r1VerificationFacet.sol
├── aa-4337/                        # ERC-4337 interfaces (EntryPoint, UserOperation)
├── infrastructure/
│   └── FacetRegistry.sol           # whitelist of approved facets
├── interfaces/                     # IBarz, IFacet, etc.
├── libraries/                      # LibDiamond, LibFacetStorage, etc.
└── restrictions/                   # pluggable restriction modules
```

---

## Deploying a Barz Wallet

```typescript
// Deploy via BarzFactory (creates deterministic address)
const factory = await ethers.getContractAt('BarzFactory', FACTORY_ADDRESS);

const owner = '0xOwnerAddress';
const verificationFacet = SECP256K1_FACET_ADDRESS; // or Secp256r1
const salt = 0;

// Compute counterfactual address before deployment
const accountAddress = await factory.getAddress(verificationFacet, owner, salt);

// Deploy (or no-op if already deployed)
await factory.createAccount(verificationFacet, owner, salt);
```

---

## Adding a New Facet

```solidity
// 1. Define storage struct in a library
library MyFeatureFacetStorage {
    bytes32 constant STORAGE_POSITION =
        keccak256("barz.my-feature.storage");

    struct Layout {
        // your state here
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 pos = STORAGE_POSITION;
        assembly { l.slot := pos }
    }
}

// 2. Implement the facet
contract MyFeatureFacet {
    using MyFeatureFacetStorage for MyFeatureFacetStorage.Layout;

    function myFunction() external {
        MyFeatureFacetStorage.layout().someField = value;
    }
}

// 3. Register in FacetRegistry (governance/admin tx)
// 4. Add via DiamondCut from the wallet owner
IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
cuts[0] = IDiamondCut.FacetCut({
    facetAddress: address(myFacet),
    action: IDiamondCut.FacetCutAction.Add,
    functionSelectors: selectors
});
IBarz(wallet).diamondCut(cuts, address(0), "");
```

---

## Writing Tests

```typescript
// Hardhat — tests/facets/MyFeature.test.ts
import { ethers } from 'hardhat';
import { setupBarz } from '../utils/setup';

describe('MyFeatureFacet', () => {
    let barz: Contract;

    beforeEach(async () => {
        ({ barz } = await setupBarz({ verificationFacet: 'Secp256k1' }));
    });

    it('does the thing', async () => {
        const facet = await ethers.getContractAt('MyFeatureFacet', barz.address);
        // ...
    });
});
```

```solidity
// Foundry — test/MyFeature.t.sol
contract MyFeatureTest is BarzTestBase {
    function setUp() public override {
        super.setUp();
        // attach your facet via diamondCut
    }

    function testMyFunction() public {
        // assert
    }

    function testFuzz_myFunction(uint256 input) public {
        // fuzz
    }
}
```

---

## ERC-4337 Flow

```
UserOperation
    → Bundler
        → EntryPoint.handleOps()
            → Barz.validateUserOp()     (AccountFacet)
                → VerificationFacet.validateSignature()
            → Barz.execute() / executeBatch()
```

UserOp signature field contains the signature validated by whichever `VerificationFacet` is currently active on the account.

---

## Key Interfaces

```solidity
interface IBarz {
    // ERC-4337
    function validateUserOp(UserOperation calldata, bytes32, uint256) external returns (uint256);
    function execute(address dest, uint256 value, bytes calldata func) external;
    function executeBatch(address[] calldata, uint256[] calldata, bytes[] calldata) external;

    // Diamond
    function diamondCut(FacetCut[] calldata, address, bytes calldata) external;
    function facets() external view returns (Facet[] memory);
    function facetAddress(bytes4 selector) external view returns (address);
}
```

---

## Audits

Audit reports are in the `audit/` directory of the repo.
