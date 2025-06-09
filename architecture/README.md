# Architecture Guide

## Clean Architecture Overview

BlaBló App được xây dựng theo nguyên tắc Clean Architecture, phân tách code thành các layer với trách nhiệm rõ ràng:

### 1. Domain Layer (Core Business Logic)

Chứa business logic cốt lõi của ứng dụng:

- **Entities**: Các đối tượng business core như `Story`, `Vocabulary`, `User`
- **Repository Interfaces**: Contract cho data operations
- **Use Cases**: Business actions như `GetStories`, `DeleteStory`

### 2. Data Layer (Data Access)

Xử lý việc truy xuất và lưu trữ dữ liệu:

- **Models**: Implement entities với logic serialize/deserialize
- **Repositories**: Implement repository interfaces 
- **Data Sources**: Local storage và API clients

### 3. Presentation Layer (UI)

Xử lý UI và user interaction:

- **Pages**: Các màn hình chính
- **Widgets**: Reusable UI components
- **Cubit/Bloc**: State management
- **ViewModels**: Logic presentation

### 4. Core Layer (Common Utilities)

Chứa shared code và utilities:

- **Constants**: App-wide constants
- **DI**: Dependency injection setup
- **Network**: API helpers
- **Theme**: Design system
- **Utils**: Helper functions

## Dependencies Flow

```
UI (Presentation) -> Business Logic (Domain) <- Data
                 \-> Data Layer           -/
```

## Benefits

1. **Maintainability**: Mỗi layer có responsibility riêng biệt
2. **Testability**: Business logic tách biệt khỏi UI/external dependencies
3. **Scalability**: Dễ dàng thêm features mới
4. **Flexibility**: UI/data sources có thể thay đổi độc lập

## Best Practices

1. Domain Layer không phụ thuộc layer khác
2. Data Layer chỉ phụ thuộc Domain Layer
3. Presentation Layer có thể phụ thuộc Domain và Data Layer
4. Luôn code theo interface
5. Sử dụng dependency injection
