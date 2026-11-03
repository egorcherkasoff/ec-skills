# Object Modifications (OMOD)

- Setting: `iEnableObjectModificationPatching=1` in `Data/F4SE/Plugins/RobCo_Patcher.ini`
- Folder: `Data/F4SE/Plugins/RobCo_Patcher/objectModification/`

Important: OMOD property layouts depend on property and function types. Use property
operations only with values verified for the target OMOD. Property names are not
case-sensitive.

## Property data layouts

OMOD properties use different data layouts. The correct operation depends on the property
type being modified:

| Layout | Change operation | Description |
|---|---|---|
| Float | `changeOModPropertiesFloat` | plain float value |
| FormID, Float | `changeOModPropertiesVP` | value pair {FormID, Float} |
| FormID, Int | `changeOModPropertiesForm` | form-valued {FormID, Int} |

Using the wrong operation for a property type may produce incorrect results. Property names,
encodings and function types must match the target OMOD. `changeOModProperties*` only changes
properties that already exist; use `oModPropertiesToAdd` to create a new property definition.

## Filters

### filterByOMod
Value: OMOD forms, comma-separated — select specific OMOD records.

```
filterByOMod=Fallout4.esm|000D2A94
```

### filterByOModExcluded
Value: OMOD forms, comma-separated — exclude specific OMOD records.

```
filterByOModExcluded=Fallout4.esm|000D2A94,Fallout4.esm|000D2A95
```

### filterConnection
Value: connection values — filter by connection.

### filterByFormType
Value: form-type value — filter OMODs by their target form type.

```
filterByFormType=weapon
```

### filterByForms
Value: forms, comma-separated — filter referenced forms.

### filterByPropertiesAnd
Value: property identifiers, comma-separated — all listed properties must be present (AND).

```
filterByPropertiesAnd=attackDamage,weight:changeOModPropertiesFloat=value=0.5
```

### filterByPropertiesOr
Value: property identifiers, comma-separated — at least one listed property must be present
(OR).

```
filterByPropertiesOr=attackDamage,weight:changeOModPropertiesFloat=value=0.5
```

### filterByPropertiesExclude
Value: property identifiers, comma-separated — exclude OMODs containing listed properties.

```
filterByPropertiesExclude=weight:filterByNameContainsOr=Heavy:changeOModPropertiesFloat=attackDamage=0.10
```

### filterByNameContainsAnd
Value: text, comma-separated — the name must contain every listed fragment (AND).

```
filterByNameContainsAnd=Automatic,Receiver:changeOModPropertiesFloat=attackDamage=0
```

### filterByNameContainsOr
Value: text, comma-separated — the name must contain at least one listed fragment (OR).

```
filterByNameContainsAnd=Receiver:filterByNameContainsOr=Mechani,Machining:changeOModPropertiesFloat=attackDamage=0.25
```

### filterByNameContainsExclude
Value: text, comma-separated — exclude names containing any listed fragment.

```
filterByNameContainsAnd=Receiver:filterByNameContainsOr=Heavy:filterByNameContainsExclude=Automatic:changeOModPropertiesFloat=attackDamage=0.10
```

### filterByAttachPoint
Value: KYWD forms, comma-separated — filter by attach point.

```
filterByAttachPoint=Fallout4.esm|0002249D
```

## Operations

### oModPropertiesToAdd
Value: `Property~Type~Operation~Value[~SecondValue]` — adds a new property definition to an
OMOD record.

- **Property** — property identifier, for example `attackDamage` or `ammo`.
- **Type** — `float`, `int`, `bool`, `enum`, `form`, `form,int` or `pair`.
- **Operation** — `set`, `add`, `mul` or `remove`.
- **Value** — numeric value or form identifier, depending on the selected type.
  `form,int` and `pair` require a second value.
- The value after `remove` is required by the syntax but ignored.

```
// Float
filterByOMod=Fallout4.esm|000D2A94:oModPropertiesToAdd=speed~float~set~1.25
// Integer
filterByOMod=Fallout4.esm|000D2A94:oModPropertiesToAdd=attackDamage~int~set~999
// Boolean
filterByOMod=Fallout4.esm|000D2A94:oModPropertiesToAdd=automatic~bool~set~1
// Enum
filterByOMod=Fallout4.esm|000D2A94:oModPropertiesToAdd=hitBehavior~enum~set~2
// FormID, Int
filterByOMod=Fallout4.esm|000D2A94:oModPropertiesToAdd=ammo~form~set~Fallout4.esm|0001F276~0
// FormID, Float pair
filterByOMod=Fallout4.esm|000D2A94:oModPropertiesToAdd=damageTypeValues~pair~set~Fallout4.esm|0001F276~25.0
// Set / Add / Multiply / Remove
filterByOMod=Fallout4.esm|000D2A94:oModPropertiesToAdd=attackDamage~int~set~25
filterByOMod=Fallout4.esm|000D2A94:oModPropertiesToAdd=attackDamage~int~add~10
filterByOMod=Fallout4.esm|000D2A94:oModPropertiesToAdd=attackDamage~float~mul~2
filterByOMod=Fallout4.esm|000D2A94:oModPropertiesToAdd=attackDamage~int~remove~0
```

