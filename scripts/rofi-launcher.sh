#!/bin/bash

# Rofi Setup Launcher - Quick access to all setup tools
# Usage: ./rofi-launcher.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to show the main launcher menu
show_launcher_menu() {
    local menu_text="🎨 Rofi Configuration Tools

Choose what you want to configure:

🧭 Full Setup Wizard - Complete guided setup
🎨 Color Themes Only - Change color theme
⚙️  Options Only - Configure features
🎭 Styles Only - Change layout style
────────────────────────────────────────────────────────────────
🔍 Environment Check - Verify setup requirements
📖 Help & Documentation"
    
    local choice=$(echo "$menu_text" | \
        rofi -dmenu \
            -config ~/.config/rofi/menu/theme-switcher.rasi \
            -p "🎨 Rofi Setup Tools" \
            -lines 12 \
            -width 60 \
            -no-custom \
            -selected-row 3 \
            -kb-cancel "Escape,Alt+F4" \
            -mesg "Select a tool to launch")
    
    local exit_code=$?
    
    # Handle Escape key or window close
    if [[ $exit_code -ne 0 ]]; then
        exit 0
    fi
    
    # Handle user selection
    case "$choice" in
        "🧭 Full Setup Wizard - Complete guided setup"|"")
            exec "$SCRIPT_DIR/setup-rofi.sh"
            ;;
        "🎨 Color Themes Only - Change color theme")
            exec "$SCRIPT_DIR/rofi-color-palette-switcher.sh"
            ;;
        "⚙️  Options Only - Configure features")
            exec "$SCRIPT_DIR/rofi-options-selector.sh"
            ;;
        "🎭 Styles Only - Change layout style")
            exec "$SCRIPT_DIR/rofi-style-switcher.sh"
            ;;
        "🔍 Environment Check - Verify setup requirements")
            exec "$SCRIPT_DIR/rofi-setup-check.sh"
            ;;
        "📖 Help & Documentation")
            show_help_menu
            ;;
        *)
            # User selected description or separator lines
            show_launcher_menu
            ;;
    esac
}

# Function to show help menu
show_help_menu() {
    local help_text="📖 Rofi Setup Help

Quick Reference:

🧭 Full Setup Wizard
   • Guided 3-step configuration process
   • Colors → Options → Styles
   • Includes preview functionality

🎨 Color Themes
   • Choose from 30+ color themes
   • Live preview with Space key
   • Enter to apply, Escape to cancel

⚙️  Options Configuration  
   • Toggle icons, zebra stripes, transparency
   • Border radius, and other features
   • Changes apply immediately

🎭 Style Layouts
   • Grid, list, compact layouts
   • Different icon configurations
   • Preview with Space key

🔍 Environment Check
   • Verifies all requirements
   • Checks themes and dependencies
   • Run before first setup

────────────────────────────────────────────────────────────────

↩️  Back to Main Menu
🏠 Exit"
    
    local choice=$(echo "$help_text" | \
        rofi -dmenu \
            -config ~/.config/rofi/menu/theme-switcher.rasi \
            -p "📖 Help & Documentation" \
            -lines 20 \
            -width 70 \
            -no-custom \
            -selected-row 32 \
            -kb-cancel "Escape,Alt+F4" \
            -mesg "Information about the setup tools")
    
    local exit_code=$?
    
    # Handle Escape key or window close
    if [[ $exit_code -ne 0 ]]; then
        exit 0
    fi
    
    case "$choice" in
        "↩️  Back to Main Menu"|"")
            show_launcher_menu
            ;;
        "🏠 Exit")
            exit 0
            ;;
        *)
            # User selected description lines
            show_help_menu
            ;;
    esac
}

# Main function
main() {
    # Check if we're in the right directory
    if [[ ! -f "$SCRIPT_DIR/setup-rofi.sh" ]]; then
        echo "Error: setup-rofi.sh not found in $SCRIPT_DIR"
        echo "Please run this script from the rofi scripts directory."
        exit 1
    fi
    
    # Show the launcher menu
    show_launcher_menu
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
