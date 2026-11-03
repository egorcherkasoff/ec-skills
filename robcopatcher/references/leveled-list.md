# Leveled Lists and Containers (LVLI, CONT)

- Setting: `iEnableLeveledListPatching=1` in `Data/F4SE/Plugins/RobCo_Patcher.ini`
- Folder: `Data/F4SE/Plugins/RobCo_Patcher/leveledList/`

Important: this module supports both leveled-item lists and containers. Leveled-list and
container filters select different record types and should only be combined with operations
intended for those records.

## Filters

### filterByLLs
Value: LVLI forms, comma-separated — select specific leveled-item lists.

```
filterByLLs=MyMod.esp|00001733,MyMod.esp|00001734
```

### filterByContainers
Value: CONT forms, comma-separated — select specific containers.

```
filterByContainers=Fallout4.esm|001338A7,MyMod.esp|00000810
```

### noFilterLL
Value: `yes`, `true`, `no`, or `false` — enable leveled-list patching without selecting
specific lists through `filterByLLs`.

```
noFilterLL=true
```

### filterByModNames
Value: plugin names, comma-separated — limit the `noFilterLL=true` path to leveled lists
originating from the listed plugins. This filter is not applied to direct `filterByLLs` or
`filterByContainers` selections.

```
noFilterLL=true:filterByModNames=Fallout4.esm,MyMod.esp
```

### chance
Value: percentage — apply the rule using the configured percentage chance.

```
filterByLLs=MyMod.esp|00001733:chance=50:addToLLs=Fallout4.esm|00004822~1~1~0
```

## Leveled list operations

### addToLLs
Value: `Form~Level~Count~ChanceNone` — add entries to selected leveled lists. Multiple
entries are comma-separated.

The last value is inverted:

- `0` means a 100% chance.
- `30` means a 70% chance.
- `100` means a 0% chance.

```
// Adds the 10mm Pistol at level 1, count 1, 100% chance
filterByLLs=MyMod.esp|00001733:addToLLs=Fallout4.esm|00004822~1~1~0
// Multiple entries
filterByLLs=MyMod.esp|00001733:addToLLs=Fallout4.esm|00004822~1~1~0,Fallout4.esm|0001F66B~10~20~25
```

### removeFromLLs
Value: `Form`, `Form~Level~Count`, or `Form~LevelCondition~CountCondition` — remove matching
entries from selected leveled lists.

The level and count values are optional. The operators `<`, `>`, `<=` and `>=` may be used
for advanced filtering. Use `none` to skip one of the two conditional fields.

```
// Remove every matching object
filterByLLs=MyMod.esp|00001734:removeFromLLs=Fallout4.esm|00004822
// Remove entries with a count greater than 3
filterByLLs=MyMod.esp|00001733:removeFromLLs=Fallout4.esm|00004822~none~>3
// Remove entries with a level of 3 or lower
filterByLLs=MyMod.esp|00001734:removeFromLLs=Fallout4.esm|00004822~<=3~none
// Remove an exact level and count
filterByLLs=MyMod.esp|00001734:removeFromLLs=Fallout4.esm|00004822~10~2
```

### removeObjectsByKeyword
Value: KYWD forms, comma-separated — remove leveled-list entries whose referenced objects
contain any listed keyword.

```
filterByLLs=MyMod.esp|00001733:removeObjectsByKeyword=Fallout4.esm|00000123
```

### clear
Value: any value except `none` — remove every entry from the selected leveled lists (also
works for containers).

```
filterByLLs=MyMod.esp|00001734:clear=yes
```

### calcForLevel
Value: `yes`, `true`, `no`, or `false` — toggle "Calculate From All Levels Less Than or
Equal to the Player's Level".

```
filterByLLs=MyMod.esp|00001734:calcForLevel=yes
filterByLLs=MyMod.esp|00001734:calcForLevel=no
```

### calcEachItem
Value: `yes`, `true`, `no`, or `false` — toggle "Calculate For Each Item In Count".

```
filterByLLs=MyMod.esp|00001734:calcEachItem=yes
filterByLLs=MyMod.esp|00001734:calcEachItem=no
```

### calcLevelAndEachItem
Value: `yes`, `true`, `no`, or `false` — set both Calculate From All Levels and Calculate
For Each Item.

