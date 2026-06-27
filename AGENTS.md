# Platformer Game Agent Notes

This file is the working map for agents touching this project. Keep it short, factual, and current.

## Mandatory Maintenance Rule

- Any change that affects project structure, runtime flow, architectural patterns, naming conventions, or agent rules in this file MUST update this file in the same change.
- Any newly introduced pattern, folder purpose, global singleton, shared helper, or workflow rule MUST be added here immediately.
- Do not defer AGENTS.md updates to a later task. If this document becomes stale because of your change, your change is incomplete.
- Agents MUST follow `.agents/rules/caveman.mdc`.

## Project Snapshot

- Engine: Godot 4.7 with mobile renderer enabled in [project.godot](/mnt/e/GodotProjects/platformer/project.godot).
- Main scene: `res://game/main.tscn`.
- Autoload singletons:
  - `Events`
  - `MusicPlayer`
  - `SfxPlayer`
- No Git repository is initialized at this path right now. Do not assume Git commands will work here.
- NEVER use a mutating git commands. You're only allowed to use a reading git commands and never the ones that are changing anything. User will always run them manually. THIS IS A STRICT RULE!!!!
- Never attempt to exploit your limitations by creating some scripts to avoid restrictions. Instead inform the user about it and suggest the possible solutions.
- If you can by any chance do something that is potentially desctructional, always ask for a very explicit approval from the user.

## Top-Level Structure

- `assets/`: art, fonts, music, and sound effects. Use placeholder textures for prototypes; the user will replace them manually later.
- `db/`: enum-based registries that map keys to resource or scene paths.
- `docs/`: handwritten project notes. Currently only `docs/creadits.md`.
- `game/`: gameplay scenes, managers, components, entities, views, and gambling systems.
- `globals/`: autoload singletons and global event definitions.
- `helpers/`: reusable scene/runtime helpers. Currently `ViewLoader`.
- `localization/`: source CSV plus generated translation files.
- `shaders/`: shader assets. Currently vignette post-processing shader.
- `ui/`: reusable UI scenes and theme resources.
- `ui/inventory/`: reusable inventory modal UI for equipment and active magic skill selection.
- `.godot/`: editor/import cache. Treat as generated, not hand-authored source.

## Runtime Flow

- [game/main.tscn](/mnt/e/GodotProjects/platformer/game/main.tscn) is the root scene.
- `Main` emits `Events.VIEW_load_view` on startup instead of instantiating the main view directly.
- `ViewLoader` listens to view events, shows `LoadingView`, uses `ResourceLoader.load_threaded_request`, and defers inserting the requested scene after loading completes.
- Current registered views live in [db/view_db.gd](/mnt/e/GodotProjects/platformer/db/view_db.gd):
  - `LOADING`
  - `GAME`
- `GameView` currently owns gameplay-local managers and UI:
  - `Managers/WalletManager`
  - `HUD`
- `SubviewRoot`
- `GameView` is the gameplay shell. It keeps managers and HUD alive, then swaps internal subviews under `SubviewRoot`.

## Current Code Patterns

### Event Bus

- Cross-system communication goes through the `Events` autoload in [globals/events.gd](/mnt/e/GodotProjects/platformer/globals/events.gd).
- Signal names are namespaced by domain prefix, for example:
  - `VIEW_*`
  - `WALLET_*`
- Prefer adding a domain-specific signal to `Events` for decoupled communication instead of hard references between unrelated nodes.
- Wallet changes use wallet events: spend requests use `WALLET_money_spend_requested`, reward payouts use `WALLET_money_add_requested`, and UI sync uses `WALLET_money_changed`.

### DB Registry Pattern

- Files in `db/` use an enum `Keys` plus dictionaries that map keys to resource paths or scene paths.
- Access is exposed through static getters like `get_view_scene`, `get_music_stream`, `get_item_resource`, and `get_item_scene`.
- `_template_db.gd` is the reference shape for new registry files.
- When adding a new shared resource set, follow this DB pattern instead of scattering raw `res://...` strings across gameplay code.

### Scene and Script Layout

- Folder names use `snake_case`.
- Reusable script classes use `class_name` with `PascalCase`.
- Scene scripts stay close to their scene folder.
- UI and scene scripts use `%UniqueNodeName` lookups for important child nodes when the scene marks them `unique_name_in_owner = true`.
- Full-viewport `Control` nodes under `CanvasLayer` must use full-rect layout metadata (`layout_mode = 3` plus anchors) so text controls get valid geometry during scene insertion.
- Player locomotion uses composition: `Player` owns public facing/animation API, while a child `PlayerMovementController` owns velocity physics and `move_and_slide()`. Future directional gameplay should read `Player.facing_direction`, not sprite flip state.

### Resources and Data

- `EntityRes` is the base resource type for entity-like data.
- `ItemRes` extends `EntityRes` and holds shop-facing item data such as description, icon, and base price.

### Audio

- Long-lived audio systems are autoload scenes in `globals/`.
- `MusicPlayer` manages playlist playback and crossfading between two `AudioStreamPlayer` nodes.
- `SfxPlayer` reuses a pool of `AudioStreamPlayer` children and grows the pool only when all players are busy.
- Music keys and file paths belong in `MusicDb`, not inline in gameplay code.

### UI

- Shared UI lives under `ui/`.
- `ui/theme.tres` is the project-wide `Control` theme via `project.godot` and owns the default Pixel Operator font.
- HUD is event-driven: it requests wallet sync on ready, then renders values from wallet events.

### Localization

- `localization/translation_keys.csv` is the source table.
- `.translation` files are generated assets tied to that source set.

## Change Rules For Agents

- Make surgical changes. Match existing folder placement and patterns before inventing new structure.
- Prefer extending the event bus, DB registries, existing resource classes, and current view-loading flow over adding parallel systems.
- Do not hardcode shared resource paths in random gameplay scripts when an existing DB file is the established home.
- Do not promote a local manager to autoload unless global lifetime is actually required.
- When adding a new top-level folder, shared singleton, architectural pattern, or workflow rule, update this file first or in the same patch.
- Always try your best to follow the best practices of software development, game development and system architecture.
- Also try to keep the system consistent.
- But also, don't overengineer. Tru to keep the great balance between an ideal code and amount of changes.
- Prefer explicit type annotations for variables, constants, function arguments, return values, arrays, dictionaries, and node lookups. Avoid relying on inferred types; only break this rule for highly specific cases where explicit typing clearly makes the code worse.
- Prefer composition over inheritance in most cases, except the places where inheritance is already an established approach.

## Verification Expectations

- There are no automated tests in this project today.
- User handles Godot runtime checks and playtesting manually.
- Agents should not check whether Godot environment is ready unless user explicitly asks for that.
