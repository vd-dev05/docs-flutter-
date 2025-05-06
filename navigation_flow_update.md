# Navigation Flow Update

This document describes the updated navigation flow in the BlaBló App, specifically focusing on the separation of the intro screens and the WelcomeScreen.

## Overview

The navigation flow has been updated to ensure that the WelcomeScreen appears after the three intro screens and before the goal selection screen. This change aligns with the design documentation and provides a clearer separation between the intro screens and the main onboarding process.

## Updated Flow

The updated navigation flow is as follows:

```
Intro Screens (3) → WelcomeScreen → Goal Selection → Speaking Feeling → Sign In
```

Specifically:
1. Intro Commute
2. Intro Traffic
3. Intro Dishes
4. WelcomeScreen (separate screen)
5. Goal Selection
6. Speaking Feeling
7. Sign In

## Implementation Details

The following changes were made to implement this updated flow:

1. **Local Data Source**: Updated the `onboarding_local_datasource.dart` file to remove the "welcome_hero" step from the intro steps and set the "intro_dishes" step to navigate directly to "goal_selection".

2. **OnboardingScreen**: Modified the `_handleStepNavigation` method in `onboarding_screen.dart` to add a special case for the "intro_dishes" step. When this step is completed, the app now navigates to the WelcomeScreen instead of following the normal navigation flow.

3. **WelcomeScreen**: Updated the navigation method in `welcome_screen.dart` to use `navigateToReplacement` instead of `navigateTo` when navigating to the GoalSelectionScreen. This ensures a cleaner navigation flow by removing the WelcomeScreen from the navigation stack.

4. **DoneScreen**: Updated the comments in `done_screen.dart` to clarify the navigation flow after completing the onboarding process.

## Benefits

This updated navigation flow provides several benefits:

1. **Clearer Separation**: The WelcomeScreen is now clearly separated from the intro screens, making it easier to understand the flow.

2. **Alignment with Design**: The flow now aligns with the design documentation, which specifies that the WelcomeScreen should appear after the three intro screens.

3. **Improved User Experience**: The user now has a clearer understanding of the progression through the onboarding process.

## Related Components

- `OnboardingScreen`: Handles the display of intro screens and navigation between steps.
- `WelcomeScreen`: Displays the welcome message with the fox character and celebration effect.
- `GoalSelectionScreen`: Allows users to select their English learning goal.
- `NavigationHelper`: Provides helper methods for navigation between screens.
