# Can Do Journey Feature Update Guide

This document provides guidance on the implementation and updates to the "Can Do Journey" feature in the Blablo App.

## Overview

The Can Do Journey feature displays a list of language learning skills organized into units. Each unit represents a topic (e.g., "I can dine out") and contains multiple lessons with specific skills the user can learn, as well as additional stories for practice.

## API Response Structure

The API endpoint returns data in the following format:

```json
{
  "units": [
    {
      "unit_id": "unit-001",
      "title": "I can dine out",
      "progress": 67,
      "icon_url": "https://cdn.example.com/icons/food.png",
      "lessons": [
        {
          "lesson_id": "lesson-001",
          "title": "Booking a Table",
          "key_expression": "I'd like to reserve a table",
          "key_vocab": ["Reservation", "quiet", "seating"],
          "status": "not_started"
        },
        {
          "lesson_id": "lesson-002",
          "title": "Describing Taste & Texture",
          "key_expression": "Is it very spicy?",
          "key_vocab": ["Spicy", "sweet", "crispy"],
          "status": "done"
        },
        {
          "lesson_id": "lesson-003",
          "title": "Dish Not as Ordered",
          "key_expression": "I ordered the salmon",
          "key_vocab": ["Wrong", "replace", "mistake"],
          "status": "in_progress",
          "progress_percent": 38
        }
      ],
      "extra_stories": [
        {
          "lesson_id": "story-001",
          "title": "Splitting the Bill",
          "key_expression": "Could we split the bill?",
          "key_vocab": ["Split", "separate", "together"],
          "status": "not_started"
        }
      ]
    }
  ]
}
```

## Implementation Details

### Model Classes

1. **CanDoJourney**: Entity class for representing a journey
   - Contains title, progress, icon, a list of skills (lessons), and a list of stories

2. **CanDoSkill**: Entity class for representing a lesson or story
   - Contains title, key expression, progress, and vocabulary items

3. **CanDoSubSkill**: Entity class for representing vocabulary items
   - Contains title, emoji, and completion status

### API Data Mapping

The API response is mapped to our domain models using the following transformation:

- `unit_id` → Journey.id
- `title` → Journey.title
- `progress` (converted from percentage to decimal) → Journey.progress
- `icon_url` → Journey.imagePath
- `lessons` → Journey.skills (mapped to CanDoSkill objects)
- `extra_stories` → Journey.stories (mapped to CanDoSkill objects using the same structure)
- For each lesson/story:
  - `lesson_id` → Skill.id
  - `title` → Skill.title
  - `key_expression` → Skill.subtitle
  - `status` → Used to determine Skill.completed and Skill.progress
  - `progress_percent` → Used to calculate Skill.progress (if status is "in_progress")
  - `key_vocab` → Mapped to List<CanDoSubSkill>

### Vocabulary Emoji Mapping

We've added automatic emoji mapping for vocabulary items:

```dart
static String? _getEmojiForVocab(String vocab) {
  final Map<String, String> emojiMap = {
    'reservation': '📝',
    'quiet': '🔇',
    'seating': '💺',
    'spicy': '🌶️',
    'sweet': '🍯',
    'crispy': '🍞',
    'wrong': '❌',
    'replace': '🔄',
    'mistake': '⚠️',
    'split': '✂️',
    'separate': '↔️',
    'together': '🤝',
  };
  
  // Look for word matches
  String lowerVocab = vocab.toLowerCase();
  for (var key in emojiMap.keys) {
    if (lowerVocab.contains(key)) {
      return emojiMap[key];
    }
  }
  
  // Default emojis
  final List<String> defaultEmojis = ['📚', '🔤', '💬', '🗣️', '📝'];
  return defaultEmojis[vocab.hashCode % defaultEmojis.length];
}
```

### UI Implementation

The UI follows the design with:

1. **Tab Bar**: For switching between "All topics", "In progress", and "Mastered" views
2. **Create Topic Card**: Allows users to create custom topics and lessons
3. **Journey Cards**: Each representing a unit with:
   - Header with icon and title
   - Lesson sections with progress indicators
   - Stories section displaying extra stories from the API
   - Action buttons

#### Lesson Display

Each lesson is shown with:
- Title with progress indicator (percentage badge)
- Key expression with speech bubble icon
- Vocabulary chips in a wrap layout

#### Stories Display

The stories section appears if the journey has extra stories from the API:
- Each story is displayed with its title and key expression
- Stories are interactive with tap feedback
- Vocabulary chips are displayed for each story

### Style Guidelines

Color schemes used:
- Completed items: `#E8F5E9` (light green background)
- In-progress items: `#FFF8E1` (light yellow background)
- Not started items: `#F5F5F5` (light grey background)
- Progress indicators: 
  - Completed: Green (`#4CAF50`)
  - In progress: Amber (`#FFC107`)
- Primary action buttons: Pink (`#FF3DC7`)
- Create button gradient: Linear gradient from `#BDF4A4` → `#B4D6FF` → `#F3C8FF`

## Testing

Test cases should cover:
1. Loading and parsing API responses
2. Handling different lesson statuses
3. Displaying correct progress indicators
4. UI responsiveness for different screen sizes

## Future Improvements

1. Add functionality to create custom topics and lessons
2. Implement lesson detail screens
3. Add interactive learning activities within lessons
4. Add offline support to continue learning without internet connection
5. Implement sharing functionality for completed lessons