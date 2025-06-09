# Story Playback

## Overview

Story Playback là tính năng cho phép người dùng nghe audio của story, giúp họ cải thiện kỹ năng nghe tiếng Anh. Tính năng này bao gồm các chức năng phát, tạm dừng, tiếp tục, và điều khiển âm lượng.

## Kiến trúc

Story Playback được triển khai bằng cách sử dụng:

1. **just_audio**: Package xử lý audio playback
2. **GlobalAudioProvider**: Provider quản lý global audio state
3. **GlobalAudioControlBar**: Widget hiển thị controls cho audio player

## Implementation

### GlobalAudioState

```dart
class GlobalAudioState {
  final AudioPlayer player;
  final String? currentAudioUrl;
  final String? currentStoryTitle;
  final int? currentStoryId;
  final ProcessingState processingState;
  final bool isPlaying;
  final Duration? duration;
  final Duration? position;
  
  // Methods for controlling playback
  Future<void> play(String url, String title, int storyId) async {...}
  void pause() {...}
  void resume() {...}
  void stop() {...}
  void seekTo(Duration position) {...}
}
```

### GlobalAudioControlBar

Widget này hiển thị thông tin về story đang phát và các controls để điều khiển playback:

```dart
class GlobalAudioControlBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(globalAudioStateProvider);
    
    // Logic để hiển thị audio controls
    // Nút play/pause, thanh tiến trình, thông tin story
  }
}
```

## Key Features

1. **Global Audio State**: Audio state được quản lý ở cấp application, cho phép audio tiếp tục phát khi người dùng điều hướng giữa các màn hình
2. **Background Playback**: Người dùng có thể tiếp tục nghe audio khi app ở background
3. **Playback Controls**: Play, pause, seek, và điều chỉnh volume
4. **Visual Feedback**: Hiển thị thông tin story đang phát và tiến trình phát

## Best Practices

1. **Resource Management**: Audio resources được giải phóng đúng cách khi không còn cần thiết
2. **Error Handling**: Xử lý các lỗi như không thể tải audio, định dạng không được hỗ trợ
3. **UX Considerations**: Cung cấp feedback trực quan để người dùng biết audio đang được xử lý
