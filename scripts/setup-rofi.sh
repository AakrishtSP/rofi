#!/bin/bash

# Rofi Setup Script - Configure Colors, Options, and Styles
# Usage: ./setup-rofi.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/rofi"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show welcome message in Rofi
show_welcome() {
    local welcome_text="Welcome to Rofi Setup Wizard!

This wizard will configure your Rofi in 3 steps:

🎨 Step 1: Choose Color Theme
⚙️  Step 2: Configure Options (icons, zebra, transparency, etc.)
🎭 Step 3: Select Style Layout

────────────────────────────────────────────────────────────────

▶️  Next: Start Setup
❌ Cancel"
    
    local choice=$(echo "$welcome_text" | \
        rofi -dmenu \
            -config ~/.config/rofi/menu/theme-switcher.rasi \
            -p "🎨 Rofi Setup Wizard" \
            -lines 15 \
            -width 80 \
            -no-custom \
            -selected-row 9 \
            -kb-cancel "Escape,Alt+F4" \
            -mesg "")
    
    local exit_code=$?
    
    # Handle Escape key or window close - this should quit immediately
    if [[ $exit_code -ne 0 ]]; then
        show_cancelled
        exit 0  # Quit completely on Escape
    fi
    
    # Handle user selection
    case "$choice" in
        "▶️  Next: Start Setup"|"")
            return 0  # Continue with setup
            ;;
        "❌ Cancel")
            show_cancelled
            return 1  # User explicitly cancelled
            ;;
        *)
            # User selected something else (like the description lines)
            # Show welcome again to let them select properly
            show_welcome
            return $?
            ;;
    esac
}

# Function to check if required scripts exist
check_dependencies() {
    print_step "Checking dependencies..."
    
    local missing_scripts=()
    
    if [[ ! -f "$SCRIPT_DIR/rofi-color-palette-switcher.sh" ]]; then
        missing_scripts+=("rofi-color-palette-switcher.sh")
    fi
    
    if [[ ! -f "$SCRIPT_DIR/rofi-options-selector.sh" ]]; then
        missing_scripts+=("rofi-options-selector.sh")
    fi
    
    if [[ ! -f "$SCRIPT_DIR/rofi-style-switcher.sh" ]]; then
        missing_scripts+=("rofi-style-switcher.sh")
    fi
    
    if [[ ${#missing_scripts[@]} -gt 0 ]]; then
        print_error "Missing required scripts:"
        for script in "${missing_scripts[@]}"; do
            echo "  - $script"
        done
        echo
        print_error "Please ensure all required scripts are in the scripts directory."
        exit 1
    fi
    
    print_success "All dependencies found!"
    echo
}

# Function to run a script and handle its exit code properly
run_script_with_handling() {
    local script_path="$1"
    local script_name="$2"
    
    # Make sure the script is executable
    chmod +x "$script_path"
    
    # Run the script and capture its exit code
    bash "$script_path"
    local exit_code=$?
    
    # Handle different exit codes
    case $exit_code in
        0)
            return 0  # Success
            ;;
        1)
            return 1  # User cancelled
            ;;
        *)
            print_error "Error occurred during $script_name execution (exit code: $exit_code)"
            return 1  # Treat other codes as cancellation
            ;;
    esac
}

# Function to run color theme selection
setup_colors() {
    print_step "Step 1/3: Selecting Color Theme"
    print_info "Opening color theme selector..."
    
    # Show step indicator in Rofi first
    local step_text="Step 1 of 3: Choose Color Theme

🎨 You're about to select your color theme
⏩ This will open the color palette switcher
✨ Pick any theme and apply it
──────────────────────────────
▶️  Next: Open Color Selector
❌ Cancel"
    
    local choice=$(echo "$step_text" | \
        rofi -dmenu \
            -config ~/.config/rofi/menu/theme-switcher.rasi \
            -p "🎨 Color Selection" \
            -lines 15 \
            -width 80 \
            -no-custom \
            -selected-row 9 \
            -kb-cancel "Escape,Alt+F4" \
            -mesg "")
    
    local exit_code=$?
    
    # Handle Escape key or window close
    if [[ $exit_code -ne 0 ]]; then
        exit 0  # Quit completely on Escape
    fi
    
    case "$choice" in
        "▶️  Next: Open Color Selector"|"")
            # Continue with color selection
            ;;
        "❌ Cancel")
            return 1
            ;;
        *)
            return 1
            ;;
    esac
    
    # Make sure the script is executable
    chmod +x "$SCRIPT_DIR/rofi-color-palette-switcher.sh"
    
    # Run the theme switcher
    if run_script_with_handling "$SCRIPT_DIR/rofi-color-palette-switcher.sh" "color theme selection"; then
        print_success "Color theme selected successfully!"
        
        # Show preview panel
        local preview_result=$(show_preview_panel "Color Theme" "Color theme has been applied to your Rofi interface.")
        return $preview_result
    else
        print_warning "Color theme selection cancelled by user."
        return 1
    fi
}

