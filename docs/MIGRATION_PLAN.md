#!/bin/bash

################################################################################
# Horimiya Prototype Theme - Architecture Migration Plan
# From: wlogout-images (simple theme library)
# To: horimiya-prototype-theme (comprehensive environment theming)
#
# Vision: Unified, wallust-integrated personal environment theme system
# Author: Lead Developer
# Date: 2026-07-20
################################################################################

cat << 'EOF'

╔════════════════════════════════════════════════════════════════════════════╗
║        HORIMIYA PROTOTYPE THEME - ARCHITECTURE MIGRATION PLAN               ║
║     Comprehensive Personal Environment Theming Infrastructure              ║
╚════════════════════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. REBRANDING & VISION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

OLD PROJECT: wlogout-images
  • Limited scope: wlogout themes only
  • Static assets: icons, layouts, styles
  • Single-component installer

NEW PROJECT: horimiya-prototype-theme
  • Comprehensive scope: wlogout, terminal, wallust integration
  • Dynamic generation: color-driven templates
  • Multi-component installer with granular selection
  • Unified personal environment theming

CORE VALUES:
  ✓ Consistency across all applications
  ✓ Color-driven design (wallust integration)
  ✓ Modularity and composability
  ✓ Enterprise-grade DevOps practices
  ✓ User autonomy (choose what to install)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
2. NEW PROJECT STRUCTURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

horimiya-prototype-theme/
├── .github/
│   └── workflows/
│       └── validate-themes.yml
│
├── scripts/
│   ├── install.sh                [REFACTORED - Multi-component support]
│   ├── uninstall.sh
│   ├── switch-theme.sh
│   ├── apply-theme.sh            [NEW - Apply colors to templates]
│   ├── detect-wallust.sh          [NEW - Wallust detection]
│   └── lib/
│       ├── common.sh
│       ├── logging.sh
│       ├── backup.sh
│       ├── validation.sh
│       ├── components.sh          [NEW - Component management]
│       └── wallust.sh             [NEW - Wallust integration]
│
├── components/
│   ├── wlogout/
│   │   ├── theme.json
│   │   ├── layout.json
│   │   ├── templates/
│   │   │   ├── style.css.j2       [NEW - Jinja2 template with wallust vars]
│   │   │   └── style.css.static   [Fallback: static stylesheet]
│   │   └── icons/
│   │       └── [6 PNG files]
│   │
│   ├── terminal/                  [NEW - Terminal emulator configs]
│   │   ├── kitty/
│   │   │   ├── theme.json
│   │   │   ├── templates/
│   │   │   │   └── kitty.conf.j2  [Jinja2 template]
│   │   │   └── kitty.conf.static  [Fallback]
│   │   │
│   │   ├── alacritty/
│   │   │   ├── theme.json
│   │   │   ├── templates/
│   │   │   │   └── alacritty.yml.j2
│   │   │   └── alacritty.yml.static
│   │   │
│   │   └── foot/                  [Future]
│   │       └── ...
│   │
│   └── shell/                     [NEW - Shell configurations]
│       ├── zsh/
│       │   ├── templates/
│       │   │   └── colorscheme.zsh.j2
│       │   └── colorscheme.zsh.static
│       │
│       └── bash/
│           └── ...
│
├── themes/
│   ├── default/
│   │   ├── colors.json            [Core color palette]
│   │   ├── metadata.json          [Theme metadata]
│   │   └── components/
│   │       ├── wlogout/           [Symlink to components/wlogout]
│   │       ├── terminal/
│   │       └── shell/
│   │
│   ├── dark/
│   │   └── ...
│   │
│   └── nord/
│       └── ...
│
├── wallust/                       [NEW - Wallust integration]
│   ├── config.toml.j2             [Wallust config template]
│   └── colorscheme.toml           [Sample colorscheme]
│
├── docs/
│   ├── ARCHITECTURE.md            [Updated]
│   ├── INSTALLATION_GUIDE.md      [Updated]
│   ├── MIGRATION_GUIDE.md         [NEW - For wlogout-images users]
│   ├── COMPONENTS.md              [NEW - Component documentation]
│   ├── WALLUST_INTEGRATION.md     [NEW - Wallust guide]
│   ├── TEMPLATE_VARIABLES.md      [NEW - Available template vars]
│   └── DEVELOPING_COMPONENTS.md   [NEW - How to create components]
│
├── tests/
│   ├── test-install.sh
│   ├── test-components.sh         [NEW]
│   ├── test-templates.sh          [NEW]
│   └── fixtures/
│
├── README.md                      [REBRANDED]
├── CONTRIBUTING.md
├── LICENSE
└── .gitignore

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
3. WALLUST INTEGRATION ARCHITECTURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A) WALLUST VARIABLE SYSTEM
────────────────────────────────────────────────────────────────────────────

