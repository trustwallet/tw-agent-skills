# tw-agent-skills

> **Note:** This repository contains Trust Wallet's open source skills for Claude Code. For information about the Agent Skills standard, see [agentskills.io](http://agentskills.io).

Skills are folders of instructions and references that Claude loads to improve performance on specialized tasks. These skills teach Claude how to work with Trust Wallet's libraries and developer platform in a repeatable, accurate way.

For more information, check out:
- [What are skills?](https://support.claude.com/en/articles/12512176-what-are-skills)
- [Using skills in Claude](https://support.claude.com/en/articles/12512180-using-skills-in-claude)
- [How to create custom skills](https://support.claude.com/en/articles/12512198-creating-custom-skills)

# About This Repository

This repository contains skills for building with Trust Wallet's open source projects — Web3 providers, wallet signing, smart contract wallets, token assets, and the developer platform.

Each skill is self-contained in its own folder with a `SKILL.md` file. Browse through to understand the patterns or contribute new skills.

# Skill Sets

- [./skills](./skills) — Trust Wallet developer skills
- [./spec](./spec) — Agent Skills specification
- [./template](./template) — Skill template

# Try in Claude Code

## Installation

Register this repository as a Claude Code plugin marketplace:

```
/plugin marketplace add trustwallet/tw-agent-skills
```

## Installing Skills

Install the web3-skills plugin (all Trust Wallet skills):

```
/plugin install web3-skills@tw-agent-skills
```

Or browse and install interactively:

1. Run `/plugin browse`
2. Select `tw-agent-skills`
3. Select `web3-skills`
4. Select `Install now`

## Updating

```
/plugin marketplace update tw-agent-skills
/plugin install web3-skills@tw-agent-skills
```

> **Note:** Restart Claude Code after installing or updating plugins.

## Using Skills

After installing, mention the skill in your request:

- "Use the trust-web3-provider skill to help me add Solana support"
- "Use the wallet-core skill to implement transaction signing in Swift"
- "Use the assets skill to check the logo CDN URL for USDC on Base"
- "Use the barz skill to add a new facet to my smart contract wallet"
- "Use the trust-developer skill to set up WalletConnect in my dApp"

# Available Skills

### web3-skills Plugin

| Skill | Description |
|-------|-------------|
| **[trust-web3-provider](./skills/trust-web3-provider/SKILL.md)** | Integrate and build on Trust Wallet's Web3 provider library — Ethereum (EIP-1193), Solana (Wallet Standard), Cosmos (Keplr), Bitcoin, Aptos, TON, Tron |
| **[wallet-core](./skills/wallet-core/SKILL.md)** | HD wallet creation, address derivation, and transaction signing across 140+ blockchains in Swift, Kotlin, TypeScript, and Go |
| **[assets](./skills/assets/SKILL.md)** | Look up token logos and metadata, list assets by chain, use CDN URLs, and contribute new assets to trustwallet/assets |
| **[barz](./skills/barz/SKILL.md)** | Build with and contribute to Barz — Trust Wallet's modular ERC-4337 smart contract wallet using the Diamond proxy pattern |
| **[trust-developer](./skills/trust-developer/SKILL.md)** | Trust Wallet developer platform — deep links, browser extension detection, and WalletConnect integration |

# Creating a Skill

Skills are simple — a folder with a `SKILL.md` file containing YAML frontmatter and instructions:

```markdown
---
name: my-skill-name
description: A clear description of what this skill does and when to use it
---

# My Skill Name

[Instructions for Claude to follow when this skill is active]
```

The frontmatter requires only two fields:
- `name` — unique identifier (lowercase, hyphens for spaces)
- `description` — what the skill does and **when Claude should activate it**

Copy `template/SKILL.md` as a starting point.

## Contributing

1. Fork this repo
2. Add your skill to `skills/<your-skill>/SKILL.md`
3. Add its path to `.claude-plugin/marketplace.json` under the `skills` array
4. Open a PR
