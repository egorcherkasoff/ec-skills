# Form Lists (FLST)

- Setting: `iEnableFormlistPatching=1` in `Data/F4SE/Plugins/RobCo_Patcher.ini`
- Folder: `Data/F4SE/Plugins/RobCo_Patcher/formList/`

Important: if no FormList filter is used, the rule may affect every FormList. Use
`filterByFormLists` or `filterByModNames` unless patching all FormLists is intentional.
Forms of different record types may be stored in a FormList.

## Filters

### filterByFormLists
Value: FLST forms, comma-separated — select specific FormLists.

```
filterByFormLists=Fallout4.esm|00246EE7
filterByFormLists=Fallout4.esm|00246EE7,MyMod.esp|00000800
```

### filterByModNames
Value: plugin names, comma-separated — only patch FormLists originating from the listed
plugins.

```
filterByModNames=Fallout4.esm,MyMod.esp
```

## Operations

### formsToAdd
Value: forms, comma-separated — add forms to the selected FormLists.

```
filterByFormLists=Fallout4.esm|00246EE7:formsToAdd=Fallout4.esm|00059A71
filterByFormLists=Fallout4.esm|00246EE7:formsToAdd=Fallout4.esm|00059A71,MyMod.esp|00000801
```

### formsToRemove
Value: forms, comma-separated — remove matching forms from the selected FormLists.

```
filterByFormLists=Fallout4.esm|00246EE7:formsToRemove=Fallout4.esm|00059A71
filterByFormLists=Fallout4.esm|00246EE7:formsToRemove=Fallout4.esm|00059A71,MyMod.esp|00000801
```

### formsToReplace
Value: `OldForm=NewForm`, comma-separated — replace matching forms in place while preserving
their position in the FormList.

```
filterByFormLists=Fallout4.esm|00246EE7:formsToReplace=Fallout4.esm|00059A71=Fallout4.esm|00059A72
filterByFormLists=Fallout4.esm|00246EE7:formsToReplace=Fallout4.esm|00059A71=Fallout4.esm|00059A72,MyMod.esp|00000801=MyMod.esp|00000802
```

## Example strings

```
// Add an entry
filterByFormLists=Fallout4.esm|00246EE7:formsToAdd=Fallout4.esm|00059A71

// Remove an entry
filterByFormLists=Fallout4.esm|00246EE7:formsToRemove=Fallout4.esm|00059A71

// Replace an entry
filterByFormLists=Fallout4.esm|00246EE7:formsToReplace=Fallout4.esm|00059A71=Fallout4.esm|00059A72

// Add and remove entries in one rule
filterByFormLists=Fallout4.esm|00246EE7:formsToRemove=Fallout4.esm|00059A71:formsToAdd=MyMod.esp|00000801

// Patch all FormLists from one plugin
filterByModNames=MyMod.esp:formsToAdd=MyMod.esp|00000801
```

## Notes

- A FormList may contain forms of different record types.
- `formsToReplace` only replaces entries that already exist in the selected FormLists.
- Multiple additions, removals and replacements are separated by commas.
- Avoid omitting all filters unless changing every FormList is intentional.
