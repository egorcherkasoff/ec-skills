---
name: Noctalia Plugins
description: Build, debug, and publish Noctalia Shell v5 plugins — plugin.toml manifests, Luau entry scripts, bar and desktop widgets, panels, layer surfaces, control-center shortcuts, launcher providers, headless services, declarative ui.* trees, runtime APIs, IPC testing, and catalog publication
---

# Noctalia Plugins

Noctalia v5 plugins extend the shell with **bar widgets**, **desktop widgets**,
**panels**, **layer surfaces**, **control-center shortcuts**, **launcher providers**,
and headless **services**. A plugin is a directory containing a static `plugin.toml`
manifest and one or more Luau entry scripts. Every entry runs in its own isolated
Luau VM, off the UI thread, with per-call time budgets.

**Version target.** This skill is verified against Noctalia **v5.4.1** (latest stable
at the time of writing), which supports plugin API levels **3–43**. API levels
**44–49** are documented for unreleased builds and are marked as such in
`references/compatibility.md`. Always check the installed shell before choosing a
level:

```bash
noctalia --version
noctalia msg plugins list      # incompatible plugins are labeled
```

If the installed binary and the docs disagree, the installed binary wins. Test the
plugin instead of trusting a version table.

## Workflow

1. **Pick the entry kinds.** A plugin can mix bar widgets, panels, services,
   shortcuts, launcher providers, desktop widgets, and layers. A headless
   `[[service]]` is the normal place for polling, network, or shared state; UI
   entries consume it through `noctalia.state`.
2. **Read the matching reference before writing code:**
   - `references/manifest.md` — `plugin.toml`, entry tables, settings schema.
   - `references/entries.md` — lifecycle callbacks and per-entry APIs.
   - `references/ui.md` — declarative `ui.*` trees and interactive controls.
   - `references/runtime-api.md` — every `noctalia.*` capability.
   - `references/compatibility.md` — choose the minimum `plugin_api`.
   - `references/workflow.md` — local install, lint, IPC testing, publishing.
   - `references/examples.md` — complete patterns for common plugin shapes.
3. **Scaffold the plugin.** Start from `assets/starter/` when a widget + service +
   panel is enough. Use a globally unique id `<author>/<plugin>`; the directory name
   in a source repo must match the part after `/`.
4. **Write the manifest first.** Declare every setting the scripts call
   `noctalia.getConfig(key)` with. Undeclared reads are errors; declared-but-unread
   settings are warnings.
5. **Validate offline:**
   ```bash
   noctalia plugins lint path/to/plugin
   ```
   Fix every error and warning before installing.
6. **Install and enable.** For development either place the plugin in
   `~/.local/share/noctalia/plugins/<plugin>/`, or add a `path` source pointing at
   your dev directory. Enable once with
   `noctalia msg plugins enable <author>/<plugin>`.
7. **Test live.** Script edits hot-reload automatically; manifest changes need
   `noctalia msg config-reload`. Drive handlers with
   `noctalia msg plugin <author/plugin>:<entry> <target> <event> [payload]`,
   panels with `noctalia msg panel-toggle <author/plugin>:<entry>`, and inspect
   state with `noctalia msg plugins list`.
8. **Configure the user side.** Add bar widgets with
   `[widget.<name>] type = "<author>/<plugin>:<entry>"`, choose panel placement in
   Settings → Plugins or `[plugin_settings."<author>/<plugin>"]`, and place desktop
   widgets from the desktop-widget editor. Validate config with
   `noctalia config validate`.
9. **Publish only after it runs.** A source repo needs `catalog.toml`, a README,
   `thumbnail.webp`, and `translations/en.json`; submit to `community-plugins`.

## Non-negotiable rules

- **Use the lowest `plugin_api` that covers every feature you use.** Raising it
  drops the plugin from older shells. A simple widget is `plugin_api = 3`.
- **Put `--!nonstrict` at the top of every entry script.** `noctalia`, `ui`,
  `barWidget`, `panel`, `layer`, `desktopWidget`, `shortcut`, and `launcher` are
  injected globals; strict mode rejects them.
- **Entry VMs do not share Lua memory.** Publish plain data (strings, numbers,
  booleans, tables of those) through `noctalia.state.set/get/watch`.
