# ec-skills

A collection of [agent skills](https://code.claude.com/docs/en/skills) — drop-in knowledge packs that teach coding assistants (OpenCode, Claude Code, and other agents that support the `SKILL.md` format) how to work with specific tools and domains.

Each skill is a self-contained directory with a `SKILL.md` entry point and focused reference files the agent reads on demand.

## Skills

| Skill | Directory | What it does |
| --- | --- | --- |
| [Noctalia Plugins](noctalia-plugins/) | `noctalia-plugins/` | Build, debug, and publish plugins for the Noctalia Shell |
| [RobCo Patcher](robcopatcher/) | `robcopatcher/` | Author and review Fallout 4 runtime patches in RobCo Patcher ini format |
| [Umbriel](umbriel-skill/) | `umbriel-skill/` | Configure the Umbriel Wayland compositor |

### Noctalia Plugins

Everything needed to develop plugins for [Noctalia Shell](https://docs.noctalia.dev/) v5: `plugin.toml` manifests, Luau entry scripts, bar and desktop widgets, panels, layer surfaces, control-center shortcuts, launcher providers, headless services, declarative `ui.*` trees, runtime APIs, IPC testing, and catalog publication. Includes a complete starter plugin (`assets/starter/`). Verified against Noctalia v5.4.1, plugin API levels 3–43.

### RobCo Patcher

Creating, reviewing, and debugging [RobCo Patcher](https://www.nexusmods.com/fallout4/mods/69798) `.ini` files — runtime patches for Fallout 4. Covers all 14 record modules (weapons, armor, NPCs, races, ammo, OMODs, aim models, explosions, projectiles, form lists, ingestibles, leveled lists, containers, constructible objects, misc items), filter logic, value formats, naming conventions, and a troubleshooting matrix.

### Umbriel

Configuring the [Umbriel](https://docs.noctalia.dev/umbriel/) Wayland compositor from the Noctalia project: `config.toml` structure, installation, outputs, game streaming, keybinds and actions, input devices, appearance, animations, GLSL effects, layouts, workspaces and overview, window/layer rules, scratchpads, security (sandboxed clients, session lock, input capture, global shortcuts), and IPC.

## Installation

Clone the repo:

```bash
git clone https://github.com/egorcherkasoff/ec-skills.git
```

Then copy (or symlink) the skill directories you need into your agent's skills folder.

**OpenCode** (project-level `.opencode/skills/` or global):

```bash
# global
mkdir -p ~/.config/opencode/skills
cp -r ec-skills/noctalia-plugins ec-skills/robcopatcher ec-skills/umbriel-skill ~/.config/opencode/skills/
```

**Claude Code** (project-level `.claude/skills/` or global):

```bash
# global
mkdir -p ~/.claude/skills
cp -r ec-skills/noctalia-plugins ec-skills/robcopatcher ec-skills/umbriel-skill ~/.claude/skills/
```

**Keeping skills up to date** — symlink instead of copying, then `git pull` to update:

```bash
ln -s "$PWD/ec-skills/umbriel-skill" ~/.config/opencode/skills/umbriel-skill
```

## License

[MIT](LICENSE)
