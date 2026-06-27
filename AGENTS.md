# Platformer Game Agent Notes

This file is the working map for agents touching this project. Keep it short, factual, and current.

## Mandatory Maintenance Rule

- Any change that affects project structure, runtime flow, architectural patterns, naming conventions, or agent rules in this file MUST update this file in the same change.
- Any newly introduced pattern, folder purpose, global singleton, shared helper, or workflow rule MUST be added here immediately.
- Do not defer AGENTS.md updates to a later task. If this document becomes stale because of your change, your change is incomplete.
- Agents MUST follow `.agents/rules/caveman.mdc`.

## Project Snapshot

- Engine: Godot 4.7 with Forward Plus renderer enabled in [project.godot](project.godot).
- Main scene: `res://game/main.tscn`.
- Autoload singletons:
  - `Events`
  - `MusicPlayer`
  - `SfxPlayer`
- A Git repository exists here, but agents MUST NOT use mutating Git commands. Only read-only Git commands are allowed. User will run all mutating Git commands manually. THIS IS A STRICT RULE.
- Never attempt to exploit your limitations by creating some scripts to avoid restrictions. Instead inform the user about it and suggest the possible solutions.
- If you can by any chance do something that is potentially destructive, always ask for very explicit approval from the user.

## Top-Level Structure

- `assets/`: art, fonts, music, and sound effects. Use placeholder textures for prototypes; the user will replace them manually later.
- `db/`: enum-based registries that map keys to resource or scene paths.
- `docs/`: handwritten project notes. Currently only `docs/creadits.md`.
- `game/`: gameplay scenes, managers, components, entities, views, tilesets, and the main scene.
- `globals/`: autoload singletons and global event definitions.
- `helpers/`: reusable scene/runtime helpers. Currently `ViewLoader`.
- `localization/`: source CSV plus generated translation files.
- `shaders/`: shader assets. Currently vignette post-processing shader.
- `ui/`: reusable UI scenes and theme resources.
- `.godot/`: editor/import cache. Treat as generated, not hand-authored source.

## Runtime Flow

- [game/main.tscn](game/main.tscn) is the root scene. It owns `Main`, generic `ViewRoot`, `ViewLoader`, and global vignette post-processing.
- `Main` emits `Events.VIEW_load_view` on startup instead of instantiating the main view directly.
- `Main` currently loads `ViewDb.Keys.GAME`.
- `ViewLoader` listens to view events, owns a persistent high-resolution `LoadingView`, uses `ResourceLoader.load_threaded_request`, inserts the requested view scene into `ViewRoot`, and emits `Events.VIEW_view_loaded` after insertion.
- `LoadingView` is a utility overlay exception to the top-level `*View` page rule; other `*View` scenes are main sections and only one should be loaded at a time.
- Current registered views live in [db/view_db.gd](db/view_db.gd):
  - `LOADING`
  - `GAME`
- `GameView` owns game-only rendering and UI: `PixelViewportContainer` displays `WorldViewport`, which renders gameplay through `WorldRoot` at an effective 480x270 pixel-art resolution and integer-scales it to the window.
- Pixel-art rendering uses nearest filtering, transform snapping, and no vertex snapping for `WorldViewport`; keep this combination unless replacing the low-resolution viewport strategy.
- `GameView` currently owns gameplay-local managers, world content, and HUD:
  - `Managers/WalletManager`
  - `PixelViewportContainer/WorldViewport/WorldRoot/ForestMap`
  - `PixelViewportContainer/WorldViewport/WorldRoot/Player`
  - `HUD`
- Player vitals are local to the player scene. `PlayerVitalsController` owns alive/dead state, wraps `HpComp`, and emits player vitals events. `GameView` owns initial spawn and restart respawn requests because it has both the player and map `RespawnPoint`.

## Current Code Patterns

### Event Bus

- Cross-system communication goes through the `Events` autoload in [globals/events.gd](globals/events.gd).
- Signal names are namespaced by domain prefix, for example:
  - `VIEW_*`
  - `WALLET_*`
  - `PLAYER_*`
