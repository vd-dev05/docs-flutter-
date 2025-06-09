# Story Deletion

## Implementation

Tính năng xóa story trong BlaBló App được triển khai bằng cách kết hợp:
1. Flutter Dismissible widget cho UI swipe-to-delete
2. API call thông qua StoryCubit
3. Optimistic update pattern với rollback khi có lỗi

## Swipe-to-Delete UI

Story Deletion UI được triển khai trong `story_screen.dart` bằng cách sử dụng `Dismissible` widget:

```dart
Dismissible(
  key: ValueKey(itemId),
  direction: DismissDirection.endToStart,
  dismissThresholds: const {DismissDirection.endToStart: 0.33},
  onUpdate: (details) {
    final isDragging = details.progress > 0.15;
    final isCurrentlyDragging = _draggingItems.contains(itemId);

    if (isDragging != isCurrentlyDragging) {
      setState(() {
        if (isDragging) {
          _draggingItems.add(itemId);
        } else {
          _draggingItems.remove(itemId);
        }
      });
    }
  },
  onDismissed: (direction) async {
    // First remove from local state
    setState(() {
      _draggingItems.remove(itemId);
      _expandedItems.remove(itemId);
    });

    // Then delete from data source through cubit
    context.read<StoryCubit>().deleteStory(story.id);
    
    // Show snackbar with delete confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${story.title} deleted successfully'),
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // Reload full story list on undo
            context.read<StoryCubit>().getStories();
          },
          textColor: Colors.white,
        ),
      ),
    );
  },
  background: Container(color: Colors.transparent),
  secondaryBackground: Container(
    color: Colors.transparent,
    child: Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(right: 16.0),
        width: 210,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFFFF2D55),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 20.0),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
  child: StoryItemCard(...),
)
```

### Các tính năng chính:

1. **Threshold 33%**: Story chỉ bị xóa khi người dùng swipe hơn 1/3 chiều rộng màn hình
2. **Visual Feedback**: Hiển thị feedback khi swipe đạt 15% để người dùng biết đang thực hiện hành động xóa
3. **Confirmation**: Hiển thị thông báo xác nhận khi xóa thành công với tùy chọn "UNDO"

## Delete API Implementation

API call được thực hiện qua `StoryCubit`:

```dart
Future<void> deleteStory(int id) async {
  try {
    // Backup current state for rollback if needed
    final currentState = state;
    if (currentState is StoryLoaded) {
      // Optimistic update - remove from UI immediately
      final updatedStories =
          currentState.stories.where((story) => story.id != id).toList();
      emit(StoryLoaded(updatedStories));

      print('Calling delete API for story ID: $id');
      final response = await _deletePlaylistFromApi(id);
      print('Delete API response: $response');

      if (response != null && response['success']) {
        print('Delete successful');
        // Keep the optimistically updated list for now
        // In production, we should properly parse the response['stories']
        // and update the state with the server data
      } else {
        print('Delete failed');
        // API call failed - restore original state
        emit(StoryLoaded(currentState.stories));
        if (response != null && response['message'] != null) {
          emit(StoryError(response['message']));
        } else {
          emit(StoryError('Failed to delete story')); 
        }
      }
    }
  } catch (e) {
    print('Error in deleteStory: $e');
    emit(StoryError('Error deleting story: ${e.toString()}')); 
  }
}
```

### Phương thức gọi API:

```dart
Future<Map<String, dynamic>?> _deletePlaylistFromApi(int id) async {
  try {
    final deviceId = await _getDeviceId();
    final uri = Uri.parse(
      'https://mocapiblablo-production.up.railway.app/api/playlists/$id',
    );

    final client = http.Client();
    final response = await client.delete(
      uri,
      headers: {'Content-Type': 'application/json', 'user_id': deviceId},
    );
    
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Story deleted successfully',
          'stories': responseData['data'] ?? [] 
        };
      } catch (e) {
        print('Error parsing response: $e');
        return null;
      }
    } else if (response.statusCode == 404) {
      print('Story not found or user_id missing');
      return null;
    }
    return null;
  } catch (e) {
    print('API error: $e');
    return null;
  }
}
```

## API Response Format

API response khi xóa story có format như sau:

```json
{
  "message": "Story deleted successfully",
  "data": [
    {
      "id": 1,
      "title": "Story 1",
      ...
    },
    ...
  ]
}
```

## Mock API Endpoint

Mock API endpoint được triển khai với Express.js như sau:

```javascript
app.delete('/api/playlists/:id', (req, res) => {
  const deviceId = req.headers['user_id'];

  if (!deviceId) {
    return res.status(404).json({ error: 'user_id is required in header' });
  }

  const storyId = req.params.id;
  const index = tasks.findIndex(task => task.id === storyId);

  if (index === -1) {
    return res.status(404).json({ error: 'Story not found' });
  }

  // Remove item from tasks
  tasks.splice(index, 1);

  // Return updated list to client
  res.json({
    message: 'Story deleted successfully',
    data: tasks
  });
});
```

## Best Practices

1. **Optimistic Updates**: Update UI ngay lập tức để tránh người dùng chờ đợi
2. **Error Handling**: Rollback về state cũ khi API call thất bại
3. **User Feedback**: Luôn hiển thị thông báo để người dùng biết hành động đã thành công hay thất bại
4. **State Management**: Sử dụng Bloc/Cubit để quản lý state một cách hiệu quả
5. **Debugging**: Thêm log messages để debug API calls và xử lý lỗi
