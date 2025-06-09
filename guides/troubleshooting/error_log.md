# BlaBló App Error Log

This document tracks errors found in the codebase and their solutions.

## Table of Contents

1. [Missing Files](#missing-files)
2. [Import Errors](#import-errors)
3. [Deprecated API Usage](#deprecated-api-usage)
4. [Performance Issues](#performance-issues)
5. [Other Issues](#other-issues)

## Missing Files

### 1. Missing `app_button.dart` file

**Error:**
```
Target of URI doesn't exist: 'app_button.dart'.
```

**Solution:**
The file was renamed from `custom_button.dart` to `app_button.dart`, but the file wasn't properly moved or renamed in the file system. We need to:
1. Rename `lib/presentation/widgets/common/custom_button.dart` to `lib/presentation/widgets/common/app_button.dart`
2. Update all imports to use the new file name

### 2. Missing imports in barrel file

**Error:**
```
Target of URI doesn't exist: 'app_button.dart'.
```

**Solution:**
Update the barrel file (`common_widgets.dart`) to use the correct paths for exports.

## Import Errors

### 1. Unused imports

**Error:**
```
Unused import: 'package:blablo_app/core/theme/app_theme.dart'.
```

**Solution:**
Remove unused imports from the following files:
- `lib/presentation/widgets/common/app_image.dart`
- `lib/presentation/widgets/common/app_dialog.dart`
- `lib/presentation/widgets/dialogs/login_dialog.dart`

### 2. Redundant imports

**Error:**
```
The import of 'package:flutter/foundation.dart' is unnecessary because all of the used elements are also provided by the import of 'package:flutter/material.dart'.
```

**Solution:**
Remove redundant imports from:
- `lib/presentation/pages/onboarding/goal_selection_screen.dart`

## Deprecated API Usage

### 1. Deprecated `withOpacity` method

**Error:**
```
'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss.
```

**Solution:**
Replace `withOpacity` with `withAlpha` or `withValues()` in the following files:
- `lib/presentation/widgets/common/particle_system.dart`
- `lib/presentation/widgets/scenario_card.dart`
- `lib/presentation/widgets/specific/conversation_bubble.dart`
- `lib/presentation/widgets/specific/scenario_card.dart`
- `lib/presentation/widgets/specific/vocabulary_card.dart`

## Performance Issues

### 1. Missing `const` constructors

**Error:**
```
Use 'const' with the constructor to improve performance.
```

**Solution:**
Add `const` keyword to widget constructors where possible:
- `lib/presentation/pages/onboarding/goal_selection_screen.dart`
- `lib/presentation/pages/home/home_screen.dart`

## Other Issues

### 1. Undefined methods

**Error:**
```
The method 'AppButton' isn't defined for the type '_GoalSelectionScreenState'.
```

**Solution:**
Fix the references to `AppButton` in:
- `lib/presentation/pages/onboarding/goal_selection_screen.dart`
- `lib/presentation/widgets/common/app_dialog.dart`

### 2. Test file issues

**Error:**
```
Target of URI doesn't exist: 'package:app_test/main.dart'.
```

**Solution:**
Update the test file to use the correct package name:
- `test/widget_test.dart`

### 3. Print statements in production code

**Error:**
```
Don't invoke 'print' in production code.
```

**Solution:**
Replace print statements with a logging framework in:
- `lib/presentation/bloc/scenarios_bloc.dart`

### 4. TODO comments

**Warning:**
```
TODO: Implement forgot password
```

**Solution:**
Implement the missing functionality or create proper tasks for them:
- `lib/presentation/pages/auth/login_screen.dart`
