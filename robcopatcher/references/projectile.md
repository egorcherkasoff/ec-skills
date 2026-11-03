# Projectiles (PROJ)

- Setting: `iEnableProjectilePatching=1` in `Data/F4SE/Plugins/RobCo_Patcher.ini`
- Folder: `Data/F4SE/Plugins/RobCo_Patcher/projectile/`

Important: form operations accept `null` only where explicitly stated. Invalid numeric
values or forms are logged and skipped individually.

## Filters

### filterByProjectiles
Value: PROJ forms, comma-separated — select specific projectile records.

```
filterByProjectiles=Fallout4.esm|000CABA4,MyMod.esp|00000800
```

### filterByModNames
Value: plugin names, comma-separated — only patch records originating from the listed plugins.

```
filterByModNames=Fallout4.esm,MyMod.esp
```

## Operations

### Numeric setters

| Operation | Value | Meaning |
|---|---|---|
| `gravity` | number | projectile gravity |
| `speed` | number | projectile speed |
| `range` | number | projectile range |
| `explosionProximity` | number | proximity distance used for projectile explosions |
| `explosionTimer` | number | projectile explosion timer |
| `muzzleFlashDuration` | number | muzzle-flash duration |
| `fadeOutTime` | number | projectile fade-out time |
| `force` | number | projectile impact force |
| `coneSpread` | number | projectile cone spread |
| `collisionRadius` | number | projectile collision radius |
| `lifetime` | number | projectile lifetime |
| `relaunchInterval` | number | projectile relaunch interval |
| `tracerFrequency` | integer | how frequently tracer effects are used |
| `soundLevel` | integer | numeric projectile sound level |

```
filterByProjectiles=MyMod.esp|00000800:gravity=0.5
filterByProjectiles=MyMod.esp|00000800:speed=5000
filterByProjectiles=MyMod.esp|00000800:range=10000
filterByProjectiles=MyMod.esp|00000800:explosionProximity=128
filterByProjectiles=MyMod.esp|00000800:explosionTimer=3.0
filterByProjectiles=MyMod.esp|00000800:muzzleFlashDuration=0.15
filterByProjectiles=MyMod.esp|00000800:fadeOutTime=2.0
filterByProjectiles=MyMod.esp|00000800:force=50
filterByProjectiles=MyMod.esp|00000800:coneSpread=1.5
filterByProjectiles=MyMod.esp|00000800:collisionRadius=4.0
filterByProjectiles=MyMod.esp|00000800:lifetime=10.0
filterByProjectiles=MyMod.esp|00000800:relaunchInterval=0.25
filterByProjectiles=MyMod.esp|00000800:tracerFrequency=3
filterByProjectiles=MyMod.esp|00000800:soundLevel=2
```

### Multiplier variants

```
filterByProjectiles=MyMod.esp|00000800:speedMult=1.25
filterByProjectiles=MyMod.esp|00000800:rangeMult=1.5
filterByProjectiles=MyMod.esp|00000800:forceMult=2.0
```

### Form operations (accept `null` to clear)

| Operation | Value |
|---|---|
| `explosionType` | EXPL form or `null` |
| `light` | LIGH form or `null` |
| `muzzleFlashLight` | LIGH form or `null` |
| `defaultWeaponSource` | WEAP form or `null` |
| `vatsProjectile` | PROJ form or `null` |
| `collisionLayer` | COLL form or `null` |
| `decalData` | TXST form or `null` |

```
filterByProjectiles=MyMod.esp|00000800:explosionType=MyMod.esp|00000801
filterByProjectiles=MyMod.esp|00000800:explosionType=null
filterByProjectiles=MyMod.esp|00000800:light=MyMod.esp|00000802
filterByProjectiles=MyMod.esp|00000800:light=null
filterByProjectiles=MyMod.esp|00000800:muzzleFlashLight=MyMod.esp|00000803
filterByProjectiles=MyMod.esp|00000800:muzzleFlashLight=null
filterByProjectiles=MyMod.esp|00000800:defaultWeaponSource=Fallout4.esm|00004822
filterByProjectiles=MyMod.esp|00000800:defaultWeaponSource=null
filterByProjectiles=MyMod.esp|00000800:vatsProjectile=MyMod.esp|00000804
filterByProjectiles=MyMod.esp|00000800:vatsProjectile=null
filterByProjectiles=MyMod.esp|00000800:collisionLayer=MyMod.esp|00000805
filterByProjectiles=MyMod.esp|00000800:collisionLayer=null
filterByProjectiles=MyMod.esp|00000800:decalData=MyMod.esp|00000806
filterByProjectiles=MyMod.esp|00000800:decalData=null
```

### fullName
Value: `~text~` — change the displayed projectile name.

```
filterByProjectiles=MyMod.esp|00000800:fullName=~High-Velocity Projectile~
```

## Example strings

```
// Increase speed and range
filterByProjectiles=MyMod.esp|00000800:speedMult=1.25:range=10000

// Increase speed, range and force
filterByProjectiles=MyMod.esp|00000800:speedMult=1.5:rangeMult=2.0:forceMult=1.5

// Assign an explosion
filterByProjectiles=MyMod.esp|00000800:explosionType=MyMod.esp|00000801

// Configure an explosive projectile
filterByProjectiles=MyMod.esp|00000800:explosionType=MyMod.esp|00000801:explosionProximity=128:explosionTimer=3.0

// Create a faster projectile with less gravity
filterByProjectiles=MyMod.esp|00000800:gravity=0.25:speedMult=2.0

// Change tracer behavior
filterByProjectiles=MyMod.esp|00000800:tracerFrequency=2:muzzleFlashDuration=0.10

// Clear explosion and light
filterByProjectiles=MyMod.esp|00000800:explosionType=null:light=null

// Patch all projectiles from a plugin
filterByModNames=MyMod.esp:speedMult=1.10:rangeMult=1.25
```

## Notes

- Invalid numeric values or forms are logged and skipped individually.
- Multipliers modify the current value; non-multiplier operations replace the current value.
- Use `null` only for operations that explicitly support clearing a form.
- Some fields may only affect specific projectile types or configurations.