# Function to run options configuration
setup_options() {
    print_step "Step 2/3: Configuring Options"
    print_info "Opening options configurator..."
    
    # Show step indicator in Rofi first
    local step_text="Step 2 of 3: Configure Options

⚙️  You're about to configure Rofi options
🔧 This includes icons, zebra stripes, transparency, etc.
✨ Toggle any options you want to enable/disable

────────────────────────────────────────────────────────────────

▶️  Next: Open Options Manager
❌ Cancel"
    
    local choice=$(echo "$step_text" | \
        rofi -dmenu \
            -config ~/.config/rofi/menu/theme-switcher.rasi \
            -p "⚙️ Options Configuration" \
            -lines 15 \
            -width 80 \
            -no-custom \
            -selected-row 9 \
            -kb-cancel "Escape,Alt+F4" \
            -mesg "")
    
    local exit_code=$?
    
    # Handle Escape key or window close
    if [[ $exit_code -ne 0 ]]; then
        exit 0  # Quit completely on Escape
    fi
    
    case "$choice" in
        "▶️  Next: Open Options Manager"|"")
            # Continue with options
            ;;
        "❌ Cancel")
            return 1
            ;;
        *)
            return 1
            ;;
    esac
    
    # Make sure the script is executable
    chmod +x "$SCRIPT_DIR/rofi-options-selector.sh"
    
    # Run the options selector
    if run_script_with_handling "$SCRIPT_DIR/rofi-options-selector.sh" "options configuration"; then
        print_success "Options configured successfully!"
        
        # Show preview panel
        local preview_result=$(show_preview_panel "Options Configuration" "Your selected options have been applied to Rofi.")
        return $preview_result
    else
        print_warning "Options configuration cancelled by user."
        return 1
    fi
}

# Function to run style selection
setup_styles() {
    print_step "Step 3/3: Selecting Style Layout"
    print_info "Opening style selector..."
    
    # Show step indicator in Rofi first
    local step_text="Step 3 of 3: Select Style Layout

🎭 You're about to choose your layout style
📐 This includes grid, list, compact, minimal, etc.
✨ Pick the layout that suits your preference

────────────────────────────────────────────────────────────────

▶️  Next: Open Style Selector
❌ Cancel"
    
    local choice=$(echo "$step_text" | \
        rofi -dmenu \
            -config ~/.config/rofi/menu/theme-switcher.rasi \
            -p "🎭 Style Selection" \
            -lines 15 \
            -width 80 \
            -no-custom \
            -selected-row 9 \
            -kb-cancel "Escape,Alt+F4" \
            -mesg "")
    
    local exit_code=$?
    
    # Handle Escape key or window close
    if [[ $exit_code -ne 0 ]]; then
        exit 0  # Quit completely on Escape
    fi
    
    case "$choice" in
        "▶️  Next: Open Style Selector"|"")
            # Continue with style selection
            ;;
        "❌ Cancel")
            return 1
            ;;
        *)
            return 1
            ;;
    esac
    
    # Make sure the script is executable
    chmod +x "$SCRIPT_DIR/rofi-style-switcher.sh"
    
    # Run the style switcher
    if run_script_with_handling "$SCRIPT_DIR/rofi-style-switcher.sh" "style selection"; then
        print_success "Style layout selected successfully!"
        
        # Show preview panel
        local preview_result=$(show_preview_panel "Style Layout" "Your selected style layout has been applied to Rofi.")
        return $preview_result
    else
        print_warning "Style selection cancelled by user."
        return 1
    fi
}