Template Variables (Jinja2 format):

  {{ foreground }}        - Primary text color
  {{ background }}        - Primary background
  {{ color0 }}            - Black
  {{ color1 }}            - Red (accent 1)
  {{ color2 }}            - Green (accent 2)
  {{ color3 }}            - Yellow (accent 3)
  {{ color4 }}            - Blue (accent 4)
  {{ color5 }}            - Magenta (accent 5)
  {{ color6 }}            - Cyan (accent 6)
  {{ color7 }}            - White
  {{ cursor_color }}      - Cursor color
  {{ cursor_text }}       - Cursor text color
  
Example wlogout style.css.j2:
  
  button {
    background-color: {{ color4 }};
    color: {{ foreground }};
    border: 1px solid {{ color5 }};
  }
  
  button:hover {
    background-color: {{ color5 }};
    box-shadow: 0 0 20px {{ color4 }};
  }

B) WALLUST WORKFLOW
────────────────────────────────────────────────────────────────────────────

1. User installs wallust: wallust colorscheme-from-image image.jpg
   └─> Generates: ~/.config/wallust/colorscheme.toml

2. Horimiya theme detection:
   └─> Check if wallust is installed
   └─> Read ~/.config/wallust/colorscheme.toml
   └─> Extract color values

3. Template rendering:
   └─> Load *.j2 templates
   └─> Inject wallust variables
   └─> Generate final config files

4. Application configuration:
   └─> Deploy rendered files to ~/.config/wlogout/
   └─> Deploy to ~/.config/kitty/
   └─> Deploy to ~/.config/alacritty/

5. (Optional) Live reload:
   └─> Trigger wlogout reload if running
   └─> Signal terminal emulator to reload

C) FALLBACK MECHANISM
────────────────────────────────────────────────────────────────────────────

If wallust is not installed:
  1. Try to use static CSS/config files (.static extension)
  2. Prompt user to install wallust for dynamic theming
  3. Provide manual wallust installation guide

If wallust is installed but no colorscheme:
  1. Generate default colorscheme
  2. Show instructions for creating custom colorscheme

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
4. MULTI-COMPONENT INSTALLATION SYSTEM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A) COMPONENT REGISTRY
────────────────────────────────────────────────────────────────────────────

Components are modular, installable system parts:

┌─────────────────────────────────────────────────────────────────────────┐
│ WLOGOUT - Logout/Power Menu Theme                                       │
├─────────────────────────────────────────────────────────────────────────┤
│ Location: ~/.config/wlogout/                                             │
│ Files: layout, style.css, icons/                                         │
│ Dependencies: wlogout (binary), wallust (optional)                        │
│ Symlink Support: Yes (icons, templates)                                  │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ TERMINAL - Terminal Emulator Configuration                              │
├─────────────────────────────────────────────────────────────────────────┤
│ Sub-components:                                                          │
│   • kitty: ~/.config/kitty/theme.conf                                    │
│   • alacritty: ~/.config/alacritty/colors.toml                           │
│   • foot: ~/.config/foot/colors                                          │
│                                                                           │
│ Features:                                                                 │
│   - Install all or individual terminal configs                           │
│   - Auto-detect installed terminal emulators                             │
│   - Fallback to defaults if emulator not installed                       │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ SHELL - Shell Configuration & Colorschemes                              │
├─────────────────────────────────────────────────────────────────────────┤
│ Sub-components:                                                          │
│   • zsh: ~/.config/zsh/horimiya-colors.zsh                               │
│   • bash: ~/.bashrc.d/horimiya-colors.sh                                 │
│                                                                           │
│ Features:                                                                 │
│   - Export color variables for shell scripts                             │
│   - Prompt color customization                                           │
│   - LS_COLORS generation                                                 │
└─────────────────────────────────────────────────────────────────────────┘

B) INSTALLATION FLAGS
────────────────────────────────────────────────────────────────────────────

# Install all components
./scripts/install.sh --all

# Install specific components
./scripts/install.sh --wlogout
./scripts/install.sh --terminal
./scripts/install.sh --shell

# Install terminal sub-components
./scripts/install.sh --terminal kitty
./scripts/install.sh --terminal alacritty
./scripts/install.sh --terminal "kitty alacritty"

