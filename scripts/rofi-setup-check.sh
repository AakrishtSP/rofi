#!/bin/bash

# Rofi Setup Environment Check
# This script verifies that all required components are available

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/rofi"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[CHECK]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if rofi is installed
check_rofi_installed() {
    print_status "Checking if rofi is installed..."
    if command -v rofi &> /dev/null; then
        local rofi_version=$(rofi -version | head -1)
        print_success "Rofi is installed: $rofi_version"
        return 0
    else
        print_error "Rofi is not installed. Please install rofi first."
        return 1
    fi
}

# Check directory structure
check_directory_structure() {
    print_status "Checking directory structure..."
    
    local required_dirs=(
        "$CONFIG_DIR/colors"
        "$CONFIG_DIR/styles"
        "$CONFIG_DIR/options"
        "$CONFIG_DIR/menu"
        "$CONFIG_DIR/scripts"
    )
    
    local missing_dirs=()
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            missing_dirs+=("$dir")
        fi
    done
    
    if [[ ${#missing_dirs[@]} -gt 0 ]]; then
        print_error "Missing required directories:"
        for dir in "${missing_dirs[@]}"; do
            echo "  - $dir"
        done
        return 1
    else
        print_success "All required directories found"
        return 0
    fi
}

# Check required files
check_required_files() {
    print_status "Checking required files..."
    
    local required_files=(
        "$CONFIG_DIR/menu/theme-switcher.rasi"
        "$CONFIG_DIR/config.rasi"
    )
    
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        print_error "Missing required files:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        return 1
    else
        print_success "All required files found"
        return 0
    fi
}

# Check scripts
check_scripts() {
    print_status "Checking setup scripts..."
    
    local required_scripts=(
        "$SCRIPT_DIR/rofi-color-palette-switcher.sh"
        "$SCRIPT_DIR/rofi-options-selector.sh"
        "$SCRIPT_DIR/rofi-style-switcher.sh"
        "$SCRIPT_DIR/setup-rofi.sh"
    )
    
    local missing_scripts=()
    local non_executable=()
    
    for script in "${required_scripts[@]}"; do
        if [[ ! -f "$script" ]]; then
            missing_scripts+=("$script")
        elif [[ ! -x "$script" ]]; then
            non_executable+=("$script")
        fi
    done
    
    if [[ ${#missing_scripts[@]} -gt 0 ]]; then
        print_error "Missing required scripts:"
        for script in "${missing_scripts[@]}"; do
            echo "  - $(basename "$script")"
        done
        return 1
    elif [[ ${#non_executable[@]} -gt 0 ]]; then
        print_warning "Some scripts are not executable. Making them executable..."
        for script in "${non_executable[@]}"; do
            chmod +x "$script"
            echo "  - Made $(basename "$script") executable"
        done
        print_success "All scripts are now executable"
        return 0
    else
        print_success "All scripts found and executable"
        return 0
    fi
}

# Check for themes and styles
check_themes_and_styles() {
    print_status "Checking available themes and styles..."
    
    local color_count=$(find "$CONFIG_DIR/colors" -name "*.rasi" 2>/dev/null | wc -l)
    local style_count=$(find "$CONFIG_DIR/styles" -name "*.rasi" 2>/dev/null | wc -l)
    
    if [[ $color_count -eq 0 ]]; then
        print_error "No color themes found in $CONFIG_DIR/colors"
        return 1
    else
        print_success "Found $color_count color themes"
    fi
    
    if [[ $style_count -eq 0 ]]; then
        print_error "No style layouts found in $CONFIG_DIR/styles"
        return 1
    else
        print_success "Found $style_count style layouts"
    fi
    
    return 0
}

# Check notify-send for notifications
check_notifications() {
    print_status "Checking notification support..."
    if command -v notify-send &> /dev/null; then
        print_success "Desktop notifications supported"
        return 0
    else
        print_warning "notify-send not found. Notifications will be disabled"
        return 0
    fi
}

# Main check function
main() {
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    ROFI SETUP ENVIRONMENT CHECK              ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    local checks_passed=0
    local total_checks=6
    
    # Run all checks
    check_rofi_installed && ((checks_passed++))
    echo
    check_directory_structure && ((checks_passed++))
    echo
    check_required_files && ((checks_passed++))
    echo
    check_scripts && ((checks_passed++))
    echo
    check_themes_and_styles && ((checks_passed++))
    echo
    check_notifications && ((checks_passed++))
    echo
    
    # Summary
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                         SUMMARY                               ║${NC}"
    echo -e "${BLUE}╠═══════════════════════════════════════════════════════════════╣${NC}"
    
    if [[ $checks_passed -eq $total_checks ]]; then
        echo -e "${BLUE}║${NC} ${GREEN}✓ All checks passed! Ready to run setup.${NC}                   ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC}                                                               ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} Run: ./setup-rofi.sh                                         ${BLUE}║${NC}"
    else
        echo -e "${BLUE}║${NC} ${RED}✗ $((total_checks - checks_passed)) checks failed. Please fix the issues above.${NC}          ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC}                                                               ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} Fix the issues and run this check again.                     ${BLUE}║${NC}"
    fi
    
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    if [[ $checks_passed -eq $total_checks ]]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
