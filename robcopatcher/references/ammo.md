# Ammo (AMMO)

- Setting: `iEnableAmmoPatching=1` in `Data/F4SE/Plugins/RobCo_Patcher.ini`
- Folder: `Data/F4SE/Plugins/RobCo_Patcher/ammo/`

Important: name filters inspect the displayed ammunition name. `ammoCategory` groups
ammunition for use by `filterByHasAmmoFromWeaponList` in the weapon patcher.

## Filters

### filterByAmmos
Value: AMMO forms, comma-separated — select specific ammunition records.

```
filterByAmmos=Fallout4.esm|0001F276,Fallout4.esm|0004CE87
```

### filterByNameContainsAnd
Value: text, comma-separated — the displayed name must contain every listed fragment (AND).

```
filterByNameContainsAnd=Fusion,Cell
```

### filterByNameContainsOr
Value: text, comma-separated — the displayed name must contain at least one listed fragment
(OR).

```
filterByNameContainsOr=Round,Cell,Cartridge
```

### filterByNameContainsExclude
Value: text, comma-separated — exclude ammunition whose displayed name contains any listed
fragment.

```
filterByNameContainsExclude=Explosive,Incendiary
```

### filterByWeightLessThan
Value: number — only match ammunition with a weight below the specified value.

```
filterByWeightLessThan=1:weight=0
```

### filterByModNames
Value: plugin names, comma-separated — only patch ammunition records originating from the
listed plugins.

```
filterByModNames=Fallout4.esm,MyAmmoMod.esp
```

## Operations

### ammoCategory
Value: `pistol` or `rifle` — assign the ammunition to one of the ammo groups used by the
weapon patcher (`filterByHasAmmoFromWeaponList`).

```
filterByAmmos=Fallout4.esm|0001F276:ammoCategory=pistol
filterByAmmos=Fallout4.esm|0001F66B:ammoCategory=rifle
```

### attackDamage
Value: number — set the damage added by the ammunition to the weapon's base damage.

For example, if a weapon has 20 base damage and its ammunition adds 20 damage, the final
weapon damage is 40 before other modifiers.

```
filterByAmmos=Fallout4.esm|0001F276:attackDamage=38
```

### attackDamageToAdd
Value: number — add the specified value to the current ammunition damage.

```
filterByAmmos=Fallout4.esm|0001F276:attackDamageToAdd=5
```

### attackDamageMult
Value: number — multiply the current ammunition damage.

```
filterByAmmos=Fallout4.esm|0001F276:attackDamageMult=1.25
```

### weight
Value: number — set ammunition weight.

```
filterByAmmos=Fallout4.esm|0001F276:weight=0.025
```

### value
Value: number — set the caps value.

```
filterByAmmos=Fallout4.esm|0001F276:value=3
```

### valueMult
Value: number — multiply the current caps value.

```
filterByAmmos=Fallout4.esm|0001F276:valueMult=1.5
```

### setNewProjectile
Value: PROJ form — set the projectile used by the ammunition.

```
filterByAmmos=MyAmmoMod.esp|00000800:setNewProjectile=MyAmmoMod.esp|00000801
```

### addToFormList
Value: FLST form — add the ammunition to one FormList.

This operation accepts one FormList per patch rule. Use additional rules to add the same
ammunition to multiple FormLists.

```
filterByAmmos=Fallout4.esm|0001F276:addToFormList=MyMod.esp|00000810
filterByAmmos=Fallout4.esm|0001F276:addToFormList=MyMod.esp|00000811
```

### keywordsToAdd
Value: KYWD forms, comma-separated — add normal keywords to the ammunition record.

```
filterByAmmos=Fallout4.esm|0001F276:keywordsToAdd=MyMod.esp|00000820,MyMod.esp|00000821
```

### fullName
Value: `~text~` — change the displayed ammunition name.

```
filterByAmmos=Fallout4.esm|0001F276:fullName=~Hellbender 5000 Rounds~
```

## Example strings

```
// Configure 10mm ammunition
filterByAmmos=Fallout4.esm|0001F276:ammoCategory=pistol:attackDamage=38

// Configure .38 ammunition
filterByAmmos=Fallout4.esm|0004CE87:ammoCategory=pistol:attackDamage=36

// Configure .44 ammunition
filterByAmmos=Fallout4.esm|0009221C:ammoCategory=pistol:attackDamage=59

// Configure .45 ammunition
filterByAmmos=Fallout4.esm|0001F66A:ammoCategory=pistol:attackDamage=40

// Increase damage and value
filterByAmmos=Fallout4.esm|0001F66B:attackDamageToAdd=5:valueMult=1.5

// Change projectile
filterByAmmos=MyAmmoMod.esp|00000800:setNewProjectile=MyAmmoMod.esp|00000801

// Remove weight from lightweight ammunition
filterByWeightLessThan=1:weight=0

// Patch ammunition by displayed name
filterByNameContainsOr=Round,Cartridge:valueMult=1.25

// Add ammunition to a FormList
filterByAmmos=Fallout4.esm|0001F276:addToFormList=MyMod.esp|00000810

// Patch all ammunition from a plugin
filterByModNames=MyAmmoMod.esp:attackDamageMult=1.10:valueMult=1.25
```

## Notes

- `ammoCategory` supports `pistol` and `rifle`.
- The ammo groups are used by `filterByHasAmmoFromWeaponList` in the weapon patcher.
- `attackDamage` is added to the weapon's base damage by the game.
- `addToFormList` accepts one FormList per patch rule; use multiple rules for multiple lists.
- Multiple operations may be combined on the same line.
