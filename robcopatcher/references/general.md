# General rules — ini files, loading and filters

## Finding the record

RobCo patches reference records by plugin and FormID. Use the plugin-relative FormID shown
for the record in xEdit, for example `Fallout4.esm|00004822`. Do not prepend a load-order
index from a save file or copy an ID from another plugin.

- The plugin name must match the actual file name, including its `.esp`, `.esm` or `.esl`
  extension.
- The hexadecimal FormID belongs to that plugin. A FormID from a different plugin will not
  resolve to the intended record.
- Leading zeros may be omitted since update 2.8.0: `Fallout4.esm|4822` is equivalent to
  `Fallout4.esm|00004822`.
- If the FormID is not known, look it up in xEdit or ask the user. Never guess one.

## Choosing a filter

Use the narrowest filter that expresses the intent:

- one record — `filterBy<RecordType>=Plugin.esp|FormID`;
- a known set — the same filter with a comma-separated list;
- every record originating from a plugin — `filterByModNames=Plugin.esp`;
- a trait-based group — keyword, name, component, race, faction, biped-slot or ammo filters;
- a relationship — for example `filterByAmmos` selects weapons that use a listed ammunition
  record, while `filterByRaces` selects NPCs of a listed race.

Use only filters documented in the relevant module reference. Filters are not interchangeable
between modules, even when their names look similar.

Exclusion filters (`filterByXyExcluded`) remove records that would otherwise match. All
configured filter groups must pass; see [Filter semantics](#filter-semantics).

## Directory layout

```
Data
└── F4SE
    └── Plugins
        ├── RobCo_Patcher.dll
        ├── RobCo_Patcher.ini
        └── RobCo_Patcher
            ├── ammo
            ├── armor
            ├── npc
            ├── race
            ├── weapon
            └── ... one folder per module, see module map in SKILL.md
```

An ini file must be placed in the folder of its category: an ini that patches races goes into
`race/`. Additional subfolders are allowed and can be named freely, for example by mod:

```
F4SE/Plugins/RobCo_Patcher/npc/myModFolder/myfile.ini
F4SE/Plugins/RobCo_Patcher/npc/myModFolder/raider/myfile.ini
F4SE/Plugins/RobCo_Patcher/npc/myModFolder/gunner/myfile.ini
```

## Two ini file types

1. `someIniFile.ini` — always read.
2. `Fallout4.esm.ini`, `SomeMod.esp.ini` (name contains an esm/esp/esl file name) — read only
   when that plugin is active in the load order, otherwise skipped.

## Mod-manager conflict warning

Mod-specific ini files with identical names (`Fallout4.esm.ini`, `MyMod.esp.ini`, …) in the
same folder can overwrite each other through mod managers. Always put each mod's files into
their own subfolder.

Bad (same filename in the same folder — conflict):

```
F4SE/Plugins/RobCo_Patcher/npc/myModFolder/Fallout4.esm.ini    <- Mod A
F4SE/Plugins/RobCo_Patcher/npc/myModFolder/Fallout4.esm.ini    <- Mod B
```

Good:

```
F4SE/Plugins/RobCo_Patcher/npc/myModFolder/ModA/Fallout4.esm.ini
F4SE/Plugins/RobCo_Patcher/npc/myModFolder/ModB/Fallout4.esm.ini
```

## Comments

Comments always start with `/`. One `/` is enough, but `//` looks better.

## Patch string structure

Patch strings are modular — use only the parts that are needed. A string consists of filters
and operations joined with `:`.

Example — make the 10mm pistol use .308 ammo and the matching NPC ammo leveled list:

```
filterByWeapons=Fallout4.esm|00004822:setNewAmmo=Fallout4.esm|0001F66B:setNewAmmoList=Fallout4.esm|000FF424
```

Since update 2.8.0 the FormID may be written without leading zeros:

```
filterByWeapons=Fallout4.esm|4822:setNewAmmo=Fallout4.esm|1F66B:setNewAmmoList=Fallout4.esm|FF424
```

## Filter semantics

- `filterByXy` — AND: every listed value must match.
- `filterByXyOr` — OR: at least one listed value must match.
- `filterByXyExcluded` — the record is excluded if any listed value matches.

Filter groups work independently of each other. A rule applies only when every configured
group passes. Missing groups are simply not checked.

Example:

- `filterByKeywords` has 2 keywords and both match — pass.
- `filterByKeywordsOr` has 5 keywords and at least one matches — pass.
- `filterByKeywordsExcluded` has 10 keywords and none matches — pass.

If `filterByKeywords` matches only ONE of its two keywords, the whole rule fails, even when
the Or and Excluded groups pass.

If no filter is set at all, the rule can access every record of the module's type. This is
rarely intended, and it is especially risky for FormLists. For leveled lists, use
`filterByLLs` or set `noFilterLL=true` explicitly to opt into patching all lists; `addToLL`
is the exception because it names its target list in its value.

Example for armors — biped slots are accessed by index (Biped Slots list in the Creation Kit;
index 11 = slot 41 [A] Torso):

```
filterByBipedSlots=11:filterByKeywordsExcluded=Fallout4.esm|0004D8A1
```

This selects all armors that use biped slot index 11 and do not have the keyword
`ArmorTypePower [KYWD:0004D8A1]`.

## Player exception

The player is always excluded from race or keyword filtering. To patch the player, use
`filterByNpcs=Fallout4.esm|00000007` and no other filter.
