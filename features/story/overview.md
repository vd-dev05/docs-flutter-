# Story Feature Overview

## Mô tả

Story Feature là tính năng chính của BlaBló App, cho phép người dùng học tiếng Anh qua những câu chuyện tương tác. Người dùng có thể nghe, đọc và làm bài tập dựa trên các câu chuyện.

## Kiến trúc

Story Feature được xây dựng theo Clean Architecture:

### Domain Layer
- **Entities**: `StoryItem`, `StoryEntity`
- **Repository Interfaces**: `StoryRepository`, `StoryLessonRepository`
- **Use Cases**: `GetStoriesUseCase`, `GetStoryUseCase`, `DeleteStoryUseCase`

### Data Layer
- **Models**: `StoryItemModel`, `StoryModel`
- **Repository Implementations**: `StoryRepositoryImpl`, `StoryLessonRepositoryImpl`
- **Data Sources**: `StoryRemoteDataSource`, `StoryLessonRemoteDataSource`

### Presentation Layer
- **Cubit/Bloc**: `StoryCubit`
- **Screens**: `StoryScreen`
- **Widgets**: `StoryItemCard`

## Luồng dữ liệu

1. **Lấy danh sách Stories**:
   - `StoryCubit.getStories()` -> `GetStoriesUseCase` -> `StoryRepository` -> `StoryRemoteDataSource`
   - Dữ liệu được trả về theo luồng ngược lại và emit bởi `StoryCubit`

2. **Lấy Story Detail**:
   - `StoryLessonBloc.getStory()` -> `GetStoryUseCase` -> `StoryLessonRepository` -> `StoryLessonRemoteDataSource`
   
3. **Xóa Story**:
   - `StoryCubit.deleteStory()` -> API call trực tiếp -> Cập nhật UI

## UI Components

- **StoryScreen**: Hiển thị danh sách stories
- **StoryItemCard**: Card hiển thị thông tin cơ bản của story
- **StoryLessonScreen**: Hiển thị nội dung chi tiết của story

## Features

1. **Swipe to Delete**: Người dùng có thể vuốt sang phải để xóa story
2. **Audio Playback**: Người dùng có thể nghe audio của story
3. **Pagination**: Danh sách stories được phân trang để tối ưu performance
4. **Offline Mode**: Stories có thể được cache để sử dụng offline
