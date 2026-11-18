# Security

Security surface of Umbriel: session locking, X11 desktop input (XTest via EIS), the
InputCapture portal, global-shortcut approval, and sandboxed Wayland clients
(security-context-v1 plus `[[security_context_rule]]` grants).

## Session locking

`ext-session-lock-v1`. The desktop stays visible while the locker prepares a mapped lock
surface for every active output (3 s budget). Umbriel switches every output to the lock
scene and reports the session locked only after **each active output has presented a
secure frame**.

- Stalled locker or omitted output: handoff continues after the deadline with an opaque
  compositor-owned blank. RGB comes from `colors.backdrop` (schema default `#000000ff`);
  alpha is always fully opaque.
- A locker that exits after the secure handoff leaves the blank in place — a crashed
  locker cannot expose the desktop.
- Keybinds with `allow_when_locked = true` still fire while locked (default `false`).

## X11 desktop input (XTest via EIS)

X11 apps can request pointer/keyboard control through XTest (Steam uses this for desktop
controller mappings). Requests arrive through Umbriel's native EIS backend; Umbriel asks
permission first.

- Prompt: **Enter** allows the requesting app for the current Umbriel session; any other
  non-modifier key or pointer click denies. Decisions last until Umbriel restarts.
- Input received through the XTest path cannot approve permission prompts.
- While locked: held emulated keys/buttons are released, further emulated input is
  discarded and **not replayed** after unlock. Physical devices still work on the lock
  screen.
- Requires Xwayland built with libei. No Steam preload library, device permission change,
  or RemoteDesktop portal implementation needed.

## Input capture

`org.freedesktop.portal.InputCapture` **version 2** via a matching
`xdg-desktop-portal-umbriel`; actual events use standard EI transport.

| Feature | Support |
| --- | --- |
| Keyboard events + modifiers | Yes |
| Pointer motion, buttons, scrolling | Yes |
| Keyboard-only / pointer-only sessions | Yes; capability masks `1`, `2`, or `3` |
| Logical screen zones, exterior edge barriers | Yes, incl. negative output positions and scaled outputs |
| `CreateSession2`, `Start`, enable, disable, release | Yes |
| Permission persistence + restore tokens | Optional explicit approval; app lifetime or until revoked |
| Clipboard sharing through capture | No |
| Touchscreen, tablet, touchpad gestures | No |
| RemoteDesktop portal input injection | Not provided by InputCapture |

Prompt and grants:

- On new capture sessions Umbriel shows its own prompt. **Enter** on a backend keyboard
  allows once; **R** remembers approval for the lifetime shown (while the app runs, or
  until revoked); any other non-modifier key or click denies. Wayland virtual keyboards
  and emulated EI input cannot approve or remember.
- The app label is requester-supplied and unverified; a name alone never restores
  permission. Remembered approval is available to any app using the standard
  restore-token flow (including unlabeled ones), which must save and supply the portal's
  token. Invalid, expired, revoked tokens or requests for extra capabilities require
  fresh approval. Apps that don't request persistence ask for each new session.
  Remembering input permission does not grant clipboard access.

CLI and storage:

```
umbriel input-capture-permissions
umbriel input-capture-revoke <id>
umbriel input-capture-revoke all
```

- Revocation stops sessions using the grant. App-lifetime grants expire when the app's
  D-Bus connection disappears. Durable grants survive restarts, stored in
  `$XDG_STATE_HOME/umbriel/input-capture-permissions.json`
  (default `~/.local/state/umbriel/input-capture-permissions.json`).
- Restore tokens are private credentials; the permission listing never exposes them.

Activation and lifecycle:

- Enabling a session arms its barriers; capture starts only on a permitted crossing.
  While a capability is captured, its events go to the approved EI receiver instead of
  local clients. **Ctrl+Alt+Escape** on a backend keyboard stops capture and restores
  local control; the app must re-enable the session before another crossing.
- Capture stops on locking, VT/session deactivation, transport failure, or session
  closure. Output geometry changes disable capture and invalidate barriers. Touchscreen
  and tablet input also restore local control. Pointer constraints, held pointer buttons,
  and compositor grabs prevent a barrier from taking over an interaction. Held input is
  released during handoff. Lock-screen input is never exported.

Deployment notes: install matching Umbriel + portal backend versions; the portal frontend
must expose version 2 (integration checks exercise real `xdg-desktop-portal` 1.22.1). No
Umbriel config option or extra libei package needed. Deskflow multi-monitor requires
≥ 1.27 (1.26 submits duplicate barrier IDs and fails to arm).