# Install with theme
./scripts/install.sh --all --theme nord
./scripts/install.sh --wlogout --terminal --theme dracula

# Advanced options
./scripts/install.sh --all --theme dark --yes --add-hyprland --wallust
./scripts/install.sh --all --dry-run --verbose

C) COMPONENT MANIFEST
────────────────────────────────────────────────────────────────────────────

~/.local/state/horimiya-installer/manifest.json:

{
  "schema_version": "2.0.0",
  "installed_components": [
    {
      "name": "wlogout",
      "version": "1.0.0",
      "installed_at": "2026-07-20T14:30:00Z",
      "config_dir": "~/.config/wlogout",
      "files": [
        {"path": "~/.config/wlogout/layout", "type": "symlink"},
        {"path": "~/.config/wlogout/style.css", "type": "generated"},
        {"path": "~/.config/wlogout/icons", "type": "symlink"}
      ]
    },
    {
      "name": "terminal",
      "version": "1.0.0",
      "installed_at": "2026-07-20T14:30:15Z",
      "sub_components": ["kitty", "alacritty"],
      "files": [
        {"path": "~/.config/kitty/theme.conf", "type": "generated"},
        {"path": "~/.config/alacritty/colors.toml", "type": "generated"}
      ]
    },
    {
      "name": "shell",
      "version": "1.0.0",
      "installed_at": "2026-07-20T14:30:30Z",
      "sub_components": ["zsh"],
      "files": [
        {"path": "~/.config/zsh/horimiya-colors.zsh", "type": "generated"}
      ]
    }
  ],
  "wallust": {
    "enabled": true,
    "colorscheme_path": "~/.config/wallust/colorscheme.toml",
    "version": "1.1.0"
  },
  "theme": "nord"
}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
5. TEMPLATE RENDERING ENGINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A) RENDERING FLOW
────────────────────────────────────────────────────────────────────────────

1. Detect wallust and read colors
   ↓
2. For each component:
   a) Check if *.j2 template exists
   b) Load template
   c) Prepare rendering context (colors + component-specific vars)
   d) Render with Jinja2 or fallback to sed/envsubst
   e) Write to target location
   f) Record in manifest
   ↓
3. Verify all files were created
   ↓
4. Return success/failure status

B) RENDERING CONTEXT STRUCTURE
────────────────────────────────────────────────────────────────────────────

context = {
  # Wallust colors
  "foreground": "#e0def4",
  "background": "#191724",
  "color0": "#26233a",
  "color1": "#eb6f92",
  ...
  
  # Component-specific variables
  "component": "wlogout",
  "theme": "dark",
  
  # User variables
  "username": "hussinchahin435",
  "hostname": "fedora",
  
  # Horimiya metadata
  "version": "2.0.0",
  "install_date": "2026-07-20"
}

C) FALLBACK RENDERING
────────────────────────────────────────────────────────────────────────────

If Jinja2 not available, use envsubst or sed:

  envsubst < template.j2 > output.conf
  
This works with simpler templates but requires exact variable names:
  ${foreground} instead of {{ foreground }}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
6. UPDATED INSTALL.SH ARCHITECTURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

New Flow:

  ┌─────────────────────────────────────────┐
  │ Parse Arguments                         │
  │ (--wlogout, --terminal, --all, etc.)    │
  └────────────────┬────────────────────────┘
                   ↓
  ┌─────────────────────────────────────────┐
  │ Initialize (logging, directories)       │
  └────────────────┬────────────────────────┘
                   ↓
  ┌─────────────────────────────────────────┐
  │ Check Dependencies                      │
  │ (Required, Optional, Suggested)         │
  └────────────────┬────────────────────────┘
                   ↓
  ┌─────────────────────────────────────────┐
  │ Detect & Configure Wallust              │
  │ (Read colorscheme if available)         │
  └────────────────┬────────────────────────┘
                   ↓
  ┌─────────────────────────────────────────┐
  │ Interactive Setup (if not --yes)        │
  │ (Select components, theme, etc.)        │
  └────────────────┬────────────────────────┘
                   ↓
  ┌─────────────────────────────────────────┐
  │ Create Backup                           │
  │ (Save existing configs)                 │
  └────────────────┬────────────────────────┘
                   ↓
  ┌─────────────────────────────────────────┐
  │ Install Selected Components             │
  │ (Render templates, create symlinks)     │
  └────────────────┬────────────────────────┘
                   ↓
  ┌─────────────────────────────────────────┐
  │ Verify Installation                     │
  │ (Check all files, test permissions)     │
  └────────────────┬────────────────────────┘
                   ↓
  ┌─────────────────────────────────────────┐
  │ Optional: Hyprland Integration          │
  │ (Add keybindings if --add-hyprland)     │
  └────────────────┬────────────────────────┘
                   ↓
  ┌─────────────────────────────────────────┐
  │ Create Manifest                         │
  │ (Record all installation details)       │
  └────────────────┬────────────────────────┘
                   ↓
  ┌─────────────────────────────────────────┐
  │ Success Report                          │
  │ (Show what was installed)               │
  └─────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
