---
name: RobCo Patcher
description: Create, review and fix RobCo Patcher .ini files for Fallout 4 — runtime patches for weapons, armor, NPCs, races, ammo, OMODs, aim models, explosions, projectiles, form lists, ingestibles, leveled lists, containers, constructible objects and misc items
---

# RobCo Patcher — patch authoring

RobCo Patcher (https://www.nexusmods.com/fallout4/mods/69798) is an F4SE plugin that patches
Fallout 4 records at runtime from `.ini` files. Each ini line is one independent patch rule:
filters select records, operations change them.

Use this skill whenever the user wants to create, edit, review or debug RobCo Patcher ini files
or "patch strings".

## Workflow

1. Determine what the user wants to change and which record type it belongs to
   (WEAP, ARMO, NPC_, RACE, AMMO, OMOD, AMDL, EXPL, PROJ, FLST, ALCH, LVLI/CONT, COBJ, MISC).
2. Read `references/general.md` for file placement, naming and loading rules.
3. Read the module reference from the table below. Never write operations or property names
   from memory — always confirm exact spelling and value format in the reference.
4. Compose the rules: filters first, then operations, parameters joined with `:`,
   multiple values with `,`.
5. Save the ini into the correct module folder (see table) using the naming conventions
   from `references/general.md` (per-mod subfolder; `<Plugin>.esp.ini` only when the rule
   should apply conditionally on that plugin being loaded).
6. Validate the file against the checklist below and re-read the relevant reference for any
   operation whose value format is uncertain.
7. Report to the user: the created file path and the `iEnable...Patching=1` setting that must
   be present in `Data/F4SE/Plugins/RobCo_Patcher.ini` for the module.

## Reviewing an existing patch

1. Identify the module from the folder the file is in (or from the setting it is meant to
   use). A file in the wrong folder is a finding in itself.
2. Read every non-comment line as `:`-separated segments. Confirm that each filter and
   operation key exists in that module's reference.
3. Check each value format: form IDs, `~` ranges, `=` pairs, tildes around `fullName`, and
   `null` only where permitted.
4. Check the logic: values inside one filter follow that filter's AND/OR/exclusion mode, and
   all configured filter groups must pass. Watch for accidental unfiltered rules and for
   race/keyword filters that silently exclude the player.
5. Report findings per line (or per rule) and show corrected lines. Do not rewrite unrelated
   rules or guess missing FormIDs.

## Before writing a rule

- Resolve the exact target in xEdit or from information the user supplies. Use the form's
  plugin-relative ID (`Fallout4.esm|00004822`), not a load-order-prefixed ID copied from a
  save or from another plugin. Never invent a FormID or plugin name.
- Confirm the record type. A patch placed in the wrong module folder silently does nothing:
  an ARMO record must be patched by the armor module, an OMOD by the object-modification
  module, and so on.
- Prefer narrow filters for a one-off change. Use `filterByModNames` or keyword/relationship
  filters only when the user really wants a bulk patch.
- Check that the target has the data the operation needs: an AimModel operation requires a
  weapon with an AimModel, an OMOD property operation requires a property of the matching
  layout, and a ranged projectile override requires ranged weapon data.
- If the user asks to patch a whole mod, confirm whether they mean records originating from
  that plugin or records it overrides. Document what the chosen filter actually matches.

## Golden rules

- One line = one independent patch rule. Parameters are separated by `:`, multiple values by `,`.
- Forms are written `Plugin.esp|FormID`, e.g. `Fallout4.esm|00004822`. Leading zeros may be
  omitted since update 2.8.0 (`Fallout4.esm|4822`).
- Lines beginning with `/` are ignored. Use `//` for comments.
- Decimal numbers use a period: `0.75`.
- Display names must be enclosed by one tilde on each side: `fullName=~New Name~`.
- `none` marks an unused parameter; unused parameters can normally be omitted.
- Filters exist in AND (`filterByXy`), OR (`filterByXyOr`) and exclusion (`filterByXyExcluded`)
  variants. Filter groups are evaluated independently; if any configured group fails, the rule
  does not apply.
- If a filter is given multiple values, the filter's own mode (AND, OR or excluded) decides
  whether all, any or none of them may match. Different filter keys are then combined with AND.
- If no filter is set at all, the rule can apply to every record of that module's type.
  For FormLists this is almost never intended. For leveled lists, set `noFilterLL=true`
  explicitly when patching without `filterByLLs` (`addToLL` is the exception because it
  names its target list in its value).
- `null` clears a form — use it only where the module reference explicitly allows it.
- Multiplier operations (`...Mult`, `...Multiply`, `changeDamageTypesByMult`) modify the
  current value; plain setters replace it; `...ToAdd` adds to it.
- `addToLLs` ChanceNone is inverted: `0` = 100% chance, `30` = 70%, `100` = 0%.
- OMOD property operations must match the property's data layout (float / {FormID,Int} /
  {FormID,Float}); the wrong operation produces incorrect results.
- The player (`Fallout4.esm|00000007`) is always excluded from race and keyword filtering.
  To patch the player use `filterByNpcs=Fallout4.esm|00000007` and no other filter.

## Module map

