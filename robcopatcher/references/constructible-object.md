# Constructible Objects (COBJ)

- Setting: `iEnableConstructibleObjectPatching=1` in `Data/F4SE/Plugins/RobCo_Patcher.ini`
- Folder: `Data/F4SE/Plugins/RobCo_Patcher/constructibleObject/`

Important: `filterByCobjs`, `filterByWorkbenchKeywordsOr` and `filterByCategoryKeywordsOr`
are evaluated independently. The current module patches workbench and category keywords.
It does not modify recipe ingredients.

## Filters

### filterByCobjs
Value: COBJ forms, comma-separated — select specific constructible-object records.

```
filterByCobjs=Fallout4.esm|00123456
filterByCobjs=Fallout4.esm|00123456,MyMod.esp|00000800
```

### filterByWorkbenchKeywordsOr
Value: KYWD forms, comma-separated — match recipes that use at least one listed workbench
keyword (OR).

```
filterByWorkbenchKeywordsOr=Fallout4.esm|00102157
filterByWorkbenchKeywordsOr=Fallout4.esm|00102157,MyMod.esp|00000810
```

### filterByCategoryKeywordsOr
Value: KYWD forms, comma-separated — match recipes containing at least one listed category
keyword (OR).

```
filterByCategoryKeywordsOr=MyMod.esp|00000801
filterByCategoryKeywordsOr=MyMod.esp|00000801,MyMod.esp|00000802
```

### filterByModNames
Value: plugin names, comma-separated — only patch recipes originating from the listed
plugins.

```
filterByModNames=Fallout4.esm,MyMod.esp
```

## Operations

### workbenchKeyword
Value: KYWD form or `null` — set the workbench keyword used by the crafting recipe.
Passing `null` removes the current workbench keyword.

```
filterByCobjs=MyMod.esp|00000800:workbenchKeyword=Fallout4.esm|00102157
filterByCobjs=MyMod.esp|00000800:workbenchKeyword=null
```

### categoryKeywordsToAdd
Value: KYWD forms, comma-separated — add category keywords to the constructible object's
recipe filter.

```
filterByCobjs=MyMod.esp|00000800:categoryKeywordsToAdd=MyMod.esp|00000801
filterByCobjs=MyMod.esp|00000800:categoryKeywordsToAdd=MyMod.esp|00000801,MyMod.esp|00000802
```

### categoryKeywordsToRemove
Value: KYWD forms, comma-separated — remove category keywords from the constructible
object's recipe filter.

```
filterByCobjs=MyMod.esp|00000800:categoryKeywordsToRemove=MyMod.esp|00000801
filterByCobjs=MyMod.esp|00000800:categoryKeywordsToRemove=MyMod.esp|00000801,MyMod.esp|00000802
```

## Example strings

```
// Move one recipe to another workbench
filterByCobjs=MyMod.esp|00000800:workbenchKeyword=Fallout4.esm|00102157

// Remove the workbench requirement
filterByCobjs=MyMod.esp|00000800:workbenchKeyword=null

// Add a category to one recipe
filterByCobjs=MyMod.esp|00000800:categoryKeywordsToAdd=MyMod.esp|00000801

// Replace a recipe category
filterByCobjs=MyMod.esp|00000800:categoryKeywordsToRemove=MyMod.esp|00000801:categoryKeywordsToAdd=MyMod.esp|00000802

// Move all recipes from one workbench
filterByWorkbenchKeywordsOr=Fallout4.esm|00102157:workbenchKeyword=MyMod.esp|00000810

// Add a category to matching recipes
filterByCategoryKeywordsOr=MyMod.esp|00000801:categoryKeywordsToAdd=MyMod.esp|00000802

// Patch recipes from one plugin
filterByModNames=MyMod.esp:categoryKeywordsToAdd=MyMod.esp|00000801

// Combine independent filters — matches recipes passing both filter groups
filterByWorkbenchKeywordsOr=Fallout4.esm|00102157:filterByCategoryKeywordsOr=MyMod.esp|00000801:categoryKeywordsToAdd=MyMod.esp|00000802
```

## Notes

- `filterByCobjs`, `filterByWorkbenchKeywordsOr` and `filterByCategoryKeywordsOr` are
  independent filter groups.
- Multiple values inside the two keyword filters use OR logic.
- `categoryKeywordsToAdd` and `categoryKeywordsToRemove` modify the recipe category filter.
- `workbenchKeyword=null` clears the recipe's workbench keyword.
- Recipe ingredients and output objects are not changed by this module.
