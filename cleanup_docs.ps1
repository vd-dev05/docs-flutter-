# Cleanup script cho việc tổ chức lại docs

# Kiểm tra xác nhận trước khi xóa
Write-Host "Cảnh báo: Script này sẽ xóa các file tài liệu cũ đã được di chuyển vào cấu trúc thư mục mới."
Write-Host "Đảm bảo rằng tất cả các file đã được di chuyển đầy đủ trước khi chạy script này."
$confirmation = Read-Host "Bạn có muốn tiếp tục không? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "Hủy thao tác xóa."
    exit
}

# Danh sách các file đã được di chuyển
$filesToRemove = @(
    "d:\Start Up\clone\blablo-app\docs\api_configuration_guide.md",
    "d:\Start Up\clone\blablo-app\docs\authentication_guide.md",
    "d:\Start Up\clone\blablo-app\docs\cando_journey_update_guide.md",
    "d:\Start Up\clone\blablo-app\docs\design_system.md",
    "d:\Start Up\clone\blablo-app\docs\development_guide.md",
    "d:\Start Up\clone\blablo-app\docs\english_learning_feature.md", 
    "d:\Start Up\clone\blablo-app\docs\english_learning_implementation_summary.md",
    "d:\Start Up\clone\blablo-app\docs\environment_variables_guide.md",
    "d:\Start Up\clone\blablo-app\docs\error_log.md",
    "d:\Start Up\clone\blablo-app\docs\facebook_auth_integration_guide.md",
    "d:\Start Up\clone\blablo-app\docs\firebase_configuration_guide.md",
    "d:\Start Up\clone\blablo-app\docs\google_sign_in_setup.md",
    "d:\Start Up\clone\blablo-app\docs\multi_platform_setup_guide.md",
    "d:\Start Up\clone\blablo-app\docs\onboarding_architecture.md",
    "d:\Start Up\clone\blablo-app\docs\onboarding_flow.md",
    "d:\Start Up\clone\blablo-app\docs\optimization_summary.md",
    "d:\Start Up\clone\blablo-app\docs\plan_supabase_google_auth_mobile.md",
    "d:\Start Up\clone\blablo-app\docs\reusable_components.md",
    "d:\Start Up\clone\blablo-app\docs\secure_deployment_guide.md",
    "d:\Start Up\clone\blablo-app\docs\tab_switching_implementation_guide.md",
    "d:\Start Up\clone\blablo-app\docs\user_registration_flow.md",
    "d:\Start Up\clone\blablo-app\docs\vocabulary_feature.md",
    "d:\Start Up\clone\blablo-app\docs\welcome_screen.md"
)

# Xóa từng file
foreach ($file in $filesToRemove) {
    if (Test-Path $file) {
        Remove-Item $file
        Write-Host "Đã xóa: $file"
    } else {
        Write-Host "File không tồn tại: $file"
    }
}

Write-Host "Hoàn tất dọn dẹp tài liệu."
