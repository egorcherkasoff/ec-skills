# Weapons (WEAP)

- Setting: `iEnableWeaponPatching=1` in `Data/F4SE/Plugins/RobCo_Patcher.ini`
- Folder: `Data/F4SE/Plugins/RobCo_Patcher/weapon/`

Important: weapon, ammo, keyword, flag and exclusion filters are evaluated independently.
A failed individual operation is logged and does not cancel the remaining operations.

## Filters

### filterByWeapons
Value: WEAP forms, comma-separated — select specific weapons.

```
filterByWeapons=Fallout4.esm|00004822,Fallout4.esm|00092217
```

### filterByWeaponsExcluded
Value: WEAP forms, comma-separated — exclude specific weapons.

```
filterByWeaponsExcluded=Fallout4.esm|00004822
```

### filterByAmmos
Value: AMMO forms, comma-separated — match weapons that use one of the listed ammunition
records.

```
filterByAmmos=Fallout4.esm|0001F276,Fallout4.esm|0009221C
```

### filterByKeywords
Value: KYWD forms, comma-separated — all listed keywords must be present (AND).

```
filterByKeywords=Fallout4.esm|00092A86,Fallout4.esm|0004A0A0
```

Matches weapons containing both WeaponTypeBallistic and WeaponTypePistol.

### filterByKeywordsOr
Value: KYWD forms, comma-separated — at least one listed keyword must be present (OR).

```
filterByKeywordsOr=Fallout4.esm|0004A0A0,Fallout4.esm|0004A0A1
```

### filterByKeywordsExcluded
Value: KYWD forms, comma-separated — exclude weapons containing any listed keyword.

```
filterByKeywordsExcluded=Fallout4.esm|0004A0A3
```

### filterByFlagsExcluded
Value: flag names, comma-separated — exclude weapons carrying any listed weapon flag.

```
filterByFlagsExcluded=automatic,nonPlayable
```

### filterByHasAmmoFromWeaponList
Value: `pistol` or `rifle` — use the ammo groups populated by the ammo patcher
(`ammoCategory`, see `ammo.md`).

```
filterByHasAmmoFromWeaponList=pistol
filterByHasAmmoFromWeaponList=rifle
```

### filterByModNames
Value: plugin names, comma-separated — only patch records originating from the listed plugins.

```
filterByModNames=Fallout4.esm,MyWeaponMod.esp
```

## Operations

### fullName
Value: `~text~` — change the displayed name.

```
filterByWeapons=Fallout4.esm|00004822:fullName=~Hellbender 5000~
```

### attackDamage
Value: 0 to 65535 — set base attack damage.

```
filterByWeapons=Fallout4.esm|00004822:attackDamage=33
```

### attackDamageToAdd
Value: number — add to the current base attack damage.

```
filterByWeapons=Fallout4.esm|00004822:attackDamageToAdd=10
```

### attackDamageMult
Value: number — multiply the current base attack damage.

```
filterByWeapons=Fallout4.esm|00004822:attackDamageMult=1.25
```

### bashDamage
Value: number — set secondary/bash damage.

```
filterByWeapons=Fallout4.esm|00004822:bashDamage=40
```

### weight
Value: number — set weapon weight.

```
filterByWeapons=Fallout4.esm|00004822:weight=3.5
```

### value
Value: 0 to 4294967295 — set caps value.

```
filterByWeapons=Fallout4.esm|00004822:value=250
```

### minRange
Value: number — set minimum range.

```
filterByWeapons=Fallout4.esm|00004822:minRange=256
```

### maxRange
Value: number — set maximum range.

```
filterByWeapons=Fallout4.esm|00004822:maxRange=4096
```

### outOfRangeDamageMult
Value: number — set the damage multiplier outside the effective range.

```
filterByWeapons=Fallout4.esm|00004822:outOfRangeDamageMult=0.5
```

### attackActionPointCost
Value: number — set VATS action-point cost.

```
filterByWeapons=Fallout4.esm|00004822:attackActionPointCost=20
```

### weaponHitType
Value: `normal`, `dismember`, `explode`, or `no` — set hit behavior. Long forms
`dismemberOnly`, `explodeOnly` and `noDismemberOrExplode` are also accepted.

```
weaponHitType=normal
weaponHitType=dismember
weaponHitType=explode
weaponHitType=no
```

### soundLevel
Value: `loud`, `normal`, `silent`, `veryLoud`, or `quiet` — set the weapon sound level.

```
soundLevel=loud
soundLevel=normal
soundLevel=silent
soundLevel=veryLoud
soundLevel=quiet
```

### coneIronSightsMultiplier
Value: number — set the iron-sight cone multiplier on the weapon's assigned AimModel.

```
filterByWeapons=Fallout4.esm|00004822:coneIronSightsMultiplier=0.75
```

### recoilDiminishSpringForce
Value: number — set recoil spring force on the assigned AimModel.

```
filterByWeapons=Fallout4.esm|00004822:recoilDiminishSpringForce=12.0
```

