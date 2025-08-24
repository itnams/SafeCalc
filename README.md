# SafeCalc - Ứng dụng Calculator ẩn với kho lưu trữ bí mật

## Mô tả
SafeCalc là một ứng dụng iOS được thiết kế để trông giống như một ứng dụng Calculator bình thường, nhưng thực chất có một kho lưu trữ bí mật bên trong. Ứng dụng này cho phép người dùng lưu trữ an toàn các ghi chú, tệp, ảnh và video.

## Tính năng chính

### 1. Thiết lập mật khẩu lần đầu
- Yêu cầu người dùng nhập mật khẩu tối thiểu 4 ký tự
- Chỉ cho phép nhập số
- Xác nhận mật khẩu để tránh nhập sai

### 2. Giao diện Calculator hoàn chỉnh
- Giao diện giống hệt ứng dụng Calculator của iOS
- Hỗ trợ đầy đủ các phép tính: cộng, trừ, nhân, chia
- Các chức năng phụ: phần trăm, đổi dấu, xóa
- Thiết kế responsive và dễ sử dụng

### 3. Kho lưu trữ bí mật
- **Ghi chú**: Tạo, chỉnh sửa và xóa các ghi chú văn bản
- **Tệp**: Lưu trữ các loại tệp khác nhau
- **Ảnh**: Lưu trữ và xem ảnh
- **Video**: Lưu trữ và phát video

### 4. Bảo mật
- Mật khẩu được lưu trữ an toàn trong UserDefaults
- Chỉ hiển thị kho lưu trữ khi nhập đúng mật khẩu
- Giao diện calculator hoàn toàn bình thường để tránh nghi ngờ

## Cách sử dụng

### Lần đầu sử dụng
1. Mở ứng dụng
2. Nhập mật khẩu tối thiểu 4 ký tự số
3. Xác nhận mật khẩu
4. Ứng dụng sẽ chuyển sang giao diện calculator

### Sử dụng hàng ngày
1. Mở ứng dụng - sẽ thấy giao diện calculator
2. Sử dụng calculator bình thường
3. Để truy cập kho lưu trữ bí mật:
   - Nhấn vào biểu tượng khóa (🔒) ở góc phải màn hình
   - Nhập mật khẩu đã thiết lập
   - Sẽ được chuyển đến kho lưu trữ bí mật

### Trong kho lưu trữ bí mật
- Sử dụng các tab để chuyển đổi giữa các loại dữ liệu
- Nhấn nút "+" để thêm mới
- Vuốt sang trái để xóa các mục
- Nhấn "Đóng" để quay lại calculator

## Cấu trúc dự án

```
SafeCalc/
├── SafeCalcApp.swift          # Điểm khởi đầu của ứng dụng
├── ContentView.swift         # View chính quản lý luồng điều hướng
├── UserDefaultsManager.swift # Quản lý mật khẩu và trạng thái
├── PasswordSetupView.swift   # Màn hình thiết lập mật khẩu lần đầu
├── CalculatorView.swift      # Giao diện và chức năng calculator
├── SecretStorageView.swift   # Kho lưu trữ bí mật
├── ColorExtensions.swift     # Extension cho Color
└── Assets.xcassets/          # Tài nguyên hình ảnh
```

## Yêu cầu hệ thống
- iOS 15.0 trở lên
- Xcode 13.0 trở lên
- Swift 5.5 trở lên

## Cài đặt và chạy
1. Clone dự án về máy
2. Mở file `SafeCalc.xcodeproj` trong Xcode
3. Chọn thiết bị hoặc simulator
4. Nhấn Run (⌘+R)

## Lưu ý bảo mật
- Mật khẩu được lưu trữ cục bộ trên thiết bị
- Không có mã hóa bổ sung - chỉ dựa vào bảo mật của iOS
- Nên sử dụng mật khẩu mạnh và không chia sẻ với người khác

## Phát triển thêm
Ứng dụng có thể được mở rộng với các tính năng:
- Mã hóa dữ liệu với mật khẩu
- Đồng bộ hóa với iCloud
- Hỗ trợ Face ID/Touch ID
- Sao lưu và khôi phục dữ liệu
- Thêm các loại dữ liệu khác (audio, documents)

## Giấy phép
Dự án này được phát triển cho mục đích giáo dục và sử dụng cá nhân.
# SafeCalc
