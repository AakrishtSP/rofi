#!/usr/bin/env bash

# Rofi Color Switcher Script
# Switches only the color scheme, keeping the current style

COLORS_DIR="$HOME/.config/rofi/colors"
COLOR_FILE="$HOME/.config/rofi/color.rasi"

# Get all color schemes
COLOR_SCHEMES=$(find "$COLORS_DIR" -name "*.rasi" -type f -exec basename {} .rasi \; | sort)

# Use rofi to select color scheme
SELECTED=$(echo "$COLOR_SCHEMES" | rofi -dmenu -p "Select Color Scheme" -theme-str '
window {
    width: 400px;
}
listview {
    lines: 10;
}
')

if [[ -n "$SELECTED" ]]; then
    # Update color.rasi to import the selected color scheme
    echo "@import \"$COLORS_DIR/$SELECTED.rasi\"" > "$COLOR_FILE"
    echo ""  >> "$COLOR_FILE"
    
    # Show notification
    if command -v notify-send &> /dev/null; then
        notify-send "Rofi Theme" "Color scheme changed to: $SELECTED"
    fi
    
    echo "Color scheme changed to: $SELECTED"
fi
