#!/usr/bin/env bash

# Rofi Style Switcher Script
# Switches only the style, keeping the current color scheme

STYLES_DIR="$HOME/.config/rofi/styles"
STYLE_FILE="$HOME/.config/rofi/style.rasi"

# Get all styles
STYLES=$(find "$STYLES_DIR" -name "*.rasi" -type f -exec basename {} .rasi \; | sort)

# Use rofi to select style
SELECTED=$(echo "$STYLES" | rofi -dmenu -p "Select Style" -theme-str '
window {
    width: 400px;
}
listview {
    lines: 10;
}
')

if [[ -n "$SELECTED" ]]; then
    # Update style.rasi to import the selected style
    echo "@import \"$STYLES_DIR/$SELECTED.rasi\"" > "$STYLE_FILE"
    echo ""  >> "$STYLE_FILE"
    
    # Show notification
    if command -v notify-send &> /dev/null; then
        notify-send "Rofi Theme" "Style changed to: $SELECTED"
    fi
    
    echo "Style changed to: $SELECTED"
fi
