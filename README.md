# App Tìm Trọ Sinh Viên

Ứng dụng giúp sinh viên tìm kiếm phòng trọ và chủ trọ đăng tin cho thuê phòng một cách dễ dàng.

## Tính năng chính

- **Đăng ký và đăng nhập**: Hỗ trợ đăng ký với các vai trò khác nhau (sinh viên, chủ trọ)
- **Quản lý người dùng**: Admin có thể quản lý tài khoản người dùng
- **Đăng tin phòng trọ**: Chủ trọ có thể đăng thông tin phòng trọ
- **Tìm kiếm phòng trọ**: Sinh viên có thể tìm kiếm phòng trọ với nhiều tiêu chí
- **Đánh giá và bình luận**: Đánh giá và bình luận về nhà trọ

## Công nghệ sử dụng

- **Frontend**: Flutter
- **Backend**: Node.js, Express
- **Database**: MySQL

## Cài đặt

### Backend

```bash
cd backend
npm install
npm start
```

### Frontend

```bash
flutter pub get
flutter run
```

## Tác giả

Nhóm Sinh Viên

## Cập nhật mới - Ver 1.2

### Quản lý người dùng nâng cao
- **Thêm quản lý trạng thái người dùng**: Admin có thể kích hoạt/khóa tài khoản người dùng (active/blocked)
- **Thêm quản lý điểm uy tín**: Hỗ trợ đánh giá người dùng với thang điểm 0-5 sao
- **Giao diện cập nhật thông tin người dùng**: Form chỉnh sửa thông tin đầy đủ với validation
- **Hiển thị trạng thái**: Hiển thị trực quan người dùng bị chặn bằng icon và màu sắc

### API Cải tiến
- Cập nhật API quản lý người dùng hỗ trợ các trường mới: status, reputation_score
- Bổ sung validation chặt chẽ cho dữ liệu đầu vào
- Trả về thông tin người dùng đã cập nhật sau khi cập nhật thành công

## Cấu trúc thư mục

```
lib/
  ├── models/          # Data models
  ├── providers/       # State management
  ├── screens/         # UI screens
  │   ├── admin/      # Admin screens
  │   ├── auth/       # Authentication screens
  │   ├── landlord/   # Landlord screens
  │   └── user/       # User screens
  ├── utils/          # Utility functions
  ├── navigation/     # Navigation logic
  └── main.dart       # Entry point
```

## API Endpoints

### Authentication
- POST /api/auth/login - Đăng nhập
- POST /api/auth/register - Đăng ký
- POST /api/auth/logout - Đăng xuất

### Admin API
- GET /api/admin/dashboard - Lấy thống kê tổng quan
- GET /api/admin/users - Lấy danh sách người dùng
- GET /api/admin/users/:id - Lấy thông tin người dùng
- POST /api/admin/users - Tạo người dùng mới
- PUT /api/admin/users/:id - Cập nhật thông tin người dùng (hỗ trợ status, reputation_score)
- DELETE /api/admin/users/:id - Xóa người dùng

### Users
- GET /api/users - Lấy danh sách người dùng
- GET /api/users/:id - Lấy thông tin người dùng
- PUT /api/users/:id - Cập nhật thông tin người dùng

### Boarding Houses
- GET /api/houses - Lấy danh sách nhà trọ
- POST /api/houses - Thêm nhà trọ mới
- GET /api/houses/:id - Lấy thông tin nhà trọ
- PUT /api/houses/:id - Cập nhật thông tin nhà trọ

### Rooms
- GET /api/rooms - Lấy danh sách phòng
- POST /api/rooms - Thêm phòng mới
- GET /api/rooms/:id - Lấy thông tin phòng
- PUT /api/rooms/:id - Cập nhật thông tin phòng

### Bookings
- GET /api/bookings - Lấy danh sách đặt phòng
- POST /api/bookings - Tạo đặt phòng mới
- PUT /api/bookings/:id - Cập nhật trạng thái đặt phòng

## Đóng góp

1. Fork dự án
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit thay đổi (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## License

MIT License - xem [LICENSE](LICENSE) để biết thêm chi tiết


