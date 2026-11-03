# NPCs (NPC_)

- Setting: `iEnableNPCPatching=1` in `Data/F4SE/Plugins/RobCo_Patcher.ini`
- Folder: `Data/F4SE/Plugins/RobCo_Patcher/npc/`

Important: NPC, race, keyword, faction and exclusion filters are evaluated independently.
NPC level fields are used differently by the game depending on flags and record setup —
change level-related operations carefully.

## Filters

### filterByNpcs
Value: NPC_ forms, comma-separated — select specific NPCs.

```
filterByNpcs=Fallout4.esm|00000007,MyMod.esp|00001000
```

### filterByNpcsExcluded
Value: NPC_ forms, comma-separated — exclude specific NPCs.

```
filterByNpcsExcluded=Fallout4.esm|00000007
```

### filterByKeywords
Value: KYWD forms, comma-separated — all listed keywords must be present (AND).

```
filterByKeywords=Fallout4.esm|0002CB72,Fallout4.esm|000EAFB7
```

### filterByKeywordsOr
Value: KYWD forms, comma-separated — at least one listed keyword must be present (OR).

```
filterByKeywordsOr=Fallout4.esm|0006B4F2,Fallout4.esm|00179C60
```

### filterByKeywordsExcluded
Value: KYWD forms, comma-separated — exclude NPCs containing any listed keyword.

```
filterByKeywordsExcluded=Fallout4.esm|00179C60
```

### filterByRaces
Value: RACE forms, comma-separated — match NPCs using one of the listed races.

```
filterByRaces=Fallout4.esm|00013746,Fallout4.esm|000EAFB6
```

### filterByClass
Value: CLAS forms, comma-separated — match NPCs using one of the listed classes.

```
filterByClass=Fallout4.esm|00012345
```

### filterByFactions
Value: FACT forms, comma-separated — all listed factions must match (AND).

```
filterByFactions=Fallout4.esm|0001CBED,Fallout4.esm|0002BE3B
```

### filterByFactionsOr
Value: FACT forms, comma-separated — at least one listed faction must match (OR).

```
filterByFactionsOr=Fallout4.esm|0001CBED,Fallout4.esm|0002BE3B
```

### filterByFactionsExcluded
Value: FACT forms, comma-separated — exclude NPCs belonging to any listed faction.

```
filterByFactionsExcluded=Fallout4.esm|0001CBED
```

### filterByGender
Value: `male` or `female`.

```
filterByGender=female
filterByGender=male
```

### filterByModNames
Value: plugin names, comma-separated — only patch records originating from the listed plugins.

```
filterByModNames=Fallout4.esm,MyMod.esp
```

### chance
Value: percentage — apply the rule using the configured percentage chance.

```
filterByRaces=Fallout4.esm|0006B4EC:chance=50:keywordsToAdd=MyMod.esp|00001000
```

### levelRange
Value: `Min~Max` — define the level interval used by ranged `changeAVIFS` values.

When an actor value also uses a range, the final value is calculated proportionally from the
NPC level. Example `levelRange=25~100:changeAVIFS=Fallout4.esm|000002D4=150~250`:

- A level 1 NPC receives 150.
- A level 25 NPC receives 150.
- A level 50 NPC receives approximately 183.
- A level 100 NPC receives 250.
- A level 200 NPC receives 250.

Without `levelRange`, ranged values are randomized instead of scaled by level.

## Operations

### setAutoCalcStats
Value: `yes`, `true`, `no`, or `false` — toggle the kAutoCalcStats flag (lets the game
recalculate NPC stats when certain events occur).

```
setAutoCalcStats=no
setAutoCalcStats=true
```

### setPcLevelMult
Value: `yes=Value` or `no=Value` — toggle the kPCLevelMult flag and configure the associated
level multiplier value.

```
setPcLevelMult=yes=1.0
setPcLevelMult=no=1.0
```

### setEssential
Value: `yes`, `true`, `no`, or `false` — toggle the Essential flag.

```
setEssential=true
setEssential=false
```

### setProtected
Value: `yes`, `true`, `no`, or `false` — toggle the Protected flag.

```
setProtected=true
setProtected=false
```

### changeAVIFS
Value: `AVIF=Value` or `AVIF=Min~Max` — change NPC actor values (Health, resistances and
other actor-value-based stats). Multiple entries are comma-separated. A single value sets the
actor value directly. A range applies either a random value or a proportional value when
`levelRange` is present.

```
changeAVIFS=Fallout4.esm|000002D4=140
changeAVIFS=Fallout4.esm|000002D4=140~180
levelRange=25~100:changeAVIFS=Fallout4.esm|000002D4=150~250
```

### keywordsToAdd / keywordsToRemove
Value: KYWD forms, comma-separated.

```
keywordsToAdd=Better Locational Damage.esm|050165DA,MyMod.esp|00001000
keywordsToRemove=Fallout4.esm|0006B4F2
```

