---
name: apacfinstab
description: Get real-time crypto regulatory intelligence for Asia-Pacific markets. Check compliance requirements, track policy changes, and compare licensing rules across HK, SG, JP, KR, AU and other APAC jurisdictions. Use when building Web3 apps that need to comply with regional regulations.
---

# APAC FINSTAB - Crypto Regulatory Intelligence

Use this skill when you need to:
- Check crypto regulatory requirements in Asia-Pacific regions
- Understand licensing requirements for exchanges, stablecoins, or DeFi protocols
- Compare compliance rules across different APAC jurisdictions
- Track recent policy changes that may affect Web3 applications

## MCP Server

Install the APAC FINSTAB MCP server for direct access to regulatory data:

```json
{
  "mcpServers": {
    "apacfinstab": {
      "command": "npx",
      "args": ["-y", "@apacfinstab/mcp-server"]
    }
  }
}
```

## Available Tools

### getLatestPolicies
Get recent crypto policy events filtered by region and topic.

```
Use getLatestPolicies to check recent regulatory changes in Hong Kong
```

### getRegionOverview
Get comprehensive regulatory overview for a specific APAC region.

```
Use getRegionOverview for Singapore to understand MAS licensing requirements
```

### comparePolicies
Compare crypto policies across multiple APAC regions.

```
Use comparePolicies to compare stablecoin rules between HK and SG
```

## Supported Regions

| Code | Region | Primary Regulator |
|------|--------|-------------------|
| HK | Hong Kong | SFC / HKMA |
| SG | Singapore | MAS |
| JP | Japan | FSA / JVCEA |
| KR | South Korea | FSC / FSS |
| AU | Australia | ASIC / AUSTRAC |
| CN | China | PBOC / CBIRC |
| IN | India | RBI / SEBI |
| TH | Thailand | SEC / BOT |
| ID | Indonesia | OJK / BI |
| VN | Vietnam | SBV |
| PH | Philippines | BSP / SEC |
| MY | Malaysia | SC / BNM |
| TW | Taiwan | FSC |

## Common Use Cases

### Building a compliant exchange
```
"I'm building a crypto exchange targeting Hong Kong users. What licenses do I need?"
→ Use getRegionOverview for HK, then check recent policy changes with getLatestPolicies
```

### Launching a stablecoin
```
"What are the stablecoin requirements in Singapore vs Hong Kong?"
→ Use comparePolicies with regions=[HK, SG] and topic=Stablecoin
```

### Expanding to new markets
```
"We're licensed in Singapore, what's required to expand to Japan?"
→ Compare regulatory requirements and identify gaps
```

## References

- Website: https://apacfinstab.com
- Policy Tracker: https://apacfinstab.com/tracker/
- npm Package: https://www.npmjs.com/package/@apacfinstab/mcp-server
- GitHub: https://github.com/fatratkiller/apacfinstab