- **`noctalia.state` is process-lifetime only.** Persist real data with
  `noctalia.pluginDataDir()` + `noctalia.readFile` / `writeFile`; never write into
  `noctalia.pluginDir()` because git installs replace it on update.
- **Only declared settings resolve.** `noctalia.getConfig("typo")` logs a warning
  and returns `nil`. `noctalia.getSetting(path)` is the separate read-only view of
  the shell's own config.
- **Never block the UI thread.** Use `noctalia.http`, `runAsync`, `readFileAsync`,
  and `runStream`; keep `update()` cheap and set a sane
  `noctalia.setUpdateInterval(ms)` (values below 16 ms are clamped).
- **Panel and desktop sizes are host-owned.** Declare panel `width`/`height` in the
  manifest. A bar widget's tree must fit one control across the bar thickness.
- **Bar widgets have no keyboard.** `ui.input`, `ui.select`, and `ui.scroll` are
  skipped with a warning inside a bar tree. Use a panel for those controls.
- **Color with roles, not hex**, unless a fixed color is intentional. Use
  `primary`, `on_surface`, `surface_container`, `outline_variant`, etc., optionally
  with an alpha suffix such as `primary/0.6`.
- **Settings labels are translation keys.** `label_key` / `description_key` are
  mandatory where applicable; literal `label`/`description` fields are rejected.
  Ship at least `translations/en.json`.
- **Callbacks receive strings.** `onChange`, `onScroll`, `onKey`, `onFrameTick`,
  `onPointerMove`, etc. deliver numeric/boolean values as strings; convert with
  `tonumber`, compare with `== "true"` / `== "false"`.
- **Clean up in `onExit(signal, reason)`.** Do not rely on it for `SIGKILL`. For
  cleanup that must outlive the VM, start a detached `noctalia.runAsync(command)`.
- **Plugins are trusted code.** The filesystem helpers are not sandboxed and
  `runAsync` can execute anything the user can. Never run untrusted payloads or
  interpolate user input into a shell string; use the argv form of `runAsync`.

## Reference index

| Topic | File |
| --- | --- |
| `plugin.toml`, entry declarations, settings schema, translations | `references/manifest.md` |
| Lifecycle callbacks, bar/shortcut/launcher/service/panel/layer/desktop APIs, IPC | `references/entries.md` |
| `ui.*` controls, layout, callbacks, drag/drop, context menus, pixel streams | `references/ui.md` |
| Every `noctalia.*` function, limits, and persistence | `references/runtime-api.md` |
| Plugin API levels 3–49 and which features they gate | `references/compatibility.md` |
| Local dev, lint, IPC testing, source repos, catalog, publishing | `references/workflow.md` |
| Complete plugin patterns and recipes | `references/examples.md` |
| Working starter: widget + service + panel | `assets/starter/` |

## Starter

`assets/starter/` is a lint-clean plugin with a bar widget, a panel, a service,
plugin-level and widget-level settings, shared state, translations, and IPC:

```bash
cp -r assets/starter ~/.local/share/noctalia/plugins/hello
noctalia plugins lint ~/.local/share/noctalia/plugins/hello
noctalia msg plugins enable me/hello
```

Then add the widget in Settings → Bar (or
`[widget.hello] type = "me/hello:hello"`), open the panel with
`noctalia msg panel-toggle me/hello:panel`, and change the label with
`noctalia msg plugin me/hello:hello focused set "Hi"`.

## When something does not work

1. Run `noctalia plugins lint <dir>`; it catches undeclared reads and unused
   settings.
2. Run `noctalia config validate` after touching `config.toml`; unknown widget
   settings and bad panel placement are reported with file/line/column.
3. Watch the shell log for Luau errors, unknown UI props, and undeclared setting
   warnings. Unknown control types or props are logged and skipped, not fatal.
4. Confirm the plugin is enabled and not labeled `incompatible` or
   `held-back` in `noctalia msg plugins list`.
5. Check that the entry id is fully qualified: `<author>/<plugin>:<entry>`, and
   that IPC uses a target the entry supports (`focused`, a connector,
   `connector:bar`, or `all`).
6. For manifest changes, run `noctalia msg config-reload`; for `.luau` changes,
   saving the file is enough.
