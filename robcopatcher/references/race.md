# Races (RACE)

- Setting: `iEnableRacePatching=1` in `Data/F4SE/Plugins/RobCo_Patcher.ini`
- Folder: `Data/F4SE/Plugins/RobCo_Patcher/race/`

Important: race, keyword and exclusion filters are evaluated independently. Ranged
actor-value changes choose a random value between Min and Max (no `levelRange` here, unlike
the NPC patcher).

## Filters

### filterByRaces
Value: RACE forms, comma-separated — select specific races.

```
filterByRaces=Fallout4.esm|0006B4EC,Fallout4.esm|000A96BF
```

### filterByRacesExcluded
Value: RACE forms, comma-separated — exclude specific races.

```
filterByRacesExcluded=Fallout4.esm|000A96BF
```

### filterByKeywords
Value: KYWD forms, comma-separated — all listed keywords must be present (AND).

```
filterByKeywords=Fallout4.esm|0006B4F2,MyMod.esp|00000800
```

### filterByKeywordsOr
Value: KYWD forms, comma-separated — at least one listed keyword must be present (OR).

```
filterByKeywordsOr=Fallout4.esm|0006B4F2,Fallout4.esm|00179C60
```

### filterByKeywordsExcluded
Value: KYWD forms, comma-separated — exclude races containing any listed keyword.

```
filterByKeywordsExcluded=Fallout4.esm|00179C60
```

### filterByModNames
Value: plugin names, comma-separated — only patch records originating from the listed plugins.

```
filterByModNames=Fallout4.esm,MyMod.esp
```

### chance
Value: percentage — apply the rule using the configured percentage chance.

```
filterByRaces=Fallout4.esm|0006B4EC:chance=50:spellsToAdd=MyMod.esp|00000800
```

## Operations

### changeAVIFS
Value: `AVIF=Value` or `AVIF=Min~Max` — change race actor values such as Health, resistances
and damage modifiers. Multiple entries are comma-separated. Negative values are accepted.
A single value sets the actor value directly; a range chooses a random value between Min and
Max.

```
changeAVIFS=Fallout4.esm|000002D4=200
changeAVIFS=Fallout4.esm|000002DF=40~60
changeAVIFS=Fallout4.esm|000002E3=-25

// Multiple actor values
filterByRaces=Fallout4.esm|0006B4EC:changeAVIFS=Fallout4.esm|000002D4=200~250,Fallout4.esm|000002E3=0,Fallout4.esm|000002EB=0,Fallout4.esm|000002DF=40~60
```

### keywordsToAdd / keywordsToRemove
Value: KYWD forms, comma-separated.

```
filterByRaces=Fallout4.esm|0006B4EC:keywordsToAdd=MyMod.esp|00000800,MyMod.esp|00000801
filterByRaces=Fallout4.esm|0006B4EC:keywordsToRemove=Fallout4.esm|0006B4F2
```

### spellsToAdd
Value: SPEL forms, comma-separated — add spells to races.

```
filterByRaces=Fallout4.esm|0006B4EC:spellsToAdd=MyMod.esp|00000800,MyMod.esp|00000801
```

## Example strings

```
// Change feral ghoul actor values
filterByRaces=Fallout4.esm|0006B4EC:changeAVIFS=Fallout4.esm|000002D4=200~250,Fallout4.esm|000002DF=40~60

// Patch glowing feral ghouls
filterByRaces=Fallout4.esm|000A96BF:filterByKeywords=Fallout4.esm|00179C60:changeAVIFS=Fallout4.esm|000002D4=280~320,Fallout4.esm|000002DF=40~60

// Patch by keyword
filterByKeywords=Fallout4.esm|0006B4F2:keywordsToAdd=MyMod.esp|00000800

// Add a spell to selected races
filterByRaces=Fallout4.esm|0006B4EC,Fallout4.esm|000A96BF:spellsToAdd=MyMod.esp|00000810

// Apply a random resistance change
filterByRaces=Fallout4.esm|0006B4EC:chance=50:changeAVIFS=Fallout4.esm|000002DF=25~50
```

## Notes

- Unlike NPC patching, race patching does not use `levelRange`. Ranged `changeAVIFS` values
  are randomized.
- A single actor-value number sets an exact value.
- Negative actor-value values are supported.
- A missing or invalid individual form is skipped.
