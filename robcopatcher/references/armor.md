# Armor (ARMO)

- Setting: `iEnableArmorPatching=1` in `Data/F4SE/Plugins/RobCo_Patcher.ini`
- Folder: `Data/F4SE/Plugins/RobCo_Patcher/armor/`

Important: armor, keyword, biped-slot and exclusion filters are evaluated independently.
Changes to armor records are also applied to attached ARMA records where supported.

## Filters

### filterByArmors
Value: ARMO forms, comma-separated — select specific armor records.

```
filterByArmors=Fallout4.esm|0001EED7,MyMod.esp|00000800
```

### filterByArmorsExcluded
Value: ARMO forms, comma-separated — exclude specific armor records.

```
filterByArmorsExcluded=Fallout4.esm|0001EED7
```

### filterByKeywords
Value: KYWD forms, comma-separated — all listed keywords must be present (AND).

```
filterByKeywords=Fallout4.esm|0004A0E8,MyMod.esp|00000801
```

### filterByKeywordsOr
Value: KYWD forms, comma-separated — at least one listed keyword must be present (OR).

```
filterByKeywordsOr=Fallout4.esm|0004A0E8,Fallout4.esm|0004A0E9
```

### filterByKeywordsExcluded
Value: KYWD forms, comma-separated — exclude armor containing any listed keyword.

```
filterByKeywordsExcluded=MyMod.esp|00000801
```

### filterByBipedSlots
Value: slot numbers, comma-separated — all listed biped slots must be present (AND).
Biped slots are specified by slot index (Biped Slots list in the Creation Kit).

```
filterByBipedSlots=33,34
```

### filterByBipedSlotsOr
Value: slot numbers, comma-separated — at least one listed biped slot must be present (OR).

```
filterByBipedSlotsOr=33,34,35
```

### filterByBipedSlotsExcluded
Value: slot numbers, comma-separated — exclude armor using any listed biped slot.

```
filterByBipedSlotsExcluded=30,31
```

### filterByModNames
Value: plugin names, comma-separated — only patch armor records originating from the listed
plugins.

```
filterByModNames=Fallout4.esm,MyMod.esp
```

## Operations

### damageResist
Value: number — set the base armor rating.

```
filterByArmors=Fallout4.esm|0001EED7:damageResist=99
```

### damageResistToAdd
Value: number — add to the current armor rating.

```
filterByArmors=Fallout4.esm|0001EED7:damageResistToAdd=20
```

### damageResistMult
Value: number — multiply the current armor rating.

```
filterByArmors=Fallout4.esm|0001EED7:damageResistMult=1.25
```

### health
Value: number — set armor health/durability.

```
filterByArmors=Fallout4.esm|0001EED7:health=500
```

### healthMult
Value: number — multiply the current armor health.

```
filterByArmors=Fallout4.esm|0001EED7:healthMult=1.5
```

### weight
Value: number — set armor weight.

```
filterByArmors=Fallout4.esm|0001EED7:weight=10.0
```

### weightMult
Value: number — multiply the current armor weight.

```
filterByArmors=Fallout4.esm|0001EED7:weightMult=0.75
```

### objectEffect
Value: ENCH form or `null` — set or clear the armor object effect.

```
filterByArmors=Fallout4.esm|0001EED7:objectEffect=Fallout4.esm|002483DA
filterByArmors=Fallout4.esm|0001EED7:objectEffect=null
```

### keywordsToAdd / keywordsToRemove
Value: KYWD forms, comma-separated — add/remove normal armor keywords. Does not modify
Attach Parent Slot keywords.

```
filterByArmors=Fallout4.esm|0001EED7:keywordsToAdd=Fallout4.esm|0004A0E8,MyMod.esp|00000801
filterByArmors=Fallout4.esm|0001EED7:keywordsToRemove=Fallout4.esm|0004A0E8
```

### attachParentSlotKeywordsToAdd / attachParentSlotKeywordsToRemove
Value: KYWD forms, comma-separated — add/remove Attach Parent Slot keywords.