```
filterByLLs=MyMod.esp|00001734:calcLevelAndEachItem=yes
```

### calcUseAll
Value: integer — enable Use All and set the maximum number of entries that may be selected.

```
filterByLLs=MyMod.esp|00001734:calcUseAll=5
```

### addTemplateKeywords
Value: template specification — add template keywords to leveled-list entries. This is an
advanced operation and requires the expected legacy syntax.

### addToLL
Value: `TargetLL~Level~Reference~Count~Chance` — add one entry to a target leveled list
using the legacy or special single-entry syntax.

```
addToLL=MyMod.esp|00001733~10~Fallout4.esm|00004822~1~0
```

## Container operations

### addToContainers
Value: `Form~Count` — add objects, items or leveled lists to selected containers. Multiple
entries are comma-separated.

```
filterByContainers=Fallout4.esm|001338A7:addToContainers=MyTestESP.esp|E4001733~100
filterByContainers=Fallout4.esm|001338A7:addToContainers=Fallout4.esm|0000000F~100,Fallout4.esm|0001F66B~25
```

### removeFromContainers
Value: forms, comma-separated — remove matching objects, items or leveled lists from
selected containers.

```
filterByContainers=Fallout4.esm|001338A7:removeFromContainers=Fallout4.esm|0000000F,Fallout4.esm|0008531F,Fallout4.esm|00085320,Fallout4.esm|000F2E1E
```

### clear
Value: any value except `none` — remove every inventory entry from the selected containers.

```
filterByContainers=Fallout4.esm|001338A7:clear=yes
```

## Example strings

```
// Add a weapon to a leveled list
filterByLLs=MyMod.esp|00001733:addToLLs=Fallout4.esm|00004822~1~1~0

// Add ammunition with a 70% chance
filterByLLs=MyMod.esp|00001733:addToLLs=Fallout4.esm|0001F66B~10~20~30

// Remove one object from a leveled list
filterByLLs=MyMod.esp|00001734:removeFromLLs=Fallout4.esm|00004822

// Remove high-count entries
filterByLLs=MyMod.esp|00001733:removeFromLLs=Fallout4.esm|00004822~none~>3

// Remove entries by keyword
filterByLLs=MyMod.esp|00001733:removeObjectsByKeyword=Fallout4.esm|00092A86

// Clear and rebuild a leveled list
filterByLLs=MyMod.esp|00001734:clear=yes:addToLLs=Fallout4.esm|00004822~1~1~0

// Configure leveled-list calculation flags
filterByLLs=MyMod.esp|00001734:calcForLevel=yes:calcEachItem=yes

// Add ammunition to a container
filterByContainers=Fallout4.esm|001338A7:addToContainers=Fallout4.esm|0001F66B~25

// Add a leveled list to a container
filterByContainers=Fallout4.esm|001338A7:addToContainers=MyTestESP.esp|E4001733~100

// Remove several objects from a container
filterByContainers=Fallout4.esm|001338A7:removeFromContainers=Fallout4.esm|0000000F,Fallout4.esm|0008531F,Fallout4.esm|00085320

// Clear and refill a container
filterByContainers=Fallout4.esm|001338A7:clear=yes:addToContainers=Fallout4.esm|0000000F~100
```

## Notes

- `filterByLLs` is used for leveled-item lists; `filterByContainers` is used for container
  inventories.
- For LVLI, operations that act on the selected list (`addToLLs`, `removeFromLLs`,
  `removeObjectsByKeyword`, `addTemplateKeywords`, the calculation flags and `clear`) need
  `filterByLLs` or `noFilterLL=true`; a line with only one of those operations does not target
  every LVLI record automatically. `addToLL` instead names its target list in its own value.
  Container operations use `filterByContainers` instead.
- `addToLLs`, `removeFromLLs` and calculation operations only apply to leveled lists.
- `addToContainers` and `removeFromContainers` only apply to containers.
- `clear` works with both selected leveled lists and selected containers.
- The ChanceNone value used by `addToLLs` is inverted: `0` means a 100% chance.
- Level values are not automatically normalized.
- Test `removeFromLLs`, `addTemplateKeywords` and `addToLL` with real records before
  distributing a large configuration.
