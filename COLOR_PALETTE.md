# Sportyx Color Palette Guide

## Overview
The Sportyx project uses a cohesive purple-based color palette across all platforms (Flutter Mobile App, React Web Client, and backend UI elements).

## Color Palette

| Color Name | Hex Value | RGB Value | Usage |
|------------|-----------|-----------|-------|
| Primary Dark | `#391053` | (57, 16, 83) | Dark brand color for strong emphasis |
| Primary | `#5a2675` | (90, 38, 117) | Main brand color for buttons, app bars, links |
| Primary Light | `#9d72b3` | (157, 114, 179) | Lighter accent for secondary elements |
| Accent | `#c9a8f1` | (201, 168, 241) | Light accent for highlights, badges |
| White | `#ffffff` | (255, 255, 255) | Background, text on dark backgrounds |

## Flutter Mobile App Implementation

### Colors File
All colors are defined in `lib/core/colors.dart`:

```dart
class AppColors {
  static const Color primaryDark = Color(0xFF391053);
  static const Color primary = Color(0xFF5a2675);
  static const Color primaryLight = Color(0xFF9d72b3);
  static const Color accent = Color(0xFFC9A8F1);
  static const Color white = Color(0xFFFFFFFF);
  // Additional utility colors
}
```

### Theme Configuration
The theme is configured in `lib/core/theme.dart` with:
- Primary button styling using `AppColors.primary`
- AppBar background using `AppColors.primary`
- Input field focus states using `AppColors.primary`
- Accent elements using `AppColors.accent`

### Usage in Components
To use colors in any Dart widget:

```dart
import '../../core/colors.dart';

// In widget
Container(
  color: AppColors.primary,
  child: Icon(Icons.star, color: AppColors.accent),
)
```

## React Web Client Implementation

### CSS Variables
Colors are defined as CSS variables in `src/index.css`:

```css
:root {
  --color-primary-dark: #391053;
  --color-primary: #5a2675;
  --color-primary-light: #9d72b3;
  --color-accent: #c9a8f1;
  --color-white: #ffffff;
}
```

### Usage in Styles
Apply colors using CSS variables:

```css
button {
  background-color: var(--color-primary);
  color: var(--color-white);
}

button:hover {
  background-color: var(--color-primary-dark);
}
```

## Files Updated

### Flutter Mobile App
- `lib/core/colors.dart` - New color constants file
- `lib/core/theme.dart` - Updated theme with new colors
- `lib/main.dart` - Uses updated theme
- `lib/features/auth/register_page.dart` - Updated hardcoded colors
- `lib/features/athlete/athlete_profile_page.dart` - Updated hardcoded colors
- `lib/features/home/landing_page.dart` - Updated slide colors

### React Web Client
- `src/index.css` - Added CSS variables and updated colors
- `src/App.css` - Updated component colors to use variables

## Best Practices

1. **Always use color constants** - Never hardcode color values in components
2. **Use semantic naming** - Use primary/accent names rather than descriptive names like "purple"
3. **Theme consistency** - Updates to colors should typically be made in the theme file
4. **Accessibility** - Ensure sufficient contrast between text and background colors
5. **Component reuse** - Use theme colors throughout for consistent visual identity

## Future Enhancements

- Add support for dark mode with a corresponding dark color palette
- Create additional utility colors (success, error, warning)
- Document accessible color contrast ratios
- Add color swatches component to design system

## Contact

For color palette inquiries or to request changes, please contact the design team.
