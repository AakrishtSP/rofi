# Rofi Setup Scripts

This directory contains automated setup scripts for configuring Rofi themes, options, and styles.

## Scripts Overview

### Main Scripts
- **`setup-rofi.sh`** - Main setup wizard that guides you through configuring Rofi
- **`rofi-setup-check.sh`** - Environment check script that verifies all dependencies

### Component Scripts  
- **`rofi-color-palette-switcher.sh`** - Interactive color theme selector
- **`rofi-options-selector.sh`** - Options manager (icons, zebra, transparency, etc.)
- **`rofi-style-switcher.sh`** - Style layout selector (grid, list, compact, etc.)

## Quick Start

1. **Run environment check** (optional but recommended):
   ```bash
   ./rofi-setup-check.sh
   ```

2. **Run the main setup wizard**:
   ```bash
   ./setup-rofi.sh
   ```

3. **Or run individual components**:
   ```bash
   ./rofi-color-palette-switcher.sh    # Colors only
   ./rofi-options-selector.sh          # Options only  
   ./rofi-style-switcher.sh            # Styles only
   ```

## Setup Process

The main wizard (`setup-rofi.sh`) guides you through 3 steps:

1. **🎨 Color Theme Selection** - Choose from available color themes
2. **⚙️ Options Configuration** - Enable/disable features like icons, zebra stripes, transparency
3. **🎭 Style Layout Selection** - Pick your preferred layout (grid, list, compact, etc.)

Each step includes:
- Preview functionality to see changes in real-time
- Ability to go back and change selections
- Option to cancel at any time

## Features

- **Interactive GUI** - All interactions use Rofi itself for a native experience
- **Preview Support** - See changes before applying them
- **Backup & Restore** - Automatic backup of current settings
- **Error Handling** - Graceful handling of cancellations and errors
- **Modular Design** - Each component can be run independently

## Requirements

- **Rofi** - The application launcher itself
- **notify-send** - For desktop notifications (optional)
- **Bash** - Shell scripting environment

## Directory Structure

The scripts expect the following rofi configuration structure:
```
~/.config/rofi/
├── colors/          # Color theme files (*.rasi)
├── styles/          # Style layout files (*.rasi)  
├── options/         # Option configuration files
├── menu/            # Menu theme files
├── scripts/         # These setup scripts
├── config.rasi      # Main rofi configuration
├── color.rasi       # Current color theme import
└── style.rasi       # Current style layout import
```

## Troubleshooting

If you encounter issues:

1. **Run the environment check**:
   ```bash
   ./rofi-setup-check.sh
   ```

2. **Check script permissions**:
   ```bash
   ls -la *.sh
   ```
   All scripts should be executable (`-rwxr-xr-x`)

3. **Make scripts executable if needed**:
   ```bash
   chmod +x *.sh
   ```

4. **Verify rofi installation**:
   ```bash
   rofi -version
   ```

## Exit Codes

All scripts return standard exit codes:
- `0` - Success (selection applied)
- `1` - Cancelled by user or error occurred

## Notes

- The setup wizard creates backups of your current configuration
- You can cancel at any time and your original settings will be restored
- Individual scripts can be run multiple times safely
- Desktop notifications require `notify-send` to be installed
