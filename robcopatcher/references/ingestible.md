# Ingestibles (ALCH)

- Setting: `iEnableIngestiblePatching=1` in `Data/F4SE/Plugins/RobCo_Patcher.ini`
- Folder: `Data/F4SE/Plugins/RobCo_Patcher/ingestible/`

Covers food, drinks, chems and other ALCH records.

Important: ingestible, keyword, magic-effect and exclusion filters are evaluated
independently. Magic-effect additions require a form, magnitude, duration and area.

## Filters

### filterByAlchs
Value: ALCH forms, comma-separated — select specific ingestible records.

```
filterByAlchs=Fallout4.esm|000366BF,MyMod.esp|00000800
```

### filterByAlchsExcluded
Value: ALCH forms, comma-separated — exclude specific ingestible records.

```
filterByAlchsExcluded=Fallout4.esm|000366BF
```

### filterByKeywords
Value: KYWD forms, comma-separated — all listed keywords must be present (AND).

```
filterByKeywords=Fallout4.esm|000A1B34,MyMod.esp|00000801
```

### filterByKeywordsOr
Value: KYWD forms, comma-separated — at least one listed keyword must be present (OR).

```
filterByKeywordsOr=Fallout4.esm|000A1B34,Fallout4.esm|000A1B35
```

### filterByKeywordsExcluded
Value: KYWD forms, comma-separated — exclude ingestibles containing any listed keyword.

```
filterByKeywordsExcluded=MyMod.esp|00000801
```

### filterByMgefs
Value: MGEF forms, comma-separated — all listed magic effects must be present (AND).

```
filterByMgefs=Fallout4.esm|00000397,MyMod.esp|00000810
```

### filterByMgefsOr
Value: MGEF forms, comma-separated — at least one listed magic effect must be present (OR).

```
filterByMgefsOr=Fallout4.esm|00000397,Fallout4.esm|000B8587
```

### filterByMgefsExcluded
Value: MGEF forms, comma-separated — exclude ingestibles containing any listed magic effect.

```
filterByMgefsExcluded=Fallout4.esm|00000397
```

### filterByType
Value: supported ingestible type — filter by ingestible type.

```
filterByType=food
```

### filterByModNames
Value: plugin names, comma-separated — only patch records originating from the listed plugins.

```
filterByModNames=Fallout4.esm,MyMod.esp
```

## Operations

### fullName
Value: `~text~` — change the displayed name.

```
filterByAlchs=Fallout4.esm|000366BF:fullName=~Hellbender 5000~
```

### keywordsToAdd / keywordsToRemove
Value: KYWD forms, comma-separated.

```
filterByAlchs=MyMod.esp|00000800:keywordsToAdd=MyMod.esp|00000801,MyMod.esp|00000802
filterByAlchs=MyMod.esp|00000800:keywordsToRemove=MyMod.esp|00000801
```

### mgefsToAdd
Value: `MGEF~Magnitude~Duration~Area` — add magic effects. Separate multiple effects with
commas.

- MGEF is the magic-effect form.
- Magnitude is the effect strength.
- Duration is the duration in seconds.
- Area is the effect area.

```
filterByAlchs=MyMod.esp|00000800:mgefsToAdd=Fallout4.esm|000B8587~20~5~0
filterByAlchs=MyMod.esp|00000800:mgefsToAdd=Fallout4.esm|000B8587~20~5~0,MyMod.esp|00000810~10~30~0
```

### mgefsToChange
Value: `MGEF~Magnitude~Duration~Area` — change matching magic effects. Separate multiple
effects with commas. Use `null` for an individual numeric field that should remain
unchanged.

```
// Change all effect values
filterByAlchs=Fallout4.esm|000366BF:mgefsToChange=Fallout4.esm|00000397~10~5~0
// Keep duration unchanged
filterByAlchs=Fallout4.esm|000366BF:mgefsToChange=Fallout4.esm|00000397~10~null~0
// Change only duration
filterByAlchs=Fallout4.esm|000366BF:mgefsToChange=Fallout4.esm|00000397~null~30~null
// Change multiple effects
filterByAlchs=MyMod.esp|00000800:mgefsToChange=Fallout4.esm|00000397~10~5~0,Fallout4.esm|000B8587~25~10~0
```

### mgefsToRemove
Value: MGEF forms, comma-separated — remove matching magic effects.

```
filterByAlchs=MyMod.esp|00000800:mgefsToRemove=Fallout4.esm|00000397
filterByAlchs=MyMod.esp|00000800:mgefsToRemove=Fallout4.esm|00000397,Fallout4.esm|000B8587
```

### clear
Value: any value except `none` — remove all magic effects from the selected ingestibles.

```
filterByAlchs=MyMod.esp|00000800:clear=yes
```

### weight
Value: number — set ingestible weight.

```
filterByAlchs=MyMod.esp|00000800:weight=0.5
```

### value
Value: number — set the caps value.

```
filterByAlchs=MyMod.esp|00000800:value=25
```

## Example strings

```
// Change weight and value
filterByAlchs=Fallout4.esm|000366BF:weight=0.5:value=25

// Rename an ingestible
filterByAlchs=Fallout4.esm|000366BF:fullName=~Hellbender 5000~

// Add a magic effect
filterByAlchs=MyMod.esp|00000800:mgefsToAdd=Fallout4.esm|000B8587~20~5~0

// Change an existing magic effect
filterByAlchs=Fallout4.esm|000366BF:mgefsToChange=Fallout4.esm|00000397~10~5~0

// Change magnitude without changing duration
filterByAlchs=Fallout4.esm|000366BF:mgefsToChange=Fallout4.esm|00000397~10~null~null

// Remove a magic effect
filterByAlchs=MyMod.esp|00000800:mgefsToRemove=Fallout4.esm|00000397

// Patch ingestibles containing a specific effect
filterByMgefs=Fallout4.esm|00000397:value=50

// Patch ingestibles containing either effect
filterByMgefsOr=Fallout4.esm|00000397,Fallout4.esm|000B8587:weight=0.25

// Clear and replace all effects
filterByAlchs=MyMod.esp|00000800:clear=yes:mgefsToAdd=Fallout4.esm|000B8587~20~5~0
```

## Notes

- The implemented operation key is `mgefsToChange`, not `changeMgefs`.
- `mgefsToAdd` requires all four values: form, magnitude, duration and area.
- `null` may be used for individual numeric fields in `mgefsToChange` to preserve existing
  values.
- `clear` removes all magic effects from the selected ingestible.
- Invalid individual forms or values are skipped.