# Function to show completion message in Rofi
show_completion() {
    local completion_text="✅ Color theme configured
✅ Options configured  
✅ Style layout configured

Your Rofi configuration has been successfully set up!

💡 Individual components can be re-run anytime:
   • Colors: ./rofi-color-palette-switcher.sh
   • Options: ./rofi-options-selector.sh
   • Styles: ./rofi-style-switcher.sh

────────────────────────────────────────────────────────────────

▶️  Next: Launch Preview
🏠 Close Setup"
    
    local choice=$(echo "$completion_text" | \
        rofi -dmenu \
            -config ~/.config/rofi/menu/theme-switcher.rasi \
            -p "🎉 Setup Completed!" \
            -lines 18 \
            -width 80 \
            -no-custom \
            -selected-row 14 \
            -mesg "")
    
    case "$choice" in
        "▶️  Next: Launch Preview"|"")
            rofi -show drun &
            ;;
        "🏠 Close Setup")
            # Just close
            ;;
        *)
            # Just close for any other selection
            ;;
    esac
    
    print_success "Rofi setup completed successfully!"
}

# Function to show cancellation message
show_cancelled() {
    echo -e "${YELLOW}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                     SETUP CANCELLED                          ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo "║                                                               ║"
    echo "║  The Rofi setup process was cancelled.                       ║"
    echo "║                                                               ║"
    echo "║  You can run this setup script again anytime:                ║"
    echo "║  ./setup-rofi.sh                                             ║"
    echo "║                                                               ║"
    echo "║  Or configure individual components:                          ║"
    echo "║  - Colors: ./rofi-color-palette-switcher.sh                   ║"
    echo "║  - Options: ./rofi-options-selector.sh                       ║"
    echo "║  - Styles: ./rofi-style-switcher.sh                          ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
}

# Function to handle interruption
handle_interrupt() {
    echo
    print_warning "Setup interrupted by user."
    show_cancelled
    exit 1
}

# Function to show preview panel after selection
show_preview_panel() {
    local step_name="$1"
    local description="$2"
    
    local preview_text="Preview: $step_name

$description

Your selection has been applied and is now active.
You can see the changes in this preview.

────────────────────────────────────────────────────────────────

▶️  Next Step
✅ Keep This Selection
🔄 Choose Again
❌ Cancel Setup"
    
    local choice=$(echo "$preview_text" | \
        rofi -dmenu \
            -config ~/.config/rofi/menu/theme-switcher.rasi \
            -p "👀 Preview: $step_name" \
            -lines 15 \
            -width 80 \
            -no-custom \
            -selected-row 8 \
            -kb-cancel "Escape,Alt+F4" \
            -mesg "")
    
    local exit_code=$?
    
    # Handle Escape key or window close
    if [[ $exit_code -ne 0 ]]; then
        exit 0  # Quit completely on Escape
    fi
    
    case "$choice" in
        "▶️  Next Step"|"✅ Keep This Selection"|"")
            return 0  # Continue to next step
            ;;
        "🔄 Choose Again")
            return 2  # Repeat current step
            ;;
        "❌ Cancel Setup")
            return 1  # Cancel setup
            ;;
        *)
            # User selected description text, show preview again
            show_preview_panel "$step_name" "$description"
            return $?
            ;;
    esac
}

# Main setup function
main() {
    # Set up signal handlers
    trap handle_interrupt SIGINT SIGTERM
    
    # Run environment check first
    print_step "Running environment check..."
    if [[ -f "$SCRIPT_DIR/rofi-setup-check.sh" ]]; then
        if ! bash "$SCRIPT_DIR/rofi-setup-check.sh"; then
            print_error "Environment check failed. Please fix the issues and try again."
            exit 1
        fi
    else
        print_warning "Environment check script not found. Proceeding with basic dependency check..."
        check_dependencies
    fi
    
    # Show welcome message
    if ! show_welcome; then
        exit 0  # Exit cleanly if user cancels welcome
    fi
    
    # Step 1: Colors
    while true; do
        case $(setup_colors) in
            0)
                break  # Continue to next step
                ;;
            2)
                continue  # Repeat this step
                ;;
            *)
                exit 0  # Any other case, exit
                ;;
        esac
    done
    
    # Step 2: Options
    while true; do
        case $(setup_options) in
            0)
                break  # Continue to next step
                ;;
            2)
                continue  # Repeat this step
                ;;
            *)
                exit 0  # Any other case, exit
                ;;
        esac
    done
    
    # Step 3: Styles
    while true; do
        case $(setup_styles) in
            0)
                break  # Continue to completion
                ;;
            2)
                continue  # Repeat this step
                ;;
            *)
                exit 0  # Any other case, exit
                ;;
        esac
    done
    
    # Show completion message
    show_completion
    
    print_success "Rofi setup completed successfully!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
