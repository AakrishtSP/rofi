#!/bin/bash

STYLE_DIR="$HOME/.config/rofi/styles"
STYLE_FILE="$HOME/.config/rofi/style.rasi"
BACKUP_FILE="$HOME/.config/rofi/style.rasi.backup"

# Create backup of current style
if [ -f "$STYLE_FILE" ]; then
    cp "$STYLE_FILE" "$BACKUP_FILE"
fi

# Function to apply style
apply_style() {
    local style="$1"
    echo "@import \"$STYLE_DIR/$style.rasi\"" > "$STYLE_FILE"
}

# Function to restore backup
restore_backup() {
    if [ -f "$BACKUP_FILE" ]; then
        mv "$BACKUP_FILE" "$STYLE_FILE"
    fi
}

# Interactive style selection with preview
while true; do
    # Get list of styles
    STYLES=($(ls "$STYLE_DIR" | sed 's/.rasi$//' | sort))
    
    # Show rofi menu
    STYLE=$(printf '%s\n' "${STYLES[@]}" | rofi -dmenu \
        -config ~/.config/rofi/menu/theme-switcher.rasi \
        -p 'Choose Rofi Style (Space=preview, Enter=apply, Esc=cancel)' \
        -kb-custom-1 "space" \
        -mesg "Use Space to preview styles, Enter to apply, Escape to cancel")
    
    EXIT_CODE=$?
    
    case $EXIT_CODE in
        0)
            # Enter pressed - apply and exit
            if [ -n "$STYLE" ]; then
                apply_style "$STYLE"
                rm -f "$BACKUP_FILE"
                notify-send "Rofi" "Style applied: $STYLE"
                exit 0
            else
                restore_backup
                notify-send "Rofi" "No style selected"
                exit 1
            fi
            break
            ;;
        10)
            # Space pressed - preview the style
            if [ -n "$STYLE" ]; then
                apply_style "$STYLE"
                notify-send "Rofi Preview" "Previewing: $STYLE"
                # Continue the loop to show menu again with new style
            fi
            ;;
        *)
            # Escape or other - cancel and restore
            restore_backup
            notify-send "Rofi" "Style selection cancelled"
            exit 1
            ;;
    esac
done

# Clean up
rm -f "$BACKUP_FILE"
exit 0

