# BlaBló App Reusable Components

This document provides an overview of the reusable components available in the BlaBló app. These components are designed to provide consistent styling and behavior across the app, making it easier to maintain and extend the codebase.

## Table of Contents

1. [Common Widgets](#common-widgets)
   - [AppButton](#appbutton)
   - [AppImage](#appimage)
   - [AppCharacter](#appcharacter)
   - [AppDialog](#appdialog)
   - [AppProgressBar](#appprogressbar)
2. [How to Use](#how-to-use)
3. [Best Practices](#best-practices)

## Common Widgets

All common widgets are located in the `lib/presentation/widgets/common` directory and can be imported using the barrel file:

```dart
import 'package:blablo_app/presentation/widgets/common/common_widgets.dart';
```

### AppButton

A reusable button component that provides consistent styling across the app. It can be used as a primary button (filled with the primary color) or a secondary button (text only).

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| text | String | The text to display on the button |
| onPressed | VoidCallback? | The callback to execute when the button is pressed |
| isPrimary | bool | Whether this is a primary button (filled) or secondary button (text only) |
| width | double? | The width of the button. If null, it will take the full available width |
| height | double | The height of the button |
| icon | IconData? | The icon to display before the text (optional) |
| backgroundColor | Color? | The background color of the button (for primary buttons) |
| textColor | Color? | The text color of the button |
| borderRadius | double | The border radius of the button |
| isLoading | bool | Whether to show a loading indicator instead of the text |

#### Example Usage

```dart
// Primary button (filled)
AppButton(
  text: "Continue",
  onPressed: () {
    // Handle button press
  },
)

// Secondary button (text only)
AppButton(
  text: "Cancel",
  onPressed: () {
    // Handle button press
  },
  isPrimary: false,
)

// Button with icon
AppButton(
  text: "Share",
  onPressed: () {
    // Handle button press
  },
  icon: Icons.share,
)

// Loading button
AppButton(
  text: "Save",
  onPressed: () {
    // Handle button press
  },
  isLoading: true,
)
```

### AppImage

A reusable image component that handles asset loading, errors, and provides consistent styling across the app.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| imagePath | String | The image path. If it's a relative path, it will be prefixed with the AppConstants.imagePath value |
| width | double? | The width of the image |
| height | double? | The height of the image |
| fit | BoxFit | How to fit the image within its bounds |
| borderRadius | BorderRadius? | The border radius of the image |
| isCircular | bool | Whether the image should be circular |
| backgroundColor | Color? | The background color to use when the image is loading or has an error |
| errorIcon | IconData | The icon to display when the image fails to load |
| errorIconColor | Color | The color of the error icon |
| errorIconSize | double | The size of the error icon |

#### Example Usage

```dart
// Basic usage
AppImage(
  imagePath: 'fox_welcome.png',
  height: 100,
)

// Circular image
AppImage(
  imagePath: 'profile_picture.png',
  height: 50,
  width: 50,
  isCircular: true,
)

// Image with custom error handling
AppImage(
  imagePath: 'scenario_image.png',
  height: 200,
  width: double.infinity,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(16),
  errorIcon: Icons.image_not_supported,
  errorIconColor: Colors.red,
)
```

### AppCharacter

A reusable component for displaying character images (like the fox) with consistent styling across the app.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| imageFilename | String | The image filename (without path) of the character |
| height | double | The height of the character image |
| width | double? | The width of the character image. If null, it will maintain aspect ratio |
| isCircular | bool | Whether to make the character circular |
| backgroundColor | Color? | The background color to use when the image is loading or has an error |
| errorIcon | IconData | The icon to display when the image fails to load |
| errorIconColor | Color | The color of the error icon |

#### Factory Constructors

- `AppCharacter.hiro()`: Creates an instance of the Hiro fox character

#### Example Usage

```dart
// Basic usage
AppCharacter(
  imageFilename: 'fox_welcome.png',
  height: 100,
)

// Using the factory constructor for Hiro
AppCharacter.hiro(
  height: 80,
)
```

### AppDialog

A reusable dialog component that provides consistent styling across the app.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| title | String? | The title of the dialog |
| content | Widget | The content of the dialog |
| primaryButtonText | String? | The primary action button text |
| onPrimaryButtonPressed | VoidCallback? | The callback to execute when the primary button is pressed |
| secondaryButtonText | String? | The secondary action button text |
| onSecondaryButtonPressed | VoidCallback? | The callback to execute when the secondary button is pressed |
| showCloseButton | bool | Whether to show a close button in the top-right corner |
| borderRadius | double | The border radius of the dialog |
| contentPadding | EdgeInsets | The padding around the dialog content |
| width | double? | The width of the dialog. If null, it will use the default width |
| maxHeightFactor | double | The maximum height of the dialog as a fraction of the screen height |

#### Example Usage

```dart
// Basic usage
showDialog(
  context: context,
  builder: (context) {
    return AppDialog(
      title: "Dialog Title",
      content: Text("This is the dialog content."),
      primaryButtonText: "OK",
      onPrimaryButtonPressed: () {
        Navigator.of(context).pop();
      },
    );
  },
);

// Dialog with two buttons
showDialog(
  context: context,
  builder: (context) {
    return AppDialog(
      title: "Confirm Action",
      content: Text("Are you sure you want to proceed?"),
      primaryButtonText: "Yes",
      onPrimaryButtonPressed: () {
        // Handle confirmation
        Navigator.of(context).pop(true);
      },
      secondaryButtonText: "No",
      onSecondaryButtonPressed: () {
        Navigator.of(context).pop(false);
      },
    );
  },
);
```

### AppProgressBar

A reusable progress bar component that provides consistent styling across the app.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| value | double | The current progress value, between 0.0 and 1.0 |
| height | double | The height of the progress bar |
| backgroundColor | Color? | The background color of the progress bar |
| valueColor | Color? | The color of the progress indicator |
| borderRadius | double | The border radius of the progress bar |
| animate | bool | Whether to animate the progress change |
| animationDuration | Duration | The duration of the animation |

#### Example Usage

```dart
// Basic usage
AppProgressBar(
  value: 0.5, // 50% progress
)

// Custom styling
AppProgressBar(
  value: 0.75,
  height: 8,
  backgroundColor: Colors.grey.shade100,
  valueColor: Colors.green,
  borderRadius: 4,
)

// Without animation
AppProgressBar(
  value: 0.33,
  animate: false,
)
```

## How to Use

To use these components in your screens, follow these steps:

1. Import the common widgets barrel file:

```dart
import 'package:blablo_app/presentation/widgets/common/common_widgets.dart';
```

2. Use the components in your widget tree:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Example Screen")),
    body: Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppProgressBar(
            value: 0.5,
          ),
        ),
        
        // Character image
        AppCharacter.hiro(
          height: 100,
        ),
        
        // Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppButton(
            text: "Continue",
            onPressed: () {
              // Handle button press
            },
          ),
        ),
      ],
    ),
  );
}
```

## Best Practices

1. **Use const constructors** when possible to improve performance:

```dart
const AppButton(
  text: "Continue",
  onPressed: null, // Note: can only be const if onPressed is null
)
```

2. **Prefer reusable components** over custom implementations to maintain consistency.

3. **Use the appropriate component** for each use case:
   - Use `AppButton` for all buttons in the app
   - Use `AppImage` for loading images from assets
   - Use `AppCharacter` for character images (like the fox)
   - Use `AppDialog` for all dialogs
   - Use `AppProgressBar` for progress indicators

4. **Customize only when necessary** - the default styling should be sufficient for most cases.

5. **Add new reusable components** when you find yourself repeating similar UI patterns across multiple screens.
