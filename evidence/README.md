# evidence/ — the learning matrix

**This is the factory's memory.** Claude does not persist between sessions; this folder does.

| File | What it is |
|---|---|
| `SCHEMA.md` | The record format, the seven context dimensions, and the three rules that keep it honest |
| `ledger/E-####.md` | One record per finding. Never deleted, never overwritten |
| `match.py` | Ask the ledger what it knows about a new situation |
| `MATRIX.md` | Generated table view of every record — regenerate with `python3 match.py --matrix` |

## Ask it something

```sh
python3 evidence/match.py --domain retention --loop_verb collect --session_shape snack
python3 evidence/match.py --brief roblox-pipeline/games/fat-man-gets-rich/brief.md
python3 evidence/match.py --matrix > evidence/MATRIX.md
```

## Honest status

The ledger currently holds **process** evidence only — things learned about how the factory itself behaves. It holds **zero player evidence**, because Gate B has not happened yet: no title has been in front of cold players. That is not a gap in the ledger, it is an accurate report of what is actually known. The first real retention and economy records arrive with the first Gate B.