| Records | RobCo_Patcher.ini setting | Ini folder (under `Data/F4SE/Plugins/RobCo_Patcher/`) | Reference |
|---|---|---|---|
| Weapons (WEAP) | `iEnableWeaponPatching=1` | `weapon/` | `references/weapon.md` |
| Armor (ARMO) | `iEnableArmorPatching=1` | `armor/` | `references/armor.md` |
| NPCs (NPC_) | `iEnableNPCPatching=1` | `npc/` | `references/npc.md` |
| Races (RACE) | `iEnableRacePatching=1` | `race/` | `references/race.md` |
| Ammo (AMMO) | `iEnableAmmoPatching=1` | `ammo/` | `references/ammo.md` |
| Object modifications (OMOD) | `iEnableObjectModificationPatching=1` | `objectModification/` | `references/omod.md` |
| Aim models (AMDL) | `iEnableAimModelPatching=1` | `aimModel/` | `references/aim-model.md` |
| Explosions (EXPL) | `iEnableExplosionPatching=1` | `explosion/` | `references/explosion.md` |
| Projectiles (PROJ) | `iEnableProjectilePatching=1` | `projectile/` | `references/projectile.md` |
| Form lists (FLST) | `iEnableFormlistPatching=1` | `formList/` | `references/form-list.md` |
| Ingestibles (ALCH) | `iEnableIngestiblePatching=1` | `ingestible/` | `references/ingestible.md` |
| Leveled lists & containers (LVLI, CONT) | `iEnableLeveledListPatching=1` | `leveledList/` | `references/leveled-list.md` |
| Constructible objects (COBJ) | `iEnableConstructibleObjectPatching=1` | `constructibleObject/` | `references/constructible-object.md` |
| Misc items (MISC) | `iEnableMiscPatching=1` | `misc/` | `references/misc.md` |

## Cross-module links

- `ammoCategory` (ammo patcher) feeds `filterByHasAmmoFromWeaponList` (weapon patcher).
  Without the ammo-side `ammoCategory` rules the weapon filter has nothing to match.
- Weapon AimModel shortcuts (`coneIronSightsMultiplier`, `recoilPerShotMin/Max`,
  `recoilDiminishSpringForce`) edit the weapon's assigned AMDL; the aim-model patcher
  edits AMDL records directly.
- `addToFormList` (ammo patcher) and the form-list patcher both manage FLST membership.
- `changeDamageTypes` uses the same `DMGT=Value` / `DMGT=Min~Max` format in the weapon and
  armor modules. `changeDamageTypesByMult` exists only in the armor module.
- `workbenchKeyword` and the category keyword operations belong to the COBJ module; they do
  not change recipe ingredients or output objects.

## Patch file checklist

- [ ] The file is inside the correct module folder (`weapon/`, `armor/`, `npc/`, …).
- [ ] The matching `iEnable...Patching=1` setting is present in `RobCo_Patcher.ini`.
- [ ] The filename is either a plain `name.ini` or a plugin-conditional `<Plugin>.esp.ini`
      whose plugin is actually in the load order.
- [ ] Mod-specific files live in their own subfolder to avoid mod-manager filename conflicts.
- [ ] Every rule has the intended filter; no unfiltered rule was created by accident.
- [ ] Every form is `Plugin.ext|FormID`, with the correct plugin filename and a real FormID.
- [ ] `fullName` values use exactly one tilde on each side.
- [ ] `null` is used only for operations documented as accepting it.
- [ ] Numeric formats match the operation: decimals with `.`, `~` ranges, `=` value pairs.
- [ ] OMOD operations match the property layout; leveled-list ChanceNone is inverted.

## Troubleshooting

| Symptom | Check first |
|---|---|
| Rule has no effect | Module setting not enabled; ini in the wrong folder; line begins with `/`; key misspelled; plugin-conditional filename never loaded because that plugin is not active; filter did not match. |
| Rule affects far more records than expected | No filter or a very broad filter (`filterByModNames`, keyword-only); unfiltered FormList rules, or leveled-list rules with `noFilterLL=true`, can hit everything. |
| Whole line ignored | Unknown key or operation; `:` and `,` confused; `~` separators missing in a structured value; decimal comma used instead of a period. |
| Name does not change or shows tildes | `fullName=~New Name~` must have exactly one tilde on each side. |
| Weapon/AimModel change has no effect | The weapon has no AimModel, or the AimModel operation is aimed at a non-AMDL record. |
| OMOD change has the wrong value or no effect | The operation does not match the property layout (float vs `{FormID,Int}` vs `{FormID,Float}`), or the property does not exist on that OMOD. |
| Leveled list is unchanged | A rule without `filterByLLs` needs `noFilterLL=true`; container operations cannot patch LVLI records (and vice versa). |
| Chance behaves backwards | `addToLLs` uses ChanceNone: `0` = always, `100` = never. |
| Player is not patched | Race and keyword filters always exclude the player; use `filterByNpcs=Fallout4.esm|00000007` alone. |
| Patch disappeared after installing another mod | A mod manager overwrote an identically named ini in the same folder; move each mod's files into its own subfolder. |
| FormID cannot be resolved | Plugin filename or extension is wrong, or the ID belongs to a different plugin/load order. IDs are hexadecimal. |

## Report back

When handing a patch to the user, state:

- the absolute path of the created or edited ini;
- the module and its `iEnable...Patching=1` setting;
- which records/filters the rule targets, and any assumptions about load order or FormIDs;
- anything that still needs confirmation in game (AimModel presence, OMOD property layout,
  leveled-list behavior, bulk-patch scope).
