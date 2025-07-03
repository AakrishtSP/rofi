#!/bin/bash

THEME_DIR="$HOME/.config/rofi/colors"
COLOR_FILE="$HOME/.config/rofi/color.rasi"
BACKUP_FILE="$HOME/.config/rofi/color.rasi.backup"

# Create backup of current theme
if [ -f "$COLOR_FILE" ]; then
    cp "$COLOR_FILE" "$BACKUP_FILE"
fi

# Function to apply theme
apply_theme() {
    local theme="$1"
    echo "@import \"$THEME_DIR/$theme.rasi\"" > "$COLOR_FILE"
}

# Function to restore backup
restore_backup() {
    if [ -f "$BACKUP_FILE" ]; then
        mv "$BACKUP_FILE" "$COLOR_FILE"
    fi
}

# Interactive theme selection with preview
while true; do
    # Get list of themes
    THEMES=($(ls "$THEME_DIR" | sed 's/.rasi$//' | sort))
    
    # Show rofi menu
    THEME=$(printf '%s\n' "${THEMES[@]}" | rofi -dmenu \
        -config ~/.config/rofi/menu/theme-switcher.rasi \
        -p 'Choose Rofi Theme (Space=preview, Enter=apply, Esc=cancel)' \
        -kb-custom-1 "space" \
        -mesg "Use Space to preview themes, Enter to apply, Escape to cancel")
    
    EXIT_CODE=$?
    
    case $EXIT_CODE in
        0)
            # Enter pressed - apply and exit
            if [ -n "$THEME" ]; then
                apply_theme "$THEME"
                rm -f "$BACKUP_FILE"
                notify-send "Rofi" "Theme applied: $THEME"
                exit 0
            else
                restore_backup
                notify-send "Rofi" "No theme selected"
                exit 1
            fi
            break
            ;;
        10)
            # Space pressed - preview the theme
            if [ -n "$THEME" ]; then
                apply_theme "$THEME"
                notify-send "Rofi Preview" "Previewing: $THEME"
                # Continue the loop to show menu again with new theme
            fi
            ;;
        *)
            # Escape or other - cancel and restore
            restore_backup
            notify-send "Rofi" "Theme selection cancelled"
            exit 1
            ;;
    esac
done

# Clean up
rm -f "$BACKUP_FILE"
exit 0

