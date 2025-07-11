# BlaBló App Documentation

## Cấu trúc tài liệu

Tài liệu của BlaBló App được tổ chức thành các phần chính sau:

1. **Architecture** - `/architecture`: Kiến trúc và thiết kế hệ thống
   - [Clean Architecture](./architecture/README.md)
   - Design Patterns
   - Data Flow

2. **Features** - `/features`: Tài liệu về các tính năng
   - [Story Feature](./features/story/overview.md)
   - [English Learning](./features/english_learning/overview.md)
   - [Vocabulary](./features/vocabulary/overview.md)
   - [Onboarding](./features/onboarding/flow.md)
   - [Can-Do Journey](./features/cando/journey_update.md)
   - [User Authentication](./features/authentication/registration_flow.md)
   - [Navigation](./features/navigation/README.md)

3. **Setup** - `/setup`: Hướng dẫn cài đặt và cấu hình
   - [Environment Variables](./setup/environment_variables.md)
   - [Firebase Configuration](./setup/firebase_configuration.md)
   - [Multi-Platform Setup](./setup/multi_platform_setup.md)
   - [Authentication Setup](./setup/authentication/overview.md)
     - [Google Sign-In](./setup/authentication/google_sign_in_setup.md)
     - [Facebook Authentication](./setup/authentication/facebook_auth_integration.md)
     - [Supabase Google Auth](./setup/authentication/supabase_google_auth.md)

4. **API** - `/api`: Tài liệu API và integration
   - [API Configuration](./api/api_configuration.md)
   - API Endpoints
   - Third Party APIs

5. **Development** - `/development`: Quy trình phát triển
   - [Development Guide](./development/development_guide.md)
   - Coding Standards
   - Testing Guidelines
   - CI/CD Pipeline

6. **UI/UX** - `/ui`: Thiết kế giao diện và trải nghiệm người dùng
   - [Design System](./ui/design_system.md)
   - [Reusable Components](./ui/reusable_components.md)
   - UI Components
   - Style Guide

7. **Guides** - `/guides`: Hướng dẫn khác
   - [Secure Deployment](./guides/secure_deployment.md)
   - Troubleshooting
     - [Error Log](./guides/troubleshooting/error_log.md)
   - Optimization
     - [Optimization Summary](./guides/optimization/summary.md)
   - Best Practices

## Quy ước đặt tên

- Tất cả tên file đều sử dụng snake_case và có phần mở rộng `.md`
- Tên file nên mô tả rõ nội dung của tài liệu
- Mỗi thư mục con nên có file `README.md` mô tả nội dung của thư mục đó
