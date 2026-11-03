# Aim Models (AMDL)

- Setting: `iEnableAimModelPatching=1` in `Data/F4SE/Plugins/RobCo_Patcher.ini`
- Folder: `Data/F4SE/Plugins/RobCo_Patcher/aimModel/`

Important: all operation values are numeric. AimModel values affect every weapon using the
patched AimModel.

## Filters

### filterByAimModels
Value: AMDL forms, comma-separated — select specific AimModel records.

```
filterByAimModels=MyMod.esp|00000800
filterByAimModels=MyMod.esp|00000800,MyMod.esp|00000801
```

### filterByModNames
Value: plugin names, comma-separated — only patch AimModel records originating from the
listed plugins.

```
filterByModNames=Fallout4.esm,MyMod.esp
```

## Operations

All values are plain setters (no add/mult variants here).

| Operation | Value | Meaning |
|---|---|---|
| `aimModelBaseStability` | number | base weapon stability |
| `aimModelConeDecreaseDelayMs` | integer | delay in ms before the cone begins decreasing after firing |
| `aimModelConeDecreasePerSec` | number | how quickly the accuracy cone decreases per second |
| `aimModelConeIncreasePerShot` | number | how much the accuracy cone increases with each shot |
| `aimModelConeSneakMultiplier` | number | cone multiplier applied while sneaking |
| `aimModelMaxConeDegrees` | number | maximum accuracy cone in degrees |
| `aimModelMinConeDegrees` | number | minimum accuracy cone in degrees |
| `aimModelRecoilArcDeg` | number | size of the recoil arc in degrees |
| `aimModelRecoilArcRotateDeg` | number | rotate the recoil arc by this many degrees |
| `aimModelRecoilDiminishSightsMult` | number | recoil reduction multiplier while aiming down sights |
| `aimModelRecoilDiminishSpringForce` | number | recoil recovery spring force |
| `aimModelRecoilHipMult` | number | recoil multiplier while firing from the hip |
| `aimModelRecoilMaxDegPerShot` | number | maximum recoil applied per shot |
| `aimModelRecoilMinDegPerShot` | number | minimum recoil applied per shot |
| `aimModelRecoilShotsForRunaway` | integer | consecutive shots before runaway recoil begins |

Examples:

```
filterByAimModels=MyMod.esp|00000800:aimModelBaseStability=0.75
filterByAimModels=MyMod.esp|00000800:aimModelConeDecreaseDelayMs=250
filterByAimModels=MyMod.esp|00000800:aimModelConeDecreasePerSec=2.5
filterByAimModels=MyMod.esp|00000800:aimModelConeIncreasePerShot=0.5
filterByAimModels=MyMod.esp|00000800:aimModelConeSneakMultiplier=0.75
filterByAimModels=MyMod.esp|00000800:aimModelMaxConeDegrees=4.0
filterByAimModels=MyMod.esp|00000800:aimModelMinConeDegrees=1.5
filterByAimModels=MyMod.esp|00000800:aimModelRecoilArcDeg=30.0
filterByAimModels=MyMod.esp|00000800:aimModelRecoilArcRotateDeg=5.0
filterByAimModels=MyMod.esp|00000800:aimModelRecoilDiminishSightsMult=0.6
filterByAimModels=MyMod.esp|00000800:aimModelRecoilDiminishSpringForce=12.0
filterByAimModels=MyMod.esp|00000800:aimModelRecoilHipMult=1.5
filterByAimModels=MyMod.esp|00000800:aimModelRecoilMaxDegPerShot=1.5
filterByAimModels=MyMod.esp|00000800:aimModelRecoilMinDegPerShot=0.5
filterByAimModels=MyMod.esp|00000800:aimModelRecoilShotsForRunaway=6
```

## Example strings

```
// Change accuracy cone
filterByAimModels=MyMod.esp|00000800:aimModelMinConeDegrees=1.5:aimModelMaxConeDegrees=4.0

// Change recoil per shot
filterByAimModels=MyMod.esp|00000800:aimModelRecoilMinDegPerShot=0.5:aimModelRecoilMaxDegPerShot=1.5

// Improve recoil recovery
filterByAimModels=MyMod.esp|00000800:aimModelRecoilDiminishSpringForce=12.0:aimModelRecoilDiminishSightsMult=0.6

// Increase hip-fire recoil
filterByAimModels=MyMod.esp|00000800:aimModelRecoilHipMult=1.5

// Configure cone growth and recovery
filterByAimModels=MyMod.esp|00000800:aimModelConeIncreasePerShot=0.5:aimModelConeDecreaseDelayMs=250:aimModelConeDecreasePerSec=2.5

// Configure runaway recoil
filterByAimModels=MyMod.esp|00000800:aimModelRecoilShotsForRunaway=6:aimModelRecoilMinDegPerShot=0.5:aimModelRecoilMaxDegPerShot=2.0

// Configure directional recoil
filterByAimModels=MyMod.esp|00000800:aimModelRecoilArcDeg=30:aimModelRecoilArcRotateDeg=5

// Patch every AimModel from a plugin
filterByModNames=MyMod.esp:aimModelRecoilHipMult=1.25:aimModelConeSneakMultiplier=0.75
```

## Notes

- AimModel changes affect every weapon that references the patched AimModel.
- The minimum cone should normally not exceed the maximum cone.
- The minimum recoil per shot should normally not exceed the maximum recoil per shot.
- `aimModelConeDecreaseDelayMs` and `aimModelRecoilShotsForRunaway` use integer values;
  all other operation values accept decimal numbers.
- Multiple operations may be combined on the same line.
