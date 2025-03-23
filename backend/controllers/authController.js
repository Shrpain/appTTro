const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/db');

const login = async (req, res) => {
  try {
    const { email, fullname, password } = req.body;

    // Kiểm tra dữ liệu đầu vào
    if (!password) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng nhập mật khẩu'
      });
    }

    if (!email && !fullname) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng nhập email hoặc họ tên'
      });
    }

    // Tìm user trong database
    let query = 'SELECT * FROM users WHERE ';
    let params = [];

    if (email) {
      query += 'email = ?';
      params.push(email);
    } else {
      query += 'fullname = ?';
      params.push(fullname);
    }

    const [users] = await db.execute(query, params);

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: email ? 'Email hoặc mật khẩu không đúng' : 'Họ tên hoặc mật khẩu không đúng'
      });
    }

    const user = users[0];

    // Kiểm tra mật khẩu
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: email ? 'Email hoặc mật khẩu không đúng' : 'Họ tên hoặc mật khẩu không đúng'
      });
    }

    // Tạo JWT token
    const token = jwt.sign(
      { 
        id: user.id, 
        email: user.email,
        role: user.role,
        fullname: user.fullname
      },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    // Trả về thông tin user và token
    res.json({
      success: true,
      message: 'Đăng nhập thành công',
      data: {
        id: user.id,
        fullname: user.fullname,
        email: user.email,
        phone: user.phone,
        role: user.role,
        reputation_score: user.reputation_score,
        avatar: user.avatar,
        token
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server, vui lòng thử lại sau'
    });
  }
};

// Thêm hàm đăng ký
const register = async (req, res) => {
  try {
    const { fullname, email, phone, password, role } = req.body;

    // Kiểm tra dữ liệu đầu vào
    if (!fullname || !email || !phone || !password || !role) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng nhập đầy đủ thông tin'
      });
    }

    // Kiểm tra role hợp lệ
    if (!['admin', 'student', 'owner'].includes(role)) {
      return res.status(400).json({
        success: false,
        message: 'Role không hợp lệ'
      });
    }

    // Kiểm tra email đã tồn tại
    const [existingEmail] = await db.execute(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (existingEmail.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Email đã được sử dụng'
      });
    }

    // Kiểm tra số điện thoại đã tồn tại
    const [existingPhone] = await db.execute(
      'SELECT id FROM users WHERE phone = ?',
      [phone]
    );

    if (existingPhone.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Số điện thoại đã được sử dụng'
      });
    }

    // Mã hóa mật khẩu
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    // Thêm user mới
    const [result] = await db.execute(
      'INSERT INTO users (fullname, email, phone, password_hash, role) VALUES (?, ?, ?, ?, ?)',
      [fullname, email, phone, password_hash, role]
    );

    // Tạo JWT token
    const token = jwt.sign(
      { 
        id: result.insertId, 
        email,
        role,
        fullname
      },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.status(201).json({
      success: true,
      message: 'Đăng ký thành công',
      data: {
        id: result.insertId,
        fullname,
        email,
        phone,
        role,
        token
      }
    });

  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server, vui lòng thử lại sau'
    });
  }
};

module.exports = {
  login,
  register
}; 