### factionsToAdd
Value: `FACT=Rank` or `FACT=Min~Max` — add factions with a fixed or random rank. Rank 0 is
usually the appropriate starting rank when no special rank is required.

```
factionsToAdd=Fallout4.esm|0001CBED=0
factionsToAdd=Fallout4.esm|0001CBED=0~3
```

### factionsToRemove
Value: FACT forms, comma-separated.

```
factionsToRemove=Fallout4.esm|0001CBED
```

### perksToAdd
Value: PERK forms, comma-separated — add perks at rank 1.

```
perksToAdd=Fallout4.esm|0004A0B5
```

### spellsToAdd
Value: SPEL forms, comma-separated.

```
spellsToAdd=MyMod.esp|00001010
```

### objectsToAdd
Value: `ObjectForm=Count`, comma-separated — add inventory objects or leveled lists.

```
objectsToAdd=Fallout4.esm|000211CC=5
```

### objectsToRemove
Value: object forms, comma-separated — remove inventory objects or leveled lists. Parsing is
case-insensitive.

```
objectsToRemove=Fallout4.esm|000211CC
```

### outfitDefault
Value: OTFT form — set the default outfit.

```
outfitDefault=MyMod.esp|00001001
```

### outfitSleep
Value: OTFT form — set the sleep outfit.

```
outfitSleep=MyMod.esp|00001002
```

### deathItem
Value: LVLI form or `null` — set or clear the NPC death item.

```
deathItem=Fallout4.esm|0003AB40
deathItem=null
```

### skin
Value: ARMO form or `null` — set or clear the NPC skin armor.

```
skin=Fallout4.esm|0001E22E
skin=null
```

### race
Value: RACE form — set the NPC race.

```
race=Fallout4.esm|0006B4EC
```

### powerArmorStand
Value: FURN form or `null` — set or clear the NPC power-armor furniture record.

```
powerArmorStand=Fallout4.esm|0012B2E9
powerArmorStand=null
```

### class
Value: CLAS form — set the NPC class.

```
class=Fallout4.esm|00012345
```

### xpValueOffset
Value: number — set the XP value offset applied when the NPC is killed.

```
xpValueOffset=50
```

### level
Value: number — set the NPC level field.

```
level=25
```

### calcLevelMin
Value: number — set the calculated minimum level used with PC-level scaling.

```
calcLevelMin=10
```

### calcLevelMax
Value: number — set the calculated maximum level used with PC-level scaling.

```
calcLevelMax=100
```

### fullName
Value: `~text~` — change the displayed NPC name.

```
filterByNpcs=MyMod.esp|00001000:fullName=~Hellbender 5000~
```

## Example strings

```
// Patch the player
filterByNpcs=Fallout4.esm|00000007:changeAVIFS=Fallout4.esm|000002D4=140

// Patch ghouls and humans
filterByRaces=Fallout4.esm|00013746,Fallout4.esm|000EAFB6:filterByKeywords=Fallout4.esm|0002CB72,Fallout4.esm|000EAFB7:setAutoCalcStats=no:levelRange=25~100:changeAVIFS=Fallout4.esm|000002D4=140~180,Fallout4.esm|000002E3=0,Fallout4.esm|000002EB=0:keywordsToAdd=Better Locational Damage.esm|050165DA

// Patch feral ghouls
filterByRaces=Fallout4.esm|0006B4EC:filterByKeywords=Fallout4.esm|0006B4F2:setAutoCalcStats=yes:changeAVIFS=Fallout4.esm|000002D4=200~250,Fallout4.esm|000002E3=0,Fallout4.esm|000002EB=0,Fallout4.esm|000002DF=40~60:keywordsToAdd=Better Locational Damage.esm|050165DA

// Patch glowing feral ghouls
filterByRaces=Fallout4.esm|000A96BF:filterByKeywords=Fallout4.esm|00179C60:setAutoCalcStats=true:changeAVIFS=Fallout4.esm|000002D4=280~320,Fallout4.esm|000002E3=0,Fallout4.esm|000002EB=0,Fallout4.esm|000002DF=40~60:keywordsToAdd=Better Locational Damage.esm|050165DC

// Patch one NPC
filterByNpcs=MyMod.esp|00001000:setEssential=true:outfitDefault=MyMod.esp|00001001
```

## Notes

- The player (`Fallout4.esm|00000007`) is always excluded from race and keyword filtering.
  To patch the player use `filterByNpcs=Fallout4.esm|00000007` and no other filter.
- Test `level`, `calcLevelMin`, `calcLevelMax` and `setPcLevelMult` changes carefully in game.
- When `levelRange` is omitted, ranged `changeAVIFS` values are randomized instead of scaled
  by NPC level.
- A missing or invalid individual form is skipped instead of disabling the entire line.
- Use `null` only for operations that explicitly support clearing a form.
