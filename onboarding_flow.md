# Quy trình Onboarding trong BlaBló App

Tài liệu này mô tả quy trình onboarding của người dùng trong BlaBló App, bao gồm các màn hình, luồng dữ liệu và cách sử dụng.

## Mục lục

1. [Tổng quan](#tổng-quan)
2. [Cấu trúc dữ liệu](#cấu-trúc-dữ-liệu)
3. [Luồng màn hình](#luồng-màn-hình)
4. [Quản lý trạng thái](#quản-lý-trạng-thái)
5. [Cách sử dụng](#cách-sử-dụng)
6. [Mở rộng](#mở-rộng)

## Tổng quan

Quy trình onboarding của BlaBló App bao gồm 3 màn hình chính:

1. **Goal Selection Screen**: Người dùng chọn mục tiêu học tiếng Anh của họ
2. **Topic Selection Screen**: Người dùng chọn các chủ đề yêu thích
3. **English Level Screen**: Người dùng chọn cấp độ tiếng Anh hiện tại của họ

Dữ liệu từ các màn hình này được lưu trữ tập trung trong `OnboardingBloc` để có thể truy cập từ bất kỳ nơi nào trong ứng dụng.

## Cấu trúc dữ liệu

### OnboardingData

```dart
class OnboardingData extends Equatable {
  /// Mục tiêu học tiếng Anh của người dùng
  final String? goalKey;
  
  /// Tiêu đề mục tiêu học tiếng Anh của người dùng
  final String? goalTitle;
  
  /// Danh sách các chủ đề yêu thích của người dùng
  final List<String> favoriteTopics;
  
  /// Cấp độ tiếng Anh của người dùng
  final String? englishLevel;

  const OnboardingData({
    this.goalKey,
    this.goalTitle,
    this.favoriteTopics = const [],
    this.englishLevel,
  });

  /// Kiểm tra xem dữ liệu onboarding đã hoàn thành chưa
  bool get isComplete {
    return goalKey != null && favoriteTopics.isNotEmpty && englishLevel != null;
  }
}
```

## Luồng màn hình

### 1. Goal Selection Screen

Màn hình đầu tiên trong quy trình onboarding, nơi người dùng chọn mục tiêu học tiếng Anh của họ.

- Hiển thị danh sách các mục tiêu phổ biến
- Cho phép người dùng nhập mục tiêu tùy chỉnh
- Lưu trữ mục tiêu đã chọn vào `OnboardingBloc`
- Chuyển đến màn hình Topic Selection

### 2. Topic Selection Screen

Màn hình thứ hai, nơi người dùng chọn các chủ đề yêu thích.

- Hiển thị lưới các chủ đề phổ biến
- Cho phép người dùng chọn nhiều chủ đề
- Cho phép người dùng nhập chủ đề tùy chỉnh
- Lưu trữ các chủ đề đã chọn vào `OnboardingBloc`
- Chuyển đến màn hình English Level

### 3. English Level Screen

Màn hình cuối cùng, nơi người dùng chọn cấp độ tiếng Anh hiện tại của họ.

- Hiển thị danh sách các cấp độ tiếng Anh
- Lưu trữ cấp độ đã chọn vào `OnboardingBloc`
- Hoàn thành quy trình onboarding và chuyển đến màn hình Home

## Quản lý trạng thái

Chúng tôi sử dụng BLoC pattern để quản lý trạng thái của quy trình onboarding:

### OnboardingBloc

```dart
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingInitial()) {
    on<SetGoalEvent>(_onSetGoal);
    on<SetFavoriteTopicsEvent>(_onSetFavoriteTopics);
    on<SetEnglishLevelEvent>(_onSetEnglishLevel);
    on<ResetOnboardingEvent>(_onResetOnboarding);
  }

  void _onSetGoal(SetGoalEvent event, Emitter<OnboardingState> emit) {
    final updatedData = state.data.copyWith(
      goalKey: event.goalKey,
      goalTitle: event.goalTitle,
    );
    
    emit(OnboardingUpdated(updatedData));
    _checkCompletion(updatedData, emit);
  }

  void _onSetFavoriteTopics(SetFavoriteTopicsEvent event, Emitter<OnboardingState> emit) {
    final updatedData = state.data.copyWith(
      favoriteTopics: event.topics,
    );
    
    emit(OnboardingUpdated(updatedData));
    _checkCompletion(updatedData, emit);
  }

  void _onSetEnglishLevel(SetEnglishLevelEvent event, Emitter<OnboardingState> emit) {
    final updatedData = state.data.copyWith(
      englishLevel: event.level,
    );
    
    emit(OnboardingUpdated(updatedData));
    _checkCompletion(updatedData, emit);
  }

  void _checkCompletion(OnboardingData data, Emitter<OnboardingState> emit) {
    if (data.isComplete) {
      emit(OnboardingCompleted(data));
    }
  }
}
```

## Cách sử dụng

### 1. Lưu dữ liệu vào OnboardingBloc

```dart
// Lưu mục tiêu
context.read<OnboardingBloc>().add(
  SetGoalEvent(
    goalKey: 'career',
    goalTitle: 'Boost my career',
  ),
);

// Lưu chủ đề yêu thích
context.read<OnboardingBloc>().add(
  SetFavoriteTopicsEvent(
    topics: ['business', 'tech', 'news'],
  ),
);

// Lưu cấp độ tiếng Anh
context.read<OnboardingBloc>().add(
  SetEnglishLevelEvent(
    level: 'intermediate',
  ),
);
```

### 2. Đọc dữ liệu từ OnboardingBloc

```dart
// Sử dụng BlocBuilder để lắng nghe thay đổi
BlocBuilder<OnboardingBloc, OnboardingState>(
  builder: (context, state) {
    final onboardingData = state.data;
    
    return Column(
      children: [
        Text('Goal: ${onboardingData.goalTitle ?? 'Not set'}'),
        Text('Topics: ${onboardingData.favoriteTopics.join(', ')}'),
        Text('Level: ${onboardingData.englishLevel ?? 'Not set'}'),
      ],
    );
  },
);

// Hoặc đọc trực tiếp (không phản ứng với thay đổi)
final onboardingData = context.read<OnboardingBloc>().state.data;
```

### 3. Phản ứng với sự hoàn thành của quy trình onboarding

```dart
BlocListener<OnboardingBloc, OnboardingState>(
  listener: (context, state) {
    if (state is OnboardingCompleted) {
      // Quy trình onboarding đã hoàn thành
      // Gửi dữ liệu lên server, cập nhật trạng thái người dùng, v.v.
      
      // Chuyển đến màn hình Home
      NavigationHelper.navigateToAndRemoveUntil(
        context,
        const HomeScreen(),
      );
    }
  },
  child: YourWidget(),
);
```

## Mở rộng

### Thêm bước mới vào quy trình onboarding

1. Cập nhật `OnboardingData` để bao gồm dữ liệu mới
2. Thêm event mới vào `OnboardingBloc`
3. Tạo màn hình mới
4. Cập nhật luồng điều hướng

### Lưu trữ dữ liệu onboarding

Để lưu trữ dữ liệu onboarding vĩnh viễn, bạn có thể:

1. Tạo repository và datasource cho onboarding
2. Thêm usecase để lưu và lấy dữ liệu onboarding
3. Cập nhật `OnboardingBloc` để sử dụng usecase này

```dart
// Ví dụ về repository
class OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;
  
  OnboardingRepository({required this.localDataSource});
  
  Future<void> saveOnboardingData(OnboardingData data) {
    return localDataSource.saveOnboardingData(data);
  }
  
  Future<OnboardingData> getOnboardingData() {
    return localDataSource.getOnboardingData();
  }
}
```
