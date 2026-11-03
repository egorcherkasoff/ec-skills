# Misc Items (MISC)

- Setting: `iEnableMiscPatching=1` in `Data/F4SE/Plugins/RobCo_Patcher.ini`
- Folder: `Data/F4SE/Plugins/RobCo_Patcher/misc/`

Important: component filters use a component form identifier.

## Filters

### filterByMiscs
Value: MISC forms, comma-separated — select specific misc items.

```
filterByMiscs=Fallout4.esm|00059B25,MyMod.esp|00000800
```

### filterByHasComponent
Value: component form — match misc items containing the specified component.

```
filterByHasComponent=Fallout4.esm|0006907A
```

### filterByHasNoComponent
Value: component form — exclude misc items containing the specified component.

```
filterByHasNoComponent=Fallout4.esm|0006907A
```

### filterByKeywords
Value: KYWD forms, comma-separated — all listed keywords must be present (AND).

```
filterByKeywords=Fallout4.esm|0010C3F6,MyMod.esp|00000801
```

### filterByKeywordsOr
Value: KYWD forms, comma-separated — at least one listed keyword must be present (OR).

```
filterByKeywordsOr=Fallout4.esm|0010C3F6,MyMod.esp|00000801
```

### filterByKeywordsExcluded
Value: KYWD forms, comma-separated — exclude misc items containing any listed keyword.

```
filterByKeywordsExcluded=MyMod.esp|00000801
```

### filterByModNames
Value: plugin names, comma-separated — only patch records originating from the listed plugins.

```
filterByModNames=Fallout4.esm,MyMod.esp
```

## Operations

### weight
Value: number — set the weight of the misc item.

```
filterByMiscs=MyMod.esp|00000800:weight=0.5
```

### weightMultiply
Value: number — multiply the current weight.

```
filterByHasComponent=Fallout4.esm|0006907A:weightMultiply=0.5
```

### value
Value: number — set the caps value.

```
filterByMiscs=MyMod.esp|00000800:value=10
```

### valueMult
Value: number — multiply the current caps value.

```
filterByMiscs=MyMod.esp|00000800:valueMult=2.0
```

### fullName
Value: `~text~` — change the displayed name.

```
filterByMiscs=MyMod.esp|00000800:fullName=~Useful Scrap~
```

### keywordsToAdd
Value: KYWD forms, comma-separated — add keywords.

```
filterByMiscs=MyMod.esp|00000800:keywordsToAdd=MyMod.esp|00000801,MyMod.esp|00000802
```

### keywordsToRemove
Value: KYWD forms, comma-separated — remove keywords.

```
filterByMiscs=MyMod.esp|00000800:keywordsToRemove=MyMod.esp|00000801
```

## Example strings

```
// Change weight and value
filterByMiscs=MyMod.esp|00000800:weightMultiply=0.5:value=10

// Rename and add a keyword
filterByMiscs=MyMod.esp|00000800:fullName=~Useful Scrap~:keywordsToAdd=MyMod.esp|00000801

// Reduce the weight of items containing a component
filterByHasComponent=Fallout4.esm|0006907A:weightMultiply=0.5

// Patch items without a specific component
filterByHasNoComponent=Fallout4.esm|0006907A:valueMult=1.5
```

## Notes

- MISC records use `weightMultiply`. Armor records use `weightMult`.
- `filterByHasComponent` and `filterByHasNoComponent` require component forms, not `true`
  or `false`.
