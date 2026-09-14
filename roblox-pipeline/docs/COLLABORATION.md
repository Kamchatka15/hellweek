# Working with a partner on Hell Week

> Two people, two very different jobs, and they need two different tools. Using the wrong one
> silently destroys work, so read the split before setting anything up.

## The split that matters

| What is being changed | Where it lives | The right tool |
|---|---|---|
| **Code** — the loop, the pack, the config, the generators | `.luau` and `.py` files on disk | **Git**. Never Team Create |
| **Looking at it / playtesting before publish** | The live place on Roblox | **Team Create, Play access** |
| **Hand work only Studio can do** — mesh imports, `Lighting.Technology`, publishing | The live place | **Team Create, Edit access** |

## Why Team Create is wrong for the code

This game is built by **Rojo**: the real source is the files on disk, and Studio is downstream of them.
A sync rebuilds the scripts in Studio from disk.

So if a partner types a change into a script inside Team Create, the next sync **overwrites it**. No
warning, no merge, no conflict. And if two people both sync from their own disks into one shared
place, whoever syncs last wins and the other's work is gone.

**Rule: nobody edits a script inside Studio. Scripts are edited on disk and synced in.**

## The blocker today

Two things are missing right now.

1. **The place has never been saved to Roblox.** `PlaceId` is 0, which means `hellweek.rbxl` exists
   only on this Mac. Team Create is a cloud session, so there is nothing for a partner to join yet.
2. **The git repository has no remote.** Everything is committed locally to `master` and pushed
   nowhere, so there is nothing for a partner to clone.

Both are one-time fixes.

---

# Path A — Git, for the code

This is the one that matters. Do this first.

### On the owner's machine
1. Create a **private** repository on GitHub. Private, not public: this is unreleased game code.
2. Point the local repo at it and push:
   ```
   git remote add origin git@github.com:<owner>/<repo>.git
   git push -u origin master
   ```
3. Add the partner as a collaborator on the repository in GitHub's settings.

### On the partner's machine
1. Clone the repository.
2. Install the toolchain. The repo pins its own versions, so:
   ```
   rokit install
   ```
   That brings the matching `rojo`, `selene` and `stylua`. Matching versions matter; a different
   `stylua` reformats every file and turns the next diff into noise.
3. Open a fresh empty place in Studio, then:
   ```
   rojo serve
   ```
   and connect from the Rojo plugin. He now has his own local copy of the whole game, built from
   source, with no risk to anyone else's.

### Working rules
- Branch per change. `git checkout -b <what-it-is>` and open a pull request.
- Never `git add -A`. Stage by path. Files get edited live in this tree and a blanket add sweeps up
  work in progress.
- `selene src games` and `stylua --check src games` before committing. A commit hook enforces the
  second one.

**The partner never needs the owner's place, the owner's account, or Team Create to write code.**

---

# Path B — Team Create, for viewing and for Studio-only work

Use this for playtesting together and for the handful of jobs Rojo cannot do.

### Step 1 — save the place to Roblox (owner)
In Studio: **File → Publish to Roblox As…**, name it, and create the experience.

Then, in the Creator Dashboard, set the experience's **Privacy to Private**. This is the step that
lets a partner in without letting the public in. It is not a release, and it does not need the
release gate.

### Step 2 — both accounts need age verification (both)
Roblox requires verified age before it will let two people collaborate. ID or facial age estimation,
in account settings. There is no way round this.

### Step 3 — decide user-owned or group-owned (owner)
This choice has a real consequence:

| | **User-owned** | **Group-owned** |
|---|---|---|
| Granting **Edit** | Only to **Roblox friends** | To anyone with the right group role |
| Adding more people later | One at a time, each must be a friend | Change their role |
| Who owns the revenue and the experience | The individual | The group |

**Recommend group-owned.** Create a Roblox group, move the experience into it, and give the partner
a role with build permissions. It removes the friend requirement, it scales, and it keeps ownership
separate from one person's account.

If staying user-owned, the two accounts must be **friends** before Edit can be granted.

### Step 4 — add the collaborator (owner)
In Studio, with the place open: the **Collaborate** button on the top bar, right-hand side. Search
the partner's username, add them, choose the level, save.

| Level | What it allows |
|---|---|
| **Play** | Joins and plays the unpublished place. Cannot change anything |
| **Edit** | Full Studio editing, including scripts |
| **Owner** | Also manages everyone else's permissions |

**Give Play first.** Move to Edit only when there is a Studio-only job to do, and read the next
section before anyone uses it.

---

# The rule that keeps both paths from destroying each other

Anything done by hand in Studio is **temporary** unless it is exported back to disk. The next Rojo
sync rebuilds from files and silently discards the rest.

Things that are legitimately hand-done in Studio, and what happens to them:

| Job | Survives a sync? |
|---|---|
| Importing a mesh, then storing it in `ServerStorage` | **Yes** — it is an asset in the place, not a script |
| `Lighting.Technology` | **Yes** — a place property, and it cannot be set from a script anyway |
| Publishing | n/a |
| **Editing any script** | **NO. It is gone on the next sync** |
| Moving parts around in the viewport | **No** — the world is generated from `world.luau` |

So: the partner can import art, flip place settings, and play. He must not type into a script.

## Suggested division of labour

- **Owner**: runs Rojo, owns the place, does the publishing.
- **Partner**: writes code on his own machine against his own local place, opens pull requests, and
  joins Team Create with **Play** access to test and give feedback.
- **Edit access**: granted only for a specific Studio-only task, then used and left alone.

## One standing rule this does not change

Publishing a version **to players**, and creating any paid product, still needs an explicit human
decision every time. Adding a collaborator does not delegate that.