- Prefer adding a domain-specific signal to `Events` for decoupled communication instead of hard references between unrelated nodes.
- Wallet changes use wallet events: spend requests use `WALLET_money_spend_requested`, sync requests use `WALLET_sync_requested`, and UI sync uses `WALLET_money_changed`.
- View loading completion uses `VIEW_view_loaded`; high-resolution UI that depends on gameplay-local managers should wait for this signal before requesting sync.
- Player vitals use player events for HP changes, death requests, death completion, respawn requests, and respawn completion.

### DB Registry Pattern

- Files in `db/` use an enum `Keys` plus dictionaries that map keys to resource paths or scene paths.
- Access is exposed through static getters like `get_view_scene`, `get_music_stream`, `get_item_resource`, and `get_item_scene`.
- `_template_db.gd` is the reference shape for new registry files.
- When adding a new shared resource set, follow this DB pattern instead of scattering raw `res://...` strings across gameplay code.
- Current registries are `ViewDb`, `MusicDb`, and `ItemDb`.
- `ItemDb` currently has placeholder keys with empty resource and scene paths. Do not assume items are fully wired.

### Scene and Script Layout

- Folder names use `snake_case`.
- Reusable script classes use `class_name` with `PascalCase`.
- Scene scripts stay close to their scene folder.
- UI and scene scripts use `%UniqueNodeName` lookups for important child nodes when the scene marks them `unique_name_in_owner = true`.
- Full-viewport `Control` nodes under `CanvasLayer` must use full-rect layout metadata (`layout_mode = 3` plus anchors) so text controls get valid geometry during scene insertion.
- Player locomotion uses composition: `Player` owns public facing/animation API, while a child `PlayerMovementController` owns velocity physics and `move_and_slide()`. Future directional gameplay should read `Player.facing_direction`, not sprite flip state.
- Player vitals use composition: `PlayerVitalsController` owns HP and alive/dead state. Dead players keep gravity and `move_and_slide()` but ignore movement input.
- `HpComp` is a reusable component with local `hp_changed` and `hp_depleted` signals.
- Damage collision uses reusable `HitboxComp` and `HurtboxComp` Area2D components under `game/components/`. Hitboxes own damage/cooldown and call hurtboxes; hurtboxes forward hits to their damage receiver through `receive_hit(damage, source_position, hitbox)`. Keep object/player-specific reactions on the receiver, not in the shared components.

### Resources and Data

- `EntityRes` is the base resource type for entity-like data.
- `ItemRes` extends `EntityRes` and holds shop-facing item data such as description, icon, and base price.

### Audio

- Long-lived audio systems are autoload scenes in `globals/`.
- `MusicPlayer` manages playlist playback and crossfading between two `AudioStreamPlayer` nodes.
- `SfxPlayer` reuses a pool of `AudioStreamPlayer` children and grows the pool only when all players are busy.
- Music keys and file paths belong in `MusicDb`, not inline in gameplay code.
- `SfxPlayer` currently uses a local `sounds` dictionary and direct `AudioStream` playback helpers. There is no SFX DB yet.

### UI

- Shared UI lives under `ui/`; game-specific UI lives with the owning game view.
- `ui/theme.tres` is the project-wide `Control` theme via `project.godot` and owns the default Pixel Operator font.
- Game HUD lives under `game/views/game_view/hud/`, is event-driven, and lives outside the low-resolution gameplay viewport. It requests wallet sync after the game view reports loaded, then renders values from wallet events.
- HUD HP and death UI listen to player vitals events. `DeadScreen` is hidden by default, shown on player death, and hidden on respawn.

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
- But also, don't overengineer. Try to keep the great balance between ideal code and amount of changes.
- Prefer explicit type annotations for variables, constants, function arguments, return values, arrays, dictionaries, and node lookups. Avoid relying on inferred types; only break this rule for highly specific cases where explicit typing clearly makes the code worse.
- Prefer composition over inheritance in most cases, except the places where inheritance is already an established approach.

## Verification Expectations

- There are no automated tests in this project today.
- User handles Godot runtime checks and playtesting manually.
- Agents should not check whether Godot environment is ready unless user explicitly asks for that.
