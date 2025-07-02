# Rofi Configuration - Separated Colors and Styles

This Rofi configuration separates colors and styles for maximum flexibility and customization.

## Structure

```
~/.config/rofi/
├── config.rasi          # Main configuration file
├── theme.rasi           # Theme file that imports color + style
├── color.rasi           # Current color scheme selector
├── style.rasi           # Current style selector
├── colors/              # Color schemes (colors only)
│   ├── adapta-nokto.rasi
│   ├── dracula-clean.rasi
│   ├── nord-clean.rasi
│   └── ...
├── styles/              # Styles (layout and visual properties)
│   ├── common.rasi      # Base style (used by all others)
│   ├── simple-icon.rasi
│   ├── simple-no-icon.rasi
│   ├── compact.rasi
│   ├── large.rasi
│   ├── minimal.rasi
│   ├── rounded.rasi
│   ├── grid.rasi
│   └── ...
└── scripts/
    ├── rofi-color-switcher.sh   # Switch color schemes
    └── rofi-style-switcher-new.sh # Switch styles
```

## Design Philosophy

### Colors (`colors/` directory)
- Contains **only** color definitions
- No layout, spacing, or visual properties
- All color schemes use the same variable names for consistency
- Can be mixed and matched with any style

### Styles (`styles/` directory)
- Contains **only** layout, spacing, fonts, and visual properties
- All styles import `common.rasi` as a base
- Modifications are layered on top of the common base
- Use color variables defined in color schemes

### Common Base (`styles/common.rasi`)
- Complete base style that works with any color scheme
- Defines all layout components and their relationships
- Uses standardized color variable names
- All other styles inherit from this base

## Available Styles

1. **simple-icon** - Default style with icons enabled
2. **simple-no-icon** - Default style without icons
3. **compact** - Smaller dimensions and font size
4. **large** - Bigger dimensions and font size
5. **minimal** - No borders, minimal spacing
6. **rounded** - Extra rounded corners everywhere
7. **grid** - Grid layout for applications (4x4)

## Color Schemes

All color schemes define these standard variables:
- `background`, `background-alt`, `foreground`
- `selected`, `active`, `urgent`
- `border-color`, `scrollbar-handle`, `text-secondary`
- Various state-specific colors for normal/selected/alternate elements

## Usage

### Switching Themes
```bash
# Switch color scheme only
./scripts/rofi-color-switcher.sh

# Switch style only  
./scripts/rofi-style-switcher-new.sh
```

### Manual Configuration
Edit `color.rasi` to change color scheme:
```rasi
@import "/home/asp/.config/rofi/colors/dracula-clean.rasi"
```

Edit `style.rasi` to change style:
```rasi
@import "/home/asp/.config/rofi/styles/rounded.rasi"
```

### Creating New Styles
1. Create a new `.rasi` file in `styles/`
2. Import `common.rasi` at the top
3. Override only the properties you want to change

Example:
```rasi
@import "common.rasi"

window {
    width: 400px;
    border-radius: 20px;
}
```

### Creating New Color Schemes
1. Create a new `.rasi` file in `colors/`
2. Define all the standard color variables
3. Use the `adapta-nokto.rasi` as a template

## Benefits

- **Modularity**: Mix any color scheme with any style
- **Consistency**: All themes use the same base structure  
- **Maintainability**: Changes to common.rasi affect all styles
- **Flexibility**: Easy to create variations without duplication
- **Organization**: Clear separation of concerns