The docs show both `form` and `form,int` as the type spelling for FormID+Int properties:

```
filterByOMod=Fallout4.esm|000D2A94:oModPropertiesToAdd=ammo~form,int~set~Fallout4.esm|0001F276~0
```

### changeOModPropertiesFloat
Value: `Property=Float` (multiple entries comma-separated) — change float property values.

```
filterByNameContainsAnd=Automatic,Receiver:changeOModPropertiesFloat=attackDamage=0,weight=0.25,value=0.5
```

### changeOModPropertiesVP
Value: `Form=Value` — change a value-pair property of type {FormID, Float}.

```
filterByNameContainsAnd=Automatic,Receiver:changeOModPropertiesVP=Fallout4.esm|00060A81=15.5
```

### changeOModPropertiesForm
Value: `OldForm=NewForm` — change a form-valued property of type {FormID, Int}.

```
filterByNameContainsAnd=Automatic,Receiver:changeOModPropertiesForm=Fallout4.esm|000D70BB=Fallout4.esm|002377D4
```

### removeOModProperties
Value: property identifiers, comma-separated — remove matching properties by property name.

```
filterByNameContainsAnd=Automatic,Receiver:removeOModProperties=attackDamage,weight,value,keywords
```

### removeOModPropertiesForm
Value: forms, comma-separated — remove form-valued properties matching the listed forms.

```
filterByNameContainsAnd=Automatic,Receiver:removeOModPropertiesForm=Fallout4.esm|000D70BB
```

### removeOModPropertiesVP
Value: forms, comma-separated — remove value-pair properties matching the listed forms.

```
filterByNameContainsAnd=Automatic,Receiver:removeOModPropertiesVP=Fallout4.esm|00060A81
```

### changeOModFunctionType
Value: function-type definition — change the function type of an OMOD property.

```
filterByOMod=Fallout4.esm|000D2A94:changeOModFunctionType=weight=add
filterByOMod=Fallout4.esm|000D2A94:changeOModFunctionType=weight=multandadd
filterByOMod=Fallout4.esm|000D2A94:changeOModFunctionType=weight=set
```

The `rem` function type is also supported, but `removeOModProperties` should normally be used
when removing properties:

```
filterByOMod=Fallout4.esm|000D2A94:changeOModFunctionType=keywords=rem
```

### attachParentSlotKeywordsToAdd / attachParentSlotKeywordsToRemove
Value: KYWD forms, comma-separated — add/remove Attach Parent Slot keywords.

```
filterByOMod=MyMod.esp|00000800:attachParentSlotKeywordsToAdd=Fallout4.esm|0012AFC3
filterByOMod=MyMod.esp|00000800:attachParentSlotKeywordsToRemove=Fallout4.esm|0012AFC3
```

### setAttachPoint
Value: KYWD form or `null` — set or clear the attach point.

```
filterByOMod=MyMod.esp|00000800:setAttachPoint=Fallout4.esm|0012AFC3
filterByOMod=MyMod.esp|00000800:setAttachPoint=null
```

### targetKeywordsToAdd / targetKeywordsToRemove
Value: KYWD forms, comma-separated — add/remove target keywords.

```
filterByOMod=MyMod.esp|00000800:targetKeywordsToAdd=Fallout4.esm|0012AFC3
filterByOMod=MyMod.esp|00000800:targetKeywordsToRemove=Fallout4.esm|0012AFC3
```

### fullName
Value: `~text~` — change the displayed name.

```
filterByOMod=MyMod.esp|00000800:fullName=~Hellbender 5000 Receiver~
```

## Native OMOD property reference

Property names are not case-sensitive.

### Type rules

- `float` — decimal value, for example `1.5`.
- `int` — whole-number value, for example `25`.
- `bool` — `0` or `1`.
- `enum` — numeric enumeration value.
- `form` — a plugin and FormID, for example `Fallout4.esm|0001F276`.
- `form,int` — Bethesda FormID/Int property. The integer is required by the syntax; the
  runtime form value is resolved from the FormID.
