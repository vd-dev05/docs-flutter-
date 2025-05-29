# Can-Do Journey Tab Switching Implementation Guide

## Overview
This document explains the implementation of tab switching functionality in the Can-Do Journey feature of the Blablo app. The implementation includes three tabs that filter content based on progress status:

1. **All topics**: Shows all lessons from the API response
2. **In progress**: Filters and shows lessons with progress > 0 but not completed
3. **Mastered**: Filters and shows lessons that are marked as completed

## Key Components

### TabController Setup
The `TabController` is initialized in the `initState` method with a listener to detect tab changes:

```dart
@override
void initState() {
  super.initState();
  _tabController = TabController(length: 3, vsync: this);
  // Add listener to detect tab changes
  _tabController.addListener(_handleTabChange);
}
```

### Tab Change Listener
The `_handleTabChange` method is triggered when the tab selection changes, allowing us to update the UI accordingly:

```dart
void _handleTabChange() {
  // Only trigger when the tab selection actually changes
  if (!_tabController.indexIsChanging && _currentTabIndex != _tabController.index) {
    setState(() {
      _currentTabIndex = _tabController.index;
      // Update state when tab changes
    });
  }
}
```

### Programmatic Tab Switching
The `_switchToTab` method provides a way to switch tabs programmatically, with animation:

```dart
void _switchToTab(int tabIndex) {
  if (tabIndex >= 0 && tabIndex < _tabController.length) {
    _tabController.animateTo(tabIndex, 
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeInOut);
    setState(() {
      _currentTabIndex = tabIndex;
    });
  }
}
```

### TabBar UI Implementation
The TabBar UI is implemented as part of the AppBar's `flexibleSpace`:

```dart
Container(
  width: double.infinity,
  color: Colors.transparent,
  padding: const EdgeInsets.only(left: 16.0),
  child: TabBar(
    controller: _tabController,
    labelColor: Colors.black,
    unselectedLabelColor: Colors.grey[500],
    indicatorColor: const Color(0xFFFF3DC7), // Pink indicator
    indicatorWeight: 3.0,
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: Colors.transparent,
    isScrollable: true,
    padding: EdgeInsets.zero,
    labelPadding: const EdgeInsets.only(right: 16.0),
    tabs: const [
      Tab(child: Text('All topics')),
      Tab(child: Text('In progress')),
      Tab(child: Text('Mastered 🏅')),
    ],
    labelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
  ),
)
```

### TabBarView Implementation
The TabBarView displays different content based on the selected tab:

```dart
TabBarView(
  controller: _tabController,
  physics: const ClampingScrollPhysics(),
  children: [
    _buildAllSkillsTab(state.journeys),
    _buildInProgressTab(state.journeys),
    _buildMasteredTab(state.journeys),
  ],
)
```

## Tab Content Implementation

### In Progress Tab
The In Progress tab filters journeys to show only those with skills that have progress > 0 and are not yet completed:

```dart
Widget _buildInProgressTab(List<CanDoJourney> journeys) {
  // Filter journeys with skills that have progress > 0 and are not completed
  final inProgressJourneys = journeys
      .where((journey) => journey.skills.any(
            (skill) => skill.progress > 0 && !skill.completed,
          ))
      .toList();

  // Return UI with empty state handling and filtered content
  // ...
}
```

### Mastered Tab
The Mastered tab filters journeys to show only those with completed skills:

```dart
Widget _buildMasteredTab(List<CanDoJourney> journeys) {
  // Filter journeys with skills that are completed
  final masteredJourneys = journeys
      .where((journey) => journey.skills.any((skill) => skill.completed))
      .toList();

  // Return UI with empty state handling and filtered content
  // ...
}
```

## Navigation Between Tabs
Navigation between tabs is implemented in various UI components:

1. **Empty State Buttons**: In empty states of "In Progress" and "Mastered" tabs, buttons navigate to the "All Topics" tab:
   ```dart
   ElevatedButton(
     onPressed: () {
       _switchToTab(0); // Switch to All Topics tab
     },
     // Button styling...
     child: const Text('Browse all topics'),
   )
   ```

2. **Journey Card Actions**: The "Continue" button in journey cards checks if there are in-progress skills and navigates to the "In Progress" tab:
   ```dart
   AppButton(
     text: "Continue",
     onPressed: () {
       bool hasInProgressSkills = journey.skills.any(
         (skill) => skill.progress > 0 && !skill.completed,
       );
       if (hasInProgressSkills) {
         _switchToTab(1); // Switch to In Progress tab
       }
     },
     // Button styling...
   )
   ```

3. **Achievement Button**: When a journey has completed skills, an achievement icon button is shown that navigates to the "Mastered" tab:
   ```dart
   IconButton(
     icon: const Icon(Icons.emoji_events, color: Colors.amber),
     onPressed: () {
       _switchToTab(2); // Switch to Mastered tab
     },
   )
   ```

## Resource Cleanup
The TabController is properly cleaned up in the dispose method:

```dart
@override
void dispose() {
  _tabController.removeListener(_handleTabChange);
  _tabController.dispose();
  super.dispose();
}
```

## Best Practices
1. **State Management**: Use a state variable (`_currentTabIndex`) to track the current tab
2. **Animation**: Include animation duration and curve for smoother tab transitions
3. **Empty States**: Provide meaningful empty states with navigation options
4. **Conditional Navigation**: Check conditions before switching tabs (e.g., check if skills are in progress)

## Testing Tips
To test the tab switching functionality:
1. Verify that tapping each tab updates the displayed content
2. Test programmatic navigation by tapping buttons that should switch tabs
3. Check that the tab indicator updates correctly when switching tabs
4. Ensure the tab state persists when data is refreshed
