# Ứng dụng Tìm trọ sinh viên

Ứng dụng mobile giúp sinh viên tìm kiếm và quản lý phòng trọ, kết nối với chủ trọ.

## Tính năng chính

### Xác thực người dùng
- Đăng nhập bằng email hoặc họ tên
- Đăng ký tài khoản với các vai trò: Sinh viên, Chủ trọ
- Đăng xuất và quản lý phiên đăng nhập

### Giao diện theo vai trò

#### Sinh viên
- Tìm kiếm phòng trọ
- Xem thông tin chi tiết phòng
- Đặt phòng và quản lý đặt phòng
- Đánh giá và bình luận
- Chia sẻ tài liệu học tập

#### Chủ trọ
- Quản lý nhà trọ và phòng trọ
- Xem và xử lý yêu cầu đặt phòng
- Quản lý thông tin người thuê
- Thống kê và báo cáo

#### Quản trị viên
- Quản lý người dùng
- Quản lý nhà trọ
- Xem báo cáo và thống kê
- Xử lý khiếu nại

## Công nghệ sử dụng

### Frontend
- Flutter SDK
- Provider cho state management
- HTTP package cho API calls
- Animation và hiệu ứng chuyển động

### Backend
- Node.js với Express
- MySQL database
- JWT cho xác thực
- API RESTful

## Cài đặt và Chạy

### Yêu cầu
- Flutter SDK
- Node.js và npm
- MySQL

### Backend
1. Di chuyển vào thư mục backend:
```bash
cd backend
```

2. Cài đặt dependencies:
```bash
npm install
```

3. Tạo file .env và cấu hình:
```env
DB_HOST=localhost
DB_USER=root
DB_PASS=your_password
DB_NAME=tim_tro_sinh_vien
JWT_SECRET=your_secret_key
```

4. Khởi tạo database:
```bash
mysql -u root -p < database.sql
```

5. Chạy server:
```bash
npm start
```

### Frontend
1. Di chuyển vào thư mục gốc của dự án

2. Cài đặt dependencies:
```bash
flutter pub get
```

3. Chạy ứng dụng:
```bash
flutter run
```

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


