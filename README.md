# Godot 2D Game Template

A comprehensive template for creating 2D games with Godot 4.5. This template provides a solid foundation with organized project structure, built-in systems, and best practices for game development.

## 🎮 Features

- **Organized Project Structure** - Clean folder organization with color-coded directories
- **View Management System** - Easy scene switching and loading with enum-based keys
- **Event System** - Global event bus for decoupled communication between components
- **Audio Management** - Built-in music and SFX players with autoload
- **Database System** - Centralized resource management with enum-based access
- **Localization Support** - Multi-language support with CSV-based translations
- **UI Framework** - HUD system and theme management
- **Entity System** - Base classes for game entities and items
- **Wallet System** - Built-in economy management
- **Loading System** - Professional loading screens with progress tracking

## 📁 Project Structure

```
godot-2d-game-template/
├── assets/                 # 🟠 Game assets (art, audio, fonts)
│   ├── art/               # Sprites, textures, and visual assets
│   ├── audio/             # Music and sound effects
│   └── fonts/             # Custom fonts
├── db/                    # 🟢 Database and resource management
│   ├── item_db.gd         # Item definitions and management
│   ├── music_db.gd        # Music track definitions
│   └── view_db.gd         # Scene/view definitions
├── docs/                  # 🔘 Documentation
├── game/                  # 🟡 Core game logic
│   ├── components/        # Reusable game components
│   ├── entities/          # Game entities and items
│   ├── managers/          # Game state managers
│   ├── views/             # Game scenes and views
│   └── main.gd            # Main game entry point
├── globals/               # 🔴 Global systems and autoloads
│   ├── events.gd          # Global event bus
│   ├── music_player/      # Music management
│   └── sfx_player/        # Sound effects management
├── helpers/               # Utility scripts
├── localization/          # Translation files
├── shaders/               # Custom shaders
└── ui/                    # 🟣 User interface components
	├── hud/               # Heads-up display
	└── theme.tres         # UI theme
```

## 🚀 Getting Started

### Prerequisites

- **Godot 4.5** or later
- Basic knowledge of GDScript and Godot

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/godot-2d-game-template.git
   cd godot-2d-game-template
   ```

2. **Make it your own:**
   ```bash
   # Remove the existing git history
   rm -rf .git

   # Initialize your own repository
   git init
   git add .
   git commit -m "Initial commit from template"
   ```

3. **Open in Godot:**
   - Launch Godot 4.5
   - Click "Import" and select the project folder
   - The project will open with all systems ready to use

## 🛠️ Core Systems

### View Management

The template includes a robust view management system that handles scene transitions:

```gdscript
# Load a view by enum key
Events.VIEW_load_view.emit(ViewDb.Keys.GAME)

# Show loading screen with progress
Events.VIEW_show_loading_view.emit(0.5)  # 50% progress
Events.VIEW_show_loading_text.emit("Loading assets...")
Events.VIEW_hide_loading_view.emit()
```

### Event System

Global events for decoupled communication:

```gdscript
# Listen to events
Events.WALLET_money_changed.connect(_on_money_changed)

# Emit events
Events.WALLET_money_spend_requested.emit(100, _on_spend_complete)
```

### Database System

Centralized resource management using enums:

```gdscript
# Get a view scene
var game_scene = ViewDb.get_view_scene(ViewDb.Keys.GAME)

# Get item data
var item_data = ItemDb.get_item(ItemDb.Keys.SOME_ITEM)
```

### Audio Management

Built-in audio players with autoload:

```gdscript
# Play music
MusicPlayer.play_music(MusicDb.Keys.MAIN_THEME)

# Play sound effect
SfxPlayer.play_sfx(SfxDb.Keys.JUMP)
```

## 🎨 Customization

### Adding New Views

1. Create your scene in `game/views/`
2. Add the enum key to `db/view_db.gd`:
   ```gdscript
   enum Keys {
	   LOADING,
	   GAME,
	   YOUR_NEW_VIEW,  # Add here
   }
   ```
3. Add the scene path to `VIEW_SCENE_PATHS`

### Adding New Items

1. Create item resources in `game/entities/items/`
2. Add enum keys to `db/item_db.gd`
3. Define item properties and behaviors

### Localization

1. Add translation keys to `localization/translation_keys.csv`
2. Create translation files for each language
3. Use `tr()` function in your code

## 📝 Development Guidelines

### Code Organization

- **Components**: Reusable game logic in `game/components/`
- **Entities**: Game objects in `game/entities/`
- **Managers**: State management in `game/managers/`
- **Views**: UI scenes in `game/views/`

### Naming Conventions

- **Files**: snake_case (e.g., `player_controller.gd`)
- **Classes**: PascalCase (e.g., `PlayerController`)
- **Variables**: snake_case (e.g., `player_health`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_HEALTH`)

### Best Practices

- Use the event system for communication between systems
- Keep scenes modular and reusable
- Use the database system for resource management
- Follow the established folder structure

## 🎯 Template Features

### Built-in Systems

- **Loading System**: Professional loading screens with progress bars
- **Wallet System**: Economy management with money tracking
- **Audio System**: Music and SFX management with fade effects
- **View System**: Scene management with smooth transitions
- **Event System**: Decoupled communication between components

### Asset Management

- **Organized Assets**: Color-coded folders for easy navigation
- **Resource Database**: Centralized resource management
- **Import Settings**: Optimized import configurations

### UI Framework

- **Theme System**: Consistent UI styling
- **HUD System**: Ready-to-use heads-up display
- **Loading UI**: Professional loading screens

## 🤝 Contributing

This is a template project, but if you find bugs or have suggestions for improvements:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This template is provided **AS-IS** for educational and development purposes. You are free to use, modify, and distribute your games created with this template.

### Music Attribution

The track `daisy_dance.mp3` (located in `assets/audio/music/`) is created by **Dean Red** and is included in this template for demonstration purposes. You are not required to use this track in your projects.

**If you choose to use `daisy_dance.mp3` in your project:**

**What's Allowed:**
- ✅ **Free to use** in any project (games, videos, apps, etc.)
- ✅ **Commercial use** allowed
- ✅ **Modification allowed** (remix, edit, etc.)
- ✅ **Include in your projects** (games, videos, applications)

**What's Required:**
- ❌ **Credits mandatory** - You MUST credit Dean Red as the original author
- ❌ **No standalone distribution** - Do not distribute the track separately from your project
- ❌ **No false attribution** - Do not claim the track as your own or attribute it to other authors

**How to credit Dean Red:**
- Include "Music: Dean Red" in your project's credits
- Add a mention in your project's documentation or README
- Credit in any promotional materials if the track is featured

**Example credit format:**
```
Music: Dean Red - "Daisy Dance"
```

**Important:** The author of this track must always be clearly identified as Dean Red. You cannot claim ownership or attribute it to anyone else.

## 🙏 Acknowledgments

- Built with [Godot Engine](https://godotengine.org/)
- Designed for 2D game development

---

**Happy Game Development! 🎮**
