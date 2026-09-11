# Skill: economy design conventions

> **Governed by `docs/ROBLOX_SUCCESS_LOGIC.md` (standing orders).** If this file fights that file, that file wins.

- Every game ships an economy workbook before code: currencies, earn rates/hr by phase, sinks, price ladder.
- Price ladder: first purchase 25–99 R$ and overdelivering (it converts trust); mid 199–499; status/prestige higher. Repeatable developer products > one-time passes for LTV; 1–2 passes early for trust.
- Every SKU answers: "what does this let me DO or SHOW?" Acceleration touches the loop players already love; status must be visible to other players.
- Paid random items: exact numeric odds shown BEFORE purchase, summing to 100%; applies to indirect purchases (keys/tickets); honor PolicyService ArePaidRandomItemsRestricted + IsPaidItemTradingAllowed (UK/AU/BE/NL/BR). Default choice: direct-buy + earnable instead.
- NO simulated gambling at any rating: never stake currency/items on chance outcomes. Chance-flavored fun must be un-wagered (readable, telegraphed, or pure PvE spectacle).
- Monthly audit: inflation (median wallet vs. price ladder), first-purchase conversion, whale concentration (>30% revenue from 10 accounts → rebalance toward breadth).
- Context: DevEx $0.0038/R$ ($0.0054 US-18+ spend). Creator Rewards pays on active-spender play days and on first-$100 of users you bring — retention and off-platform links are revenue lines.
