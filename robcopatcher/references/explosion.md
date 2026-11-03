# Explosions (EXPL)

- Setting: `iEnableExplosionPatching=1` in `Data/F4SE/Plugins/RobCo_Patcher.ini`
- Folder: `Data/F4SE/Plugins/RobCo_Patcher/explosion/`

Important: form operations accept `null` only where explicitly stated. Invalid numeric
values or forms are logged and skipped individually.

## Filters

### filterByExplosions
Value: EXPL forms, comma-separated — select specific explosion records.

```
filterByExplosions=Fallout4.esm|00000800,MyMod.esp|00000801
```

### filterByModNames
Value: plugin names, comma-separated — only patch explosion records originating from the
listed plugins.

```
filterByModNames=Fallout4.esm,MyMod.esp
```

## Operations

### Numeric setters

| Operation | Value | Meaning |
|---|---|---|
| `projectileSpread` | number | spread applied to spawned projectiles |
| `projectileCount` | integer | number of projectiles spawned by the explosion |
| `force` | number | explosion force |
| `damage` | number | explosion damage |
| `innerRadius` | number | inner explosion radius |
| `outerRadius` | number | outer explosion radius |
| `imageSpaceRadius` | number | radius used for image-space effects |
| `verticalOffsetMult` | number | vertical offset multiplier |
| `placedObjectFadeDelay` | number | delay before the placed impact object fades |
| `soundLevel` | integer | numeric explosion sound level |
| `staggerMagnitude` | integer | explosion stagger magnitude |
| `projectileVectorX` | number | X component of the spawned projectile vector |
| `projectileVectorY` | number | Y component of the spawned projectile vector |
| `projectileVectorZ` | number | Z component of the spawned projectile vector |

```
filterByExplosions=MyMod.esp|00000800:projectileSpread=15.0
filterByExplosions=MyMod.esp|00000800:projectileCount=8
filterByExplosions=MyMod.esp|00000800:force=500
filterByExplosions=MyMod.esp|00000800:damage=150
filterByExplosions=MyMod.esp|00000800:innerRadius=128
filterByExplosions=MyMod.esp|00000800:outerRadius=500
filterByExplosions=MyMod.esp|00000800:imageSpaceRadius=600
filterByExplosions=MyMod.esp|00000800:verticalOffsetMult=1.0
filterByExplosions=MyMod.esp|00000800:placedObjectFadeDelay=5.0
filterByExplosions=MyMod.esp|00000800:soundLevel=2
filterByExplosions=MyMod.esp|00000800:staggerMagnitude=3
filterByExplosions=MyMod.esp|00000800:projectileVectorX=0.0
filterByExplosions=MyMod.esp|00000800:projectileVectorY=0.0
filterByExplosions=MyMod.esp|00000800:projectileVectorZ=1.0
```

### Add / multiply variants

```
filterByExplosions=MyMod.esp|00000800:forceMult=1.5
filterByExplosions=MyMod.esp|00000800:damageToAdd=50
filterByExplosions=MyMod.esp|00000800:damageMult=1.25
```

### Form operations (accept `null` to clear)

| Operation | Value |
|---|---|
| `light` | LIGH form or `null` |
| `sound1` | SNDR form or `null` |
| `sound2` | SNDR form or `null` |
| `impactDataSet` | IPDS form or `null` |
| `impactPlacedObject` | bound object form or `null` |
| `spawnProjectile` | PROJ form or `null` |

```
filterByExplosions=MyMod.esp|00000800:light=MyMod.esp|00000810
filterByExplosions=MyMod.esp|00000800:light=null
filterByExplosions=MyMod.esp|00000800:sound1=MyMod.esp|00000811
filterByExplosions=MyMod.esp|00000800:sound2=MyMod.esp|00000812
filterByExplosions=MyMod.esp|00000800:impactDataSet=MyMod.esp|00000813
filterByExplosions=MyMod.esp|00000800:impactPlacedObject=MyMod.esp|00000814
filterByExplosions=MyMod.esp|00000800:spawnProjectile=MyMod.esp|00000801
filterByExplosions=MyMod.esp|00000800:spawnProjectile=null
```

### fullName
Value: `~text~` — change the displayed explosion name.

```
filterByExplosions=MyMod.esp|00000800:fullName=~High-Impact Explosion~
```

## Example strings

```
// Increase damage and radius
filterByExplosions=MyMod.esp|00000800:damageToAdd=50:outerRadius=500

// Multiply damage and force
filterByExplosions=MyMod.esp|00000800:damageMult=1.5:forceMult=2.0

// Configure explosion radii
filterByExplosions=MyMod.esp|00000800:innerRadius=128:outerRadius=512:imageSpaceRadius=600

// Assign a spawned projectile
filterByExplosions=MyMod.esp|00000800:spawnProjectile=MyMod.esp|00000801

// Configure spawned projectiles
filterByExplosions=MyMod.esp|00000800:spawnProjectile=MyMod.esp|00000801:projectileCount=8:projectileSpread=25

// Launch projectiles upward
filterByExplosions=MyMod.esp|00000800:projectileVectorX=0:projectileVectorY=0:projectileVectorZ=1

// Change explosion presentation
filterByExplosions=MyMod.esp|00000800:light=MyMod.esp|00000810:sound1=MyMod.esp|00000811:sound2=MyMod.esp|00000812

// Configure impact effects
filterByExplosions=MyMod.esp|00000800:impactDataSet=MyMod.esp|00000813:impactPlacedObject=MyMod.esp|00000814:placedObjectFadeDelay=5.0

// Clear optional form data
filterByExplosions=MyMod.esp|00000800:light=null:sound2=null:spawnProjectile=null

// Patch all explosions from a plugin
filterByModNames=MyMod.esp:damageMult=1.25:forceMult=1.5
```

## Notes

- Invalid numeric values or forms are logged and skipped individually.
- Multiplier operations modify the current value; other numeric operations replace it or add
  to it as stated.
- `spawnProjectile` works together with `projectileCount`, `projectileSpread` and the
  projectile vector operations.
- Use `null` only for operations that explicitly support clearing a form.
- Some fields only have an effect when the explosion record uses the corresponding feature.
