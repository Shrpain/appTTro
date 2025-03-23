CREATE DATABASE IF NOT EXISTS tim_tro_sinh_vien;
USE tim_tro_sinh_vien;

-- Bảng người dùng (Admin, Sinh viên, Chủ trọ)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fullname VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'student', 'owner') NOT NULL,
    reputation_score FLOAT DEFAULT 0 CHECK (reputation_score >= 0 AND reputation_score <= 5),
    avatar VARCHAR(255) DEFAULT 'default_avatar.jpg',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng nhà trọ
CREATE TABLE boarding_houses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    description TEXT,
    total_rooms INT NOT NULL DEFAULT 0,
    price_range VARCHAR(50) NOT NULL,  -- Ví dụ: "1.5 - 2.5 triệu"
    rating FLOAT DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Bảng phòng trọ
CREATE TABLE rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    boarding_house_id INT NOT NULL,
    room_number VARCHAR(50) NOT NULL,
    price DOUBLE NOT NULL,
    area DOUBLE NOT NULL,  -- Diện tích (m²)
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (boarding_house_id) REFERENCES boarding_houses(id) ON DELETE CASCADE
);

-- Bảng đặt phòng
CREATE TABLE bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    room_id INT NOT NULL,
    status ENUM('pending', 'approved', 'rejected', 'canceled') DEFAULT 'pending',
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE
);

-- Bảng tài liệu học tập
CREATE TABLE documents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    subject VARCHAR(100) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Bảng đánh giá nhà trọ
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    boarding_house_id INT NOT NULL,
    rating FLOAT CHECK (rating >= 0 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (boarding_house_id) REFERENCES boarding_houses(id) ON DELETE CASCADE
);

-- Bảng tin nhắn (chat giữa sinh viên & chủ trọ)
CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    message TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
);