### recoilPerShotMin
Value: number — set minimum recoil per shot on the AimModel.

```
filterByWeapons=Fallout4.esm|00004822:recoilPerShotMin=1.5
```

### recoilPerShotMax
Value: number — set maximum recoil per shot on the AimModel.

```
filterByWeapons=Fallout4.esm|00004822:recoilPerShotMax=3.0
```

### keywordsToAdd / keywordsToRemove
Value: KYWD forms, comma-separated — add/remove normal weapon keywords.

```
filterByWeapons=Fallout4.esm|00004822:keywordsToAdd=Fallout4.esm|00092A86,Fallout4.esm|0004A0A0
filterByWeapons=Fallout4.esm|00004822:keywordsToRemove=Fallout4.esm|0004A0A0
```

### attachParentSlotKeywordsToAdd / attachParentSlotKeywordsToRemove
Value: KYWD forms, comma-separated — add/remove Attach Parent Slot keywords.

```
filterByWeapons=Fallout4.esm|00004822:attachParentSlotKeywordsToAdd=MyMod.esp|00000800
filterByWeapons=Fallout4.esm|00004822:attachParentSlotKeywordsToRemove=MyMod.esp|00000800
```

### setNewAmmo
Value: AMMO form — set weapon ammunition.

```
filterByWeapons=Fallout4.esm|00004822:setNewAmmo=Fallout4.esm|0001F66B
```

### setNewAmmoList
Value: LVLI form — set the NPC Add Ammo List used when NPCs receive the weapon.

```
filterByWeapons=Fallout4.esm|00004822:setNewAmmoList=Fallout4.esm|000FF424
```

### aimModel
Value: AMDL form — assign a new AimModel.

```
filterByWeapons=Fallout4.esm|00004822:aimModel=MyMod.esp|00000810
```

### overrideProjectile
Value: PROJ form or `null` — set or clear the ranged override projectile. Requires ranged
weapon data.

```
filterByWeapons=Fallout4.esm|00004822:overrideProjectile=Fallout4.esm|000CABA4
filterByWeapons=Fallout4.esm|00004822:overrideProjectile=null
```

### changeDamageTypes
Value: `DMGT=Value` or `DMGT=Min~Max` — add or change damage-type values. Multiple entries are
comma-separated. A single value sets an exact amount; a range chooses a random value between
Min and Max.

```
changeDamageTypes=Fallout4.esm|00060A81=25
changeDamageTypes=Fallout4.esm|00060A81=20~30
```

### damageTypesToChange
Value: same format as `changeDamageTypes` — alternative parser key.

```
filterByWeapons=Fallout4.esm|00004822:damageTypesToChange=Fallout4.esm|00060A81=25
```

### damageTypesToRemove
Value: DMGT forms, comma-separated — remove damage types.

```
filterByWeapons=Fallout4.esm|00004822:damageTypesToRemove=Fallout4.esm|00060A81
```

### instanceNamingRule
Value: INNR form or `null` — set or clear Instance Naming Rules.

```
filterByWeapons=Fallout4.esm|00004822:instanceNamingRule=MyMod.esp|00000820
filterByWeapons=Fallout4.esm|00004822:instanceNamingRule=null
```

## Example strings

```
// Increase weapon damage
filterByWeapons=Fallout4.esm|00004822:attackDamageToAdd=10:attackDamageMult=1.25

// Change ammunition and NPC ammo list
filterByWeapons=Fallout4.esm|00004822:setNewAmmo=Fallout4.esm|0001F66B:setNewAmmoList=Fallout4.esm|000FF424

// Patch ballistic pistols
filterByKeywords=Fallout4.esm|00092A86,Fallout4.esm|0004A0A0:attackDamage=50

// Patch multiple weapons
filterByWeapons=Fallout4.esm|00004822,Fallout4.esm|00092217:attackDamage=33:bashDamage=40

// Patch all weapons using a specific ammo
filterByAmmos=Fallout4.esm|0001F276:attackDamageMult=1.10

// Add weapon keywords
filterByWeapons=Fallout4.esm|00004822:keywordsToAdd=Fallout4.esm|00092A86,Fallout4.esm|0004A0A0

// Change projectile
filterByWeapons=Fallout4.esm|00004822:overrideProjectile=Fallout4.esm|000CABA4

// Add physical damage
filterByWeapons=Fallout4.esm|00004822:changeDamageTypes=Fallout4.esm|00060A81=25
```

## Notes

- AimModel operations require the weapon to have an AimModel. Missing AimModel data is logged.
- `filterByHasAmmoFromWeaponList` only matches weapons whose ammo received an `ammoCategory`
  from the ammo patcher; add those ammo rules as well when using this filter.
- Use `keywordsToAdd` for normal keywords and `attachParentSlotKeywordsToAdd` for APPR keywords.
- `overrideProjectile` requires ranged weapon data.
- `changeDamageTypes` and `damageTypesToChange` use the same damage-type value format.
- Use `null` only for operations that explicitly support clearing a form.
