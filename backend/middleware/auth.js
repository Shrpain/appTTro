const jwt = require('jsonwebtoken');
const db = require('../config/database');

// Middleware để xác thực token
const verifyToken = (req, res, next) => {
  // Lấy token từ header
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'Không tìm thấy token xác thực'
    });
  }

  const token = authHeader.split(' ')[1];

  try {
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_jwt_secret');
    
    // Lưu thông tin user vào request để sử dụng ở các middleware tiếp theo
    req.user = decoded;
    
    next();
  } catch (error) {
    console.error('Lỗi xác thực token:', error);
    return res.status(401).json({
      success: false,
      message: 'Token không hợp lệ hoặc đã hết hạn'
    });
  }
};

// Middleware kiểm tra quyền admin
const isAdmin = async (req, res, next) => {
  try {
    const userId = req.user.id;
    
    // Kiểm tra role của user trong database
    const [users] = await db.execute(
      'SELECT role FROM users WHERE id = ?',
      [userId]
    );
    
    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy người dùng'
      });
    }
    
    const user = users[0];
    
    // Nếu không phải admin thì trả về lỗi
    if (user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Bạn không có quyền truy cập tài nguyên này'
      });
    }
    
    // Nếu là admin thì cho phép tiếp tục
    next();
  } catch (error) {
    console.error('Lỗi kiểm tra quyền admin:', error);
    return res.status(500).json({
      success: false,
      message: 'Lỗi server, vui lòng thử lại sau'
    });
  }
};

module.exports = {
  verifyToken,
  isAdmin
}; 