## Global shortcut approval

Umbriel's private global-shortcut bridge approves new shortcut IDs before registration.
The requesting app's label is unverified. Review displayed shortcut IDs, descriptions,
candidate chords, and conflicts; long requests paginate within the output's usable area.

- **Enter** on a physical keyboard reviews the next page; a fresh Enter on the final page
  approves the complete request and remembers its shortcut scope. Holding Enter, Wayland
  virtual keyboards, and emulated input cannot advance or approve. Any other non-modifier
  physical key or pointer click cancels. Output changes restart page review; config
  changes cancel the pending request. Approval fails when no panel can be shown or another
  confirmation, input capture, or session lock prevents review.
- Remembered approval restores only via a private compositor-issued credential for the
  same app and shortcut IDs — labels alone never restore it. Store:
  `$XDG_STATE_HOME/umbriel/global-shortcuts.json`
  (default `~/.local/state/umbriel/global-shortcuts.json`).
- Ordinary configured keybinds and compositor escape chords take priority. Shortcuts do
  not activate during capture, locking, a confirmation, shortcut inhibition, an active
  submap, or session inactivity.

CLI:

```
umbriel global-shortcuts
umbriel global-shortcuts --json
umbriel global-shortcuts-revoke org.example.App
umbriel global-shortcuts-revoke all
```

Note: umbriel 0.1.0 (88ba829c) rejects both commands as unknown on CLI and socket.

Inspection includes unassigned candidates and conflict reasons, never restore credentials.
Revocation closes matching live sessions and cancels pending review; a durable deletion
failure is reported even though live sessions stop — retry revocation before trusting a
credential to be permanently invalid. Reply fields/failures: see IPC docs
(`global-shortcuts`).

## Sandboxed Wayland clients (security-context-v1)

Wayland security-context protocol **v1**, always enabled. A sandbox engine creates a
restricted Wayland connection labeled with sandbox engine, application, and instance;
Umbriel then limits protocols on that connection. This does not create the sandbox or
display permission prompts.

### Restricted capabilities

Restricted clients keep: ordinary windows, rendering, focused input, clipboard use,
output discovery, idle inhibition, activation. Umbriel withholds compositor-wide
authority:

- Screen and window capture
- Direct access to the input-capture and global-shortcut bridges
- Virtual input and input-method ownership
- Clipboard-manager access
- Layer shell and session locking
- Gamma and output configuration
- DRM leasing of non-desktop displays
- Global workspace and window control
- Creation of nested security contexts

Trusted host services (e.g. xdg-desktop-portal) mediate privileged operations. New
protocols stay hidden from restricted clients until security-reviewed.

### Per-application grants

`[[security_context_rule]]` — grant extra globals when an app genuinely needs a protocol
without a portal equivalent:

```toml
[[security_context_rule]]
match.sandbox_engine = 'org\.flatpak'
match.app_id = 'org\.example\.ClipboardManager'
allow_globals = [
  "ext_data_control_manager_v1",
  "zwlr_data_control_manager_v1",
]
```

| Key | Type | Description |
| --- | --- | --- |
| `match.sandbox_engine` | string or string array, regex | Exact regex match on the sandbox engine. |
| `match.app_id` | string or string array, regex | Exact regex match on the application ID. |
| `allow_globals` | string array (default `[]`) | Additional Wayland globals to expose. |

- Umbriel supports both data-control variants; existing clipboard managers often use
  `zwlr_`, so grant both unless the app is known to use only `ext_`.
- Selectors are optional; a rule without selectors applies to every restricted client
  (avoid broad grants). Patterns match the complete value, not a substring. Either
  selector takes one pattern or an array; any one match suffices.
- Rules are additive and cannot remove the base protocol set; every matching rule
  contributes its values. `wp_security_context_manager_v1` stays blocked even if listed.
- Changes apply only to new connections — restart the app after changing grants. Invalid
  entries are ignored with a configuration warning.

### Security boundary

The protocol restricts **one Wayland connection** only — not files, processes, devices,
networking, D-Bus, X11, or other host interfaces. For restriction to matter the sandbox
must expose only its restricted Wayland socket and control access to Umbriel IPC
(`$UMBRIEL_SOCKET`), host D-Bus, X11 (`$DISPLAY`), and devices/host resources. The engine
supplies app metadata, so a grant is only as trustworthy as that engine. Clients on the
ordinary Wayland socket remain unrestricted. Treat security contexts as one part of a
sandbox boundary, not complete isolation.
