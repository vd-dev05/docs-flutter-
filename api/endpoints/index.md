# API Endpoints Index

Đây là tài liệu tổng hợp tất cả các API endpoint của BlaBló App. Để xem chi tiết về từng API, hãy nhấp vào liên kết tương ứng.

## Story API Endpoints

- **[GET /api/playlists](./story_endpoints.md#get-stories-list)** - Lấy danh sách stories
- **[GET /api/playlists/{id}](./story_endpoints.md#get-story-by-id)** - Lấy thông tin chi tiết về một story
- **[DELETE /api/playlists/{id}](./story_endpoints.md#delete-story)** - Xóa một story
- **[POST /api/playlists](./story_endpoints.md#create-story)** - Tạo một story mới
- **[PUT /api/playlists/{id}](./story_endpoints.md#update-story)** - Cập nhật thông tin story
- **[POST /api/playlists/{id}/favorite](./story_endpoints.md#mark-story-as-favorite)** - Đánh dấu story là yêu thích
- **[POST /api/playlists/{id}/complete](./story_endpoints.md#mark-story-as-completed)** - Đánh dấu story là đã hoàn thành

## Vocabulary API Endpoints

- **[GET /api/vocabulary](./vocabulary_endpoints.md#get-vocabulary-list)** - Lấy danh sách từ vựng
- **[POST /api/vocabulary](./vocabulary_endpoints.md#add-vocabulary)** - Thêm từ vựng mới
- **[GET /api/vocabulary/{id}](./vocabulary_endpoints.md#get-vocabulary-by-id)** - Lấy thông tin chi tiết về một từ vựng
- **[PUT /api/vocabulary/{id}](./vocabulary_endpoints.md#update-vocabulary)** - Cập nhật thông tin từ vựng
- **[DELETE /api/vocabulary/{id}](./vocabulary_endpoints.md#delete-vocabulary)** - Xóa một từ vựng
- **[GET /api/vocabulary/category/{categoryName}](./vocabulary_endpoints.md#get-vocabulary-by-category)** - Lấy từ vựng theo danh mục
- **[POST /api/vocabulary/{id}/learn](./vocabulary_endpoints.md#mark-vocabulary-as-learned)** - Đánh dấu từ vựng đã học

## User API Endpoints

- **[POST /api/auth/register](./user_endpoints.md#user-registration)** - Đăng ký người dùng mới
- **[POST /api/auth/login](./user_endpoints.md#user-login)** - Đăng nhập
- **[POST /api/auth/social/google](./user_endpoints.md#social-login-google)** - Đăng nhập bằng Google
- **[POST /api/auth/social/facebook](./user_endpoints.md#social-login-facebook)** - Đăng nhập bằng Facebook
- **[GET /api/user/profile](./user_endpoints.md#get-user-profile)** - Lấy thông tin người dùng
- **[PUT /api/user/profile](./user_endpoints.md#update-user-profile)** - Cập nhật hồ sơ người dùng
- **[PUT /api/user/settings](./user_endpoints.md#update-user-settings)** - Cập nhật cài đặt người dùng
- **[POST /api/auth/password/reset-request](./user_endpoints.md#password-reset-request)** - Yêu cầu đặt lại mật khẩu
- **[POST /api/auth/password/reset](./user_endpoints.md#reset-password)** - Đặt lại mật khẩu
- **[POST /api/auth/logout](./user_endpoints.md#logout)** - Đăng xuất
- **[DELETE /api/user](./user_endpoints.md#delete-account)** - Xóa tài khoản

## Can-Do Journey API Endpoints

- **[GET /api/cando/journey](./cando_endpoints.md#get-user-journey)** - Lấy thông tin về hành trình học tập
- **[POST /api/cando/quest/{questId}/complete](./cando_endpoints.md#complete-quest)** - Hoàn thành một nhiệm vụ
- **[GET /api/cando/quests](./cando_endpoints.md#get-available-quests)** - Lấy danh sách các nhiệm vụ có sẵn
- **[GET /api/cando/quest/{questId}](./cando_endpoints.md#get-quest-details)** - Lấy thông tin chi tiết về một nhiệm vụ
- **[GET /api/cando/levels](./cando_endpoints.md#get-cefr-levels)** - Lấy thông tin về các cấp độ CEFR
- **[PUT /api/cando/level](./cando_endpoints.md#update-user-level)** - Cập nhật cấp độ người dùng

## Onboarding API Endpoints

- **[GET /api/onboarding/flow](./onboarding_endpoints.md#get-onboarding-flow)** - Lấy thông tin về quy trình onboarding
- **[POST /api/onboarding/step/{stepId}](./onboarding_endpoints.md#update-onboarding-step)** - Cập nhật bước onboarding
- **[GET /api/onboarding/proficiency-test](./onboarding_endpoints.md#get-proficiency-test)** - Lấy bài kiểm tra trình độ
- **[POST /api/onboarding/proficiency-test/submit](./onboarding_endpoints.md#submit-proficiency-test)** - Gửi bài kiểm tra trình độ
- **[POST /api/onboarding/complete](./onboarding_endpoints.md#complete-onboarding)** - Hoàn thành quá trình onboarding
- **[GET /api/onboarding/status](./onboarding_endpoints.md#get-onboarding-status)** - Kiểm tra trạng thái onboarding
- **[POST /api/onboarding/skip](./onboarding_endpoints.md#skip-onboarding)** - Bỏ qua quá trình onboarding