```
filterByArmors=Fallout4.esm|0001EED7:attachParentSlotKeywordsToAdd=MyMod.esp|00000810
filterByArmors=Fallout4.esm|0001EED7:attachParentSlotKeywordsToRemove=MyMod.esp|00000810
```

### bipedSlotsToAdd / bipedSlotsToRemove
Value: slot numbers, comma-separated — add/remove biped slots by slot index.

```
filterByArmors=Fallout4.esm|0001EED7:bipedSlotsToAdd=33,34
filterByArmors=Fallout4.esm|0001EED7:bipedSlotsToRemove=33,34
```

### changeDamageTypes
Value: `DMGT=Value` or `DMGT=Min~Max` — add or change armor damage-type resistance values.
Multiple entries are comma-separated. A single value sets an exact amount; a range chooses a
random value between Min and Max.

```
filterByArmors=Fallout4.esm|0001EED7:changeDamageTypes=Fallout4.esm|00060A81=25
filterByArmors=Fallout4.esm|0001EED7:changeDamageTypes=Fallout4.esm|00060A81=20~30
filterByArmors=Fallout4.esm|0001EED7:changeDamageTypes=Fallout4.esm|00060A81=25,MyMod.esp|00000820=15
```

### changeDamageTypesByMult
Value: `DMGT=Multiplier` or `DMGT=Min~Max` — multiply existing matching damage-type values.
A range chooses a random multiplier.

```
filterByArmors=Fallout4.esm|0001EED7:changeDamageTypesByMult=Fallout4.esm|00060A81=1.5
filterByArmors=Fallout4.esm|0001EED7:changeDamageTypesByMult=Fallout4.esm|00060A81=1.1~1.5
```

### instanceNamingRule
Value: INNR form or `null` — set or clear the Instance Naming Rules record.

```
filterByArmors=Fallout4.esm|0001EED7:instanceNamingRule=MyMod.esp|00000830
filterByArmors=Fallout4.esm|0001EED7:instanceNamingRule=null
```

### fullName
Value: `~text~` — change the displayed armor name.

```
filterByArmors=Fallout4.esm|0001EED7:fullName=~Hellbender 5000 Armor~
```

## Example strings

```
// Improve armor and reduce weight
filterByArmors=MyMod.esp|00000800:damageResistToAdd=20:weightMult=0.75

// Multiply armor rating and health
filterByArmors=MyMod.esp|00000800:damageResistMult=1.25:healthMult=1.5

// Patch armor by keyword
filterByKeywords=Fallout4.esm|0004A0E8:damageResistToAdd=15

// Patch armor using specific biped slots
filterByBipedSlotsOr=33,34:weightMult=0.8

// Set physical resistance
filterByArmors=Fallout4.esm|0001EED7:changeDamageTypes=Fallout4.esm|00060A81=25

// Multiply an existing damage resistance
filterByArmors=Fallout4.esm|0001EED7:changeDamageTypesByMult=Fallout4.esm|00060A81=1.5

// Add normal and Attach Parent Slot keywords
filterByArmors=Fallout4.esm|0001EED7:keywordsToAdd=MyMod.esp|00000801:attachParentSlotKeywordsToAdd=MyMod.esp|00000810

// Change armor slots
filterByArmors=Fallout4.esm|0001EED7:bipedSlotsToRemove=33:bipedSlotsToAdd=34

// Assign an object effect
filterByArmors=Fallout4.esm|0001EED7:objectEffect=Fallout4.esm|002483DA

// Patch all armor from a plugin
filterByModNames=MyMod.esp:damageResistMult=1.10:weightMult=0.90
```

## Notes

- `filterByArmors`, keyword filters and biped-slot filters are independent filter groups.
- Use `keywordsToAdd` for normal armor keywords and `attachParentSlotKeywordsToAdd` for APPR
  keywords.
- Biped slots are specified by slot index.
- Changes to armor records are also applied to attached ARMA records where supported.
- Multiplier operations modify the current value; other numeric operations replace the value
  or add to it as stated.
- Use `null` only for operations that explicitly support clearing a form.
