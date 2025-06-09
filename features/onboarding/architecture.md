# Onboarding Architecture

This document describes the architecture of the onboarding feature in the BlaBló app.

## Overview

The onboarding feature follows clean architecture principles and uses the BLoC/Cubit pattern for state management. The feature is divided into several screens that guide the user through the onboarding process.

## Components

### Screens

1. **Intro Screens**: A series of screens that introduce the app to the user.
2. **Goal Selection Screen**: Allows the user to select their English learning goal.
3. **Speaking Feeling Screen**: Asks the user how they feel when speaking English.
4. **Topic Selection Screen**: Lets the user select topics they're interested in.
5. **Auth Screen**: Provides options for signing in or creating an account.
6. **Done Screen**: Confirms the completion of the onboarding process.

### Reusable Components

1. **OnboardingScreenBase**: A base widget for all onboarding screens that provides consistent layout and styling.
2. **SelectionOptionItem**: A reusable widget for displaying selectable options in onboarding screens.

### State Management

#### BLoC

The `OnboardingBloc` is responsible for managing the overall state of the onboarding process. It handles events like:
- Fetching onboarding steps from the API
- Setting the user's goal
- Setting the user's speaking feeling
- Setting the user's favorite topics

#### Cubits

Each screen has its own Cubit to manage its local state:

1. **GoalSelectionCubit**: Manages the state of the goal selection screen.
2. **SpeakingFeelingCubit**: Manages the state of the speaking feeling screen.
3. **TopicSelectionCubit**: Manages the state of the topic selection screen.

### Data Flow

1. The `OnboardingBloc` fetches the onboarding steps from the API.
2. The `OnboardingScreen` displays the intro screens and navigates to the appropriate screen based on the user's actions.
3. Each screen uses its own Cubit to manage its local state and updates the `OnboardingBloc` when the user makes a selection.
4. The `OnboardingBloc` stores the user's selections and determines when the onboarding process is complete.

## Dependency Injection

The `CubitProviders` class provides factory methods for creating Cubits with the appropriate dependencies. This makes it easy to create Cubits in the UI layer without having to manually inject dependencies.

## Fallback Mechanism

The app includes a fallback mechanism to handle cases where the API doesn't provide data for a screen. Each screen has default options that are used when the API data is missing or incomplete.

## Code Organization

- **lib/presentation/pages/onboarding/**: Contains the screen widgets.
- **lib/presentation/cubits/**: Contains the Cubits for each screen.
- **lib/presentation/widgets/onboarding/**: Contains reusable widgets for the onboarding screens.
- **lib/core/di/**: Contains dependency injection code.

## Benefits of This Architecture

1. **Separation of Concerns**: Each component has a single responsibility.
2. **Testability**: The business logic is separated from the UI, making it easier to test.
3. **Reusability**: Common UI elements are extracted into reusable components.
4. **Maintainability**: The code is organized in a way that makes it easy to understand and modify.
5. **Scalability**: New screens can be added easily by following the same pattern.