- `pair` — Bethesda FormID/Float property.

Operations: `set`, `add`, `mul`/`multiply`, `rem`/`remove`.

### Important property rules

- `keywords` and `enchantments` use `add` or `remove`. Do not use `set`.
- `ammo` and `NPCAddAmmoList` use `form` or `form,int` with `set`.
- `damageTypes`, `damageTypeValues`, and `actorValues` use `pair`.
- The value after `remove` is required by the syntax but is ignored.
- `keywords`, `ammo`, `enchantments` and `NPCAddAmmoList` use the form,int layout.
  `damageTypes` and `actorValues` use the pair layout.

### WEAP properties

Float:
`attackDamage`, `value`, `weight`, `speed`, `reach`, `minRange`, `maxRange`,
`attackDelaySec`, `outOfRangeDamageMult`, `secondaryDamage`, `criticalChargeBonus`,
`aimModelMinConeDegrees`, `aimModelMaxConeDegrees`, `aimModelConeIncreasePerShot`,
`aimModelConeDecreasePerSec`, `aimModelConeSneakMultiplier`,
`aimModelRecoilDiminishSpringForce`, `aimModelRecoilDiminishSightsMult`,
`aimModelRecoilMaxDegPerShot`, `aimModelRecoilMinDegPerShot`, `aimModelRecoilHipMult`,
`aimModelRecoilArcDeg`, `aimModelRecoilArcRotateDeg`, `aimModelConeIronSightsMultiplier`,
`fOVMult`, `fireSeconds`, `aimModelBaseStability`, `soundLevelMult`, `reloadSpeed`,
`attackActionPointCost`, `sightedTransitionSeconds`, `fullPowerSeconds`, `minPowerPerShot`,
`colorRemappingIndex`, `criticalDamageMult`

Integer:
`rank`, `ammoCapacity`, `numProjectiles`, `accuracyBonus`,
`aimModelConeDecreaseDelayMs`, `aimModelRecoilShotsForRunaway`

Boolean:
`playerOnly`, `NPCUseAmmo`, `charge`, `crime`, `fixedRange`, `effectOnDeath`,
`alternateRumble`, `nonHostile`, `ignoreResist`, `automatic`, `cantDrop`, `nonPlayable`,
`hasScope`, `boltAction`, `holdInputToPower`, `repeatableSingleFire`, `disableShells`,
`chargeAttack`

Enum:
`hitBehavior`, `type`, `soundLevel`, `staggerValue`

Form:
`attackSound`, `attackSound2D`, `attackLoop`, `attackFailSound`, `idleSound`,
`equipSound`, `unEquipSound`, `impactDataSet`, `effect`, `equipSlot`, `fastEquipSound`

Form/Int:
`keywords`, `ammo`, `enchantments`, `NPCAddAmmoList`,
`rangedOverrideProjectile` / `overrideProjectile`

Form/Float pair:
`damageTypes`, `damageTypeValues`, `actorValues`

Not currently supported (not valid for the type field, cannot be created with
`oModPropertiesToAdd`):
`aimModel` (use the individually listed `aimModel*` fields instead),
`blockBashImpactData`, `blockBashMaterial`, `zoomData`, `zoomOverlay`, `zoomIS`,
`cameraOffsetX`, `cameraOffsetY`, `cameraOffsetZ`, `materialSwaps`,
`forcedInventory` and `sXPOffset` (NPC)

### ARMO properties

- Float: `weight`, `colorRemappingIndex`
- Integer: `value`, `rating`, `index`, `health`
- Form/Int: `keywords`
- Form/Float pair: `damageTypes`, `damageTypeValues`, `actorValues`
- Not generically addable: `blockBashImpactData`, `blockBashMaterial`, `materialSwaps`

### NPC properties

- Float: `colorRemappingIndex`
- Form/Int: `enchantments`
- Not generically addable: `forcedInventory`, `sXPOffset`, `materialSwaps`

### More examples

```
// Form
filterByOMod=Fallout4.esm|000D2A94:oModPropertiesToAdd=effect~form~set~Fallout4.esm|0001F276
// Form/Float pair with add
filterByOMod=Fallout4.esm|000D2A94:oModPropertiesToAdd=damageTypeValues~pair~add~Fallout4.esm|00060A81~25.0
// Remove
filterByOMod=Fallout4.esm|000D2A94:oModPropertiesToAdd=weight~float~remove~0
```

Form references always use the plugin name and FormID together, for example
`MyMod.esp|00123456`.
