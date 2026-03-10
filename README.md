<h1 align="center">SortieHUDPlus</h1>

<p align="center">
Windower HUD addon for tracking Sortie progress in Final Fantasy XI
</p>

<p align="center">
<b>Version:</b> 22.0<br>
<b>Author:</b> Madroxx
</p>

---

# Overview

SortieHUDPlus is a Windower addon designed to provide a clean, real-time HUD for tracking progress during **Sortie** runs in Final Fantasy XI.

The HUD tracks:

- Sector objective completion
- Chest / Casket / Coffer progress
- Temporary item acquisition
- Gallimaufry earned
- Fragment collection
- Aminon unlock status

The HUD updates automatically during gameplay and also allows manual corrections when needed.

---

# Features

## Dynamic HUD Views

### Ground Floor HUD (Sectors A–D)

Tracks all **8 objectives per sector**.

```
     1  2  3  4  5  6  7  8
A   [ ][ ][ ][ ][ ] [ ][ ] [ ]
B   [ ][ ][ ][ ][ ] [ ][ ] [ ]
C   [ ][ ][ ][ ][ ] [ ][ ] [ ]
D   [ ][ ][ ][ ][ ] [ ][ ] [ ]
```

---

### Basement HUD (Sectors E–H)

Tracks **4 objectives per sector**.

```
     1  2  3  4
E   [ ][ ][ ][ ]
F   [ ][ ][ ][ ]
G   [ ][ ][ ][ ]
H   [ ][ ][ ][ ]
```

---

## Objective Tracking

Objectives use a simple visual grid.

```
[ ] = Objective incomplete
[X] = Objective completed (gold)
Green row = Entire sector completed
```

Example:

```
A [X][X][X][X][X] [X][X] [X]
```

Completed objectives automatically **disappear from the objective list view**.

---

# Objective Lists

Each sector also has a detailed objective screen.

Example:

```
A Objectives (2 / 8 Complete)

A3  Vanquish 3 Abject foes with magic.
A4  Vanquish 3 more Abject foes with magic.
A5  Interact with Bitzer #A while naked.
```

Completed objectives are hidden to keep the list readable during runs.

---

# Resource Tracking

The HUD automatically tracks Sortie resources.

```
Fragments: [E][F] G H
Aminon: LOCKED
Gallimaufry: 4520 (+2300)
```

Fragments tracked:

- Fragment E
- Fragment F
- Fragment G
- Fragment H

When all fragments are collected:

```
Aminon: OPEN
```

---

# Temporary Item Tracker

Tracks Sortie temporary items across all sectors.

Items tracked:

- Metal
- Plate
- Shard
- Key

Example display:

```
      A B C D E F G H

Metal X . . . . . . .
Plate . X . . . . . .
Shard . . X . . . . .
Key   . . . X . . . .
```

Legend:

```
X = Item obtained
. = Item not obtained
```

---

# Commands

## HUD Views

Show Ground Floor HUD

```
/shud ground
```

Show Basement HUD

```
/shud basement
```

Show Temporary Item Tracker

```
/shud temp
```

---

## Objective Screens

Display objectives for a sector.

```
/shud obj a
/shud obj b
/shud obj c
/shud obj d
/shud obj e
/shud obj f
/shud obj g
/shud obj h
```

---

## Manual Objective Controls

Mark an objective complete:

```
/shud done a3
```

Example:

```
/shud done b2
```

Undo an objective completion:

```
/shud undo a3
```

Example:

```
/shud undo b2
```

The grid and objective list update immediately.

---

# Automatic Detection

SortieHUDPlus automatically detects several events from the combat log.

Detected events:

- Chest spawns
- Casket spawns
- Coffer spawns
- Gallimaufry gains

When detected:

- The objective is marked complete
- The HUD grid updates
- The objective disappears from the objective list

---

# Gallimaufry Counter

Tracks Gallimaufry gained during the current Sortie run.

Example:

```
Gallimaufry: 4520 (+2300)
```

Meaning:

- First number = total Gallimaufry detected
- Number in parentheses = gained during this run

---

# Installation

1. Place the addon folder inside:

```
Windower/addons/
```

2. Load the addon in game:

```
/lua load sortiehudplus
```

---

# Notes

- Designed specifically for **Sortie content**
- Some objective detection relies on combat log messages
- Future versions may include packet-based detection for greater accuracy

---

# Credits

Original Addon Concept  
https://www.ffxiah.com/forum/topic/56901/sortiehud-track-completed-objectives-rewards/#3638912

Original Author  
Sockfoot (Bismarck)

Expanded Development  
Madroxx
