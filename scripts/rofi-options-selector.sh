#!/bin/bash

OPTIONS_DIR="$HOME/.config/rofi/options"
BACKUP_DIR="$HOME/.config/rofi/options/.backup"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to get all available options dynamically
get_available_options() {
    find "$OPTIONS_DIR" -maxdepth 1 -type d -not -name ".*" -not -name "options" | \
    xargs -I {} basename {} | sort
}

# Function to ensure option symlink exists
ensure_option_symlink() {
    local option_name="$1"
    local option_file="$OPTIONS_DIR/$option_name/$option_name.rasi"
    local disable_file="$OPTIONS_DIR/$option_name/disable.rasi"
    
    # If symlink doesn't exist and disable.rasi exists, create symlink to disable.rasi
    if [ ! -L "$option_file" ] && [ ! -f "$option_file" ] && [ -f "$disable_file" ]; then
        ln -sf "disable.rasi" "$option_file"
    fi
}

# Function to backup current option files
backup_options() {
    mkdir -p "$BACKUP_DIR"
    for option in $(get_available_options); do
        ensure_option_symlink "$option"
        local option_file="$OPTIONS_DIR/$option/$option.rasi"
        if [ -L "$option_file" ]; then
            # If it's a symlink, save the target
            readlink "$option_file" > "$BACKUP_DIR/$option.target"
        elif [ -f "$option_file" ]; then
            # If it's a regular file, copy it
            cp "$option_file" "$BACKUP_DIR/$option.rasi"
        fi
    done
}

# Function to restore backup option files
restore_backup() {
    for option in $(get_available_options); do
        local option_file="$OPTIONS_DIR/$option/$option.rasi"
        if [ -f "$BACKUP_DIR/$option.target" ]; then
            # Restore symlink
            local target=$(cat "$BACKUP_DIR/$option.target")
            rm -f "$option_file"
            ln -sf "$target" "$option_file"
        elif [ -f "$BACKUP_DIR/$option.rasi" ]; then
            # Restore regular file
            mv "$BACKUP_DIR/$option.rasi" "$option_file"
        fi
    done
}

# Generic function to toggle any option
toggle_option() {
    local option_name="$1"
    local option_file="$OPTIONS_DIR/$option_name/$option_name.rasi"
    local enable_file="$OPTIONS_DIR/$option_name/enable.rasi"
    local disable_file="$OPTIONS_DIR/$option_name/disable.rasi"
    
    # Determine current state based on symlink target or file content
    local current_state="disabled"
    if [ -L "$option_file" ]; then
        # If it's a symlink, check the target
        local target=$(readlink "$option_file")
        if [[ "$target" == *"enable.rasi" ]]; then
            current_state="enabled"
        fi
    elif [ -f "$option_file" ]; then
        # If it's a regular file, check content
        if grep -q "// Enabled" "$option_file" 2>/dev/null; then
            current_state="enabled"
        elif grep -q "show-icons: true" "$option_file" 2>/dev/null; then
            current_state="enabled"
        fi
    fi
    
    # Toggle the state using symlinks
    if [ "$current_state" = "enabled" ]; then
        rm -f "$option_file"
        ln -sf "disable.rasi" "$option_file"
        echo "disabled"
    else
        rm -f "$option_file"
        ln -sf "enable.rasi" "$option_file"
        echo "enabled"
    fi
}

# Function to get current option states
get_option_states() {
    for option in $(get_available_options); do
        ensure_option_symlink "$option"
        local option_file="$OPTIONS_DIR/$option/$option.rasi"
        local state="Off"
        
        # Determine state based on symlink target or file content
        if [ -L "$option_file" ]; then
            local target=$(readlink "$option_file")
            if [[ "$target" == *"enable.rasi" ]]; then
                state="On"
            fi
        elif [ -f "$option_file" ]; then
            if grep -q "// Enabled" "$option_file" 2>/dev/null; then
                state="On"
            elif grep -q "show-icons: true" "$option_file" 2>/dev/null; then
                state="On"
            fi
        fi
        
        # Format option name for display (capitalize first letter, replace hyphens with spaces)
        local display_name=$(echo "$option" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
        echo " $display_name: $state"
    done
    
    echo "────────────────────────────────────────────────────────────────────────────────────────────────────"
    echo " Apply Changes & Exit"
    echo " Cancel & Restore"
    echo ""
    echo "• Click on any option above to toggle it"
    echo "• Use Space to preview changes"
}

# Main option selector loop
backup_options

while true; do
    # Show current states and options
    OPTION=$(get_option_states | rofi -dmenu \
        -config ~/.config/rofi/menu/theme-switcher.rasi \
        -p 'Rofi Options Manager' \
        -lines 10 \
        -width 50 \
        -kb-custom-1 "space" \
        -mesg "Click options to toggle • Space=preview • Enter=apply/action")
    
    EXIT_CODE=$?
    
    case $EXIT_CODE in
        0)
            # Enter pressed - handle selection
            case "$OPTION" in
                " Apply Changes & Exit")
                    rm -rf "$BACKUP_DIR"
                    notify-send "Rofi Options" "Options applied successfully"
                    exit 0
                    ;;
                " Cancel & Restore")
                    restore_backup
                    rm -rf "$BACKUP_DIR"
                    notify-send "Rofi Options" "Changes cancelled"
                    exit 1
                    ;;
                "────"*|"•"*|"")
                    # Do nothing for separator lines, info lines, or empty selection
                    ;;
                *)
                    # Handle dynamic option toggles
                    if [[ "$OPTION" =~ ^\ (.+):\ (On|Off)$ ]]; then
                        display_name="${BASH_REMATCH[1]}"
                        current_state="${BASH_REMATCH[2]}"
                        
                        # Convert display name back to option folder name
                        option_name=$(echo "$display_name" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
                        
                        # Toggle the option
                        new_state=$(toggle_option "$option_name")
                        notify-send "Rofi Options" "$display_name: $new_state"
                    fi
                    ;;
            esac
            ;;
        10)
            # Space pressed - show preview
            rofi -show drun &
            sleep 0.5
            ;;
        *)
            # Escape or other - cancel and restore
            restore_backup
            rm -rf "$BACKUP_DIR"
            notify-send "Rofi Options" "Options selection cancelled"
            exit 1
            ;;
    esac
done

# Clean up
rm -rf "$BACKUP_DIR"
exit 0