7. EXAMPLE USAGE AFTER MIGRATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Install everything (wlogout + terminal emulators + shell)
$ ./scripts/install.sh --all --wallust

# Install just wlogout with dynamic wallust theming
$ ./scripts/install.sh --wlogout --wallust

# Install specific terminal emulator config
$ ./scripts/install.sh --terminal kitty

# Install multiple components
$ ./scripts/install.sh --wlogout --terminal alacritty --shell zsh

# Non-interactive with specific theme
$ ./scripts/install.sh --all --theme nord --yes

# Preview without making changes
$ ./scripts/install.sh --all --theme dracula --dry-run --verbose

# Detect installed components and auto-install for them
$ ./scripts/install.sh --all --auto-detect

# View current installation status
$ ./scripts/status.sh

# Switch theme (re-renders all templates)
$ ./scripts/switch-theme.sh dark

# Apply wallust colorscheme to all components
$ ./scripts/apply-theme.sh --wallust

# Uninstall specific component
$ ./scripts/uninstall.sh --wlogout

# Uninstall everything and restore backup
$ ./scripts/uninstall.sh --all

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
8. IMPLEMENTATION ROADMAP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Phase 1: Core Migration (THIS SESSION)
  ☐ Create components/ directory structure
  ☐ Create templates/ with Jinja2 templates
  ☐ Create wallust/ integration directory
  ☐ Create scripts/lib/components.sh
  ☐ Create scripts/lib/wallust.sh
  ☐ Create scripts/apply-theme.sh
  ☐ Refactor scripts/install.sh for multi-component
  ☐ Update manifests to support components
  ☐ Create MIGRATION_GUIDE.md

Phase 2: Template Development
  ☐ Create wlogout/templates/style.css.j2
  ☐ Create terminal/kitty/templates/kitty.conf.j2
  ☐ Create terminal/alacritty/templates/alacritty.yml.j2
  ☐ Create shell/zsh/templates/colorscheme.zsh.j2
  ☐ Create fallback .static files

Phase 3: Testing & Documentation
  ☐ Create comprehensive tests
  ☐ Write COMPONENTS.md
  ☐ Write WALLUST_INTEGRATION.md
  ☐ Write TEMPLATE_VARIABLES.md
  ☐ Create CI/CD pipeline

Phase 4: User Experience
  ☐ Create interactive component selector
  ☐ Create theme preview system
  ☐ Create status.sh script
  ☐ Create apply-theme.sh refinement

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
9. KEY DESIGN DECISIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Why Jinja2 templates?
   • Industry standard for configuration templating
   • More powerful than simple variable substitution
   • Allows conditionals, loops, filters
   • Future-proof for complex theming

2. Why component-based architecture?
   • Users install only what they need
   • Reduces disk footprint
   • Simplifies updates (update one component at a time)
   • Clear separation of concerns

3. Why wallust integration?
   • Solves the "color cohesion" problem
   • Single source of truth for colors
   • Professional, enterprise-grade theming
   • Colors automatically match wallpaper

4. Why manifest-based tracking?
   • Deterministic uninstalls
   • Clear audit trail
   • Easy rollback
   • Supports partial uninstalls

5. Why fallback to .static files?
   • Works even if Jinja2 not installed
   • Provides sensible defaults
   • Reduces dependencies
   • Graceful degradation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
10. SUCCESS CRITERIA
━━━━━��━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Single command installs complete themed environment
✓ Components can be selected independently
✓ Wallust integration is seamless and automatic
✓ Color changes propagate across all components
✓ Rollback works perfectly
✓ Dry-run shows exactly what will be done
✓ Clear logging for debugging
✓ Performance is instant (< 2 seconds for full install)
✓ Works on Fedora 40+ and Ubuntu 24.04+
✓ No breaking changes for wlogout-images users

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
