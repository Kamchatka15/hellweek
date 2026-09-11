# Skill: Roblox security conventions

> **Governed by `docs/ROBLOX_SUCCESS_LOGIC.md` (standing orders).** If this file fights that file, that file wins.

- Server authority for anything of value: currency, inventory, purchases, progression. The client renders and requests; it never decides.
- Every RemoteEvent/RemoteFunction: validate types/ranges, check ownership, rate-limit per player, fail closed.
- Prices exist only on the server. Client UI displays what the server tells it.
- ProcessReceipt: idempotent. Ledger receipt in DataStore (key: PurchaseHistory_<userId>, store ReceiptId) BEFORE returning PurchaseGranted; on repeat ReceiptId, return granted without re-granting. Grant path must survive server crash mid-purchase.
- DataStores: UpdateAsync over SetAsync for read-modify-write; session locking; schema version field on every record; migration function per version bump.
- Exploit response: log anomalies (impossible earn rates, teleports), soft-flag first, BanAsync for confirmed duping.
- No secrets in ReplicatedStorage/client. Open Cloud keys live in a password manager, never in repo or chat.
