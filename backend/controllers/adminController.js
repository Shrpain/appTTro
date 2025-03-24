const db = require('../config/database');

// Lấy thống kê tổng quan cho dashboard
const getDashboardStats = async (req, res) => {
  try {
    // Sẽ cài đặt chi tiết ở phần sau
    res.json({
      success: true,
      stats: {
        totalUsers: 0,
        totalRooms: 0,
        newReports: 0,
        newReviews: 0
      }
    });
  } catch (error) {
    console.error('Lỗi khi lấy thống kê:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server, vui lòng thử lại sau'
    });
  }
};

// Lấy danh sách tất cả người dùng
const getUsers = async (req, res) => {
  try {
    console.log('Đang lấy danh sách người dùng...');
    
    // Thử lấy danh sách users
    console.log('Đang query users...');
    const [users] = await db.execute(
      'SELECT id, fullname, email, phone, role, reputation_score, avatar, status, created_at FROM users'
    );

    console.log(`Đã lấy ${users.length} người dùng`);
    
    // Trả về kết quả cho client
    return res.json({
      success: true,
      users: users,
      total: users.length
    });
  } catch (error) {
    console.error('Lỗi chi tiết khi lấy danh sách người dùng:', error);
    return res.status(500).json({
      success: false,
      message: 'Lỗi server, vui lòng thử lại sau',
      error: error.message
    });
  }
};

// Lấy thông tin một người dùng theo ID
const getUserById = async (req, res) => {
  try {
    console.log('Đang lấy thông tin người dùng:', req.params.id);
    const userId = req.params.id;
    
    // Kiểm tra định dạng userId
    if (!userId || isNaN(parseInt(userId))) {
      return res.status(400).json({
        success: false,
        message: 'ID người dùng không hợp lệ'
      });
    }
    
    // Truy vấn thông tin người dùng
    const [users] = await db.execute(
      'SELECT id, fullname, email, phone, role, reputation_score, avatar, created_at FROM users WHERE id = ?',
      [userId]
    );

    // Kiểm tra người dùng tồn tại
    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy người dùng'
      });
    }

    // Trả về thông tin người dùng
    console.log('Đã tìm thấy người dùng:', users[0].fullname);
    return res.json({
      success: true,
      user: users[0]
    });
  } catch (error) {
    console.error('Lỗi khi lấy thông tin người dùng:', error);
    return res.status(500).json({
      success: false,
      message: 'Lỗi server, vui lòng thử lại sau',
      error: error.message
    });
  }
};

// Tạo người dùng mới (chỉ admin mới có quyền)
const createUser = async (req, res) => {
  try {
    console.log('Đang tạo người dùng mới với dữ liệu:', req.body);
    const { fullname, email, phone, password, role } = req.body;
    const bcrypt = require('bcryptjs');

    // Kiểm tra dữ liệu đầu vào
    if (!fullname || !email || !phone || !password || !role) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng nhập đầy đủ thông tin'
      });
    }

    // Kiểm tra email hợp lệ
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        message: 'Email không hợp lệ'
      });
    }

    // Kiểm tra email đã tồn tại chưa
    const [existingUsers] = await db.execute(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (existingUsers.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Email đã được sử dụng'
      });
    }

    // Kiểm tra số điện thoại đã tồn tại chưa
    const [existingPhones] = await db.execute(
      'SELECT id FROM users WHERE phone = ?',
      [phone]
    );

    if (existingPhones.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Số điện thoại đã được sử dụng'
      });
    }

    // Kiểm tra role hợp lệ
    const validRoles = ['admin', 'student', 'owner'];
    if (!validRoles.includes(role)) {
      return res.status(400).json({
        success: false,
        message: 'Vai trò không hợp lệ'
      });
    }

    // Mã hóa mật khẩu
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Tạo người dùng mới
    const [result] = await db.execute(
      'INSERT INTO users (fullname, email, phone, password_hash, role, created_at) VALUES (?, ?, ?, ?, ?, NOW())',
      [fullname, email, phone, hashedPassword, role]
    );

    console.log('Đã tạo người dùng mới:', fullname, 'với ID:', result.insertId);
    
    return res.status(201).json({
      success: true,
      message: 'Tạo người dùng thành công',
      userId: result.insertId
    });
  } catch (error) {
    console.error('Lỗi khi tạo người dùng:', error);
    return res.status(500).json({
      success: false,
      message: 'Lỗi server, vui lòng thử lại sau',
      error: error.message
    });
  }
};

// Cập nhật thông tin người dùng
const updateUser = async (req, res) => {
  console.log('Update user request body:', req.body);
  const userId = req.params.id;

  if (!userId || isNaN(userId)) {
    return res.status(400).json({ success: false, message: 'ID người dùng không hợp lệ' });
  }

  try {
    const { fullname, email, phone, password, role, status, reputation_score } = req.body;
    const bcrypt = require('bcryptjs');

    // Build update fields dynamically
    const updateFields = [];
    const updateValues = [];

    if (fullname) {
      updateFields.push('fullname = ?');
      updateValues.push(fullname);
    }

    if (email) {
      // Kiểm tra email hợp lệ
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        return res.status(400).json({
          success: false,
          message: 'Email không hợp lệ'
        });
      }

      // Kiểm tra email đã tồn tại chưa (trừ chính user hiện tại)
      const [existingUsers] = await db.execute(
        'SELECT id FROM users WHERE email = ? AND id != ?',
        [email, userId]
      );

      if (existingUsers.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'Email đã được sử dụng'
        });
      }

      updateFields.push('email = ?');
      updateValues.push(email);
    }

    if (phone) {
      // Kiểm tra số điện thoại đã tồn tại chưa (trừ chính user hiện tại)
      const [existingPhones] = await db.execute(
        'SELECT id FROM users WHERE phone = ? AND id != ?',
        [phone, userId]
      );

      if (existingPhones.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'Số điện thoại đã được sử dụng'
        });
      }

      updateFields.push('phone = ?');
      updateValues.push(phone);
    }

    if (password) {
      // Mã hóa mật khẩu mới
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);
      updateFields.push('password_hash = ?');
      updateValues.push(hashedPassword);
    }

    if (role) {
      // Kiểm tra role hợp lệ
      const validRoles = ['admin', 'student', 'owner'];
      if (!validRoles.includes(role)) {
        return res.status(400).json({
          success: false,
          message: 'Vai trò không hợp lệ'
        });
      }
      updateFields.push('role = ?');
      updateValues.push(role);
    }

    if (status) {
      // Kiểm tra status hợp lệ
      const validStatuses = ['active', 'blocked'];
      if (!validStatuses.includes(status)) {
        return res.status(400).json({
          success: false,
          message: 'Trạng thái không hợp lệ'
        });
      }
      updateFields.push('status = ?');
      updateValues.push(status);
    }

    if (reputation_score !== undefined) {
      // Kiểm tra điểm uy tín hợp lệ
      const score = parseFloat(reputation_score);
      if (isNaN(score) || score < 0 || score > 5) {
        return res.status(400).json({
          success: false,
          message: 'Điểm uy tín phải từ 0 đến 5'
        });
      }
      updateFields.push('reputation_score = ?');
      updateValues.push(score);
    }

    // Nếu không có trường nào được cập nhật
    if (updateFields.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Không có thông tin nào được cập nhật'
      });
    }

    // Thêm userId vào mảng updateValues
    updateValues.push(userId);

    // Thực hiện cập nhật
    const [result] = await db.execute(
      `UPDATE users SET ${updateFields.join(', ')} WHERE id = ?`,
      updateValues
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy người dùng'
      });
    }

    // Lấy thông tin người dùng đã cập nhật
    const [updatedUser] = await db.execute(
      'SELECT id, fullname, email, phone, role, reputation_score, avatar, status, created_at FROM users WHERE id = ?',
      [userId]
    );

    return res.json({
      success: true,
      message: 'Cập nhật thông tin người dùng thành công',
      user: updatedUser[0]
    });

  } catch (error) {
    console.error('Lỗi khi cập nhật người dùng:', error);
    return res.status(500).json({
      success: false,
      message: 'Lỗi server, vui lòng thử lại sau',
      error: error.message
    });
  }
};

// Xóa người dùng
const deleteUser = async (req, res) => {
  try {
    console.log('Đang xóa người dùng:', req.params.id);
    const userId = req.params.id;
    
    // Kiểm tra userId
    if (!userId || isNaN(parseInt(userId))) {
      return res.status(400).json({
        success: false,
        message: 'ID người dùng không hợp lệ'
      });
    }
    
    // Kiểm tra người dùng tồn tại
    const [existingUsers] = await db.execute(
      'SELECT id, fullname, role FROM users WHERE id = ?',
      [userId]
    );
    
    if (existingUsers.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy người dùng'
      });
    }
    
    const existingUser = existingUsers[0];
    
    // Lấy thông tin người dùng hiện tại (admin đang thực hiện xóa)
    const currentAdmin = req.user;
    
    // Ngăn admin xóa chính mình
    if (parseInt(userId) === currentAdmin.id) {
      return res.status(400).json({
        success: false,
        message: 'Bạn không thể xóa tài khoản của chính mình'
      });
    }
    
    // Xóa người dùng
    const [result] = await db.execute(
      'DELETE FROM users WHERE id = ?',
      [userId]
    );
    
    console.log('Đã xóa người dùng:', existingUser.fullname, 'với ID:', userId);
    
    return res.json({
      success: true,
      message: `Đã xóa người dùng ${existingUser.fullname} thành công`,
      affectedRows: result.affectedRows
    });
  } catch (error) {
    console.error('Lỗi khi xóa người dùng:', error);
    return res.status(500).json({
      success: false,
      message: 'Lỗi server, vui lòng thử lại sau',
      error: error.message
    });
  }
};

// Lấy danh sách nhà trọ
const getBoardingHouses = async (req, res) => {
  try {
    // Lấy danh sách nhà trọ

    res.json({
      success: true,
      boarding_houses: []
    });
  } catch (error) {
    console.error('Lỗi khi lấy danh sách nhà trọ:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server, vui lòng thử lại sau'
    });
  }
};

// Lấy thông tin chi tiết nhà trọ
const getBoardingHouseById = async (req, res) => {
  try {
    const houseId = req.params.id;
    // Lấy thông tin nhà trọ

    res.json({
      success: true,
      boarding_house: {}
    });
  } catch (error) {
    console.error('Lỗi khi lấy thông tin nhà trọ:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server, vui lòng thử lại sau'
    });
  }
};

// Cập nhật thông tin nhà trọ
const updateBoardingHouse = async (req, res) => {
  try {
    const houseId = req.params.id;
    // Cập nhật thông tin nhà trọ

    res.json({
      success: true,
      message: 'Cập nhật thông tin nhà trọ thành công'
    });
  } catch (error) {
    console.error('Lỗi khi cập nhật nhà trọ:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server, vui lòng thử lại sau'
    });
  }
};

// Xóa nhà trọ
const deleteBoardingHouse = async (req, res) => {
  try {
    const houseId = req.params.id;
    // Xóa nhà trọ

    res.json({
      success: true,
      message: 'Xóa nhà trọ thành công'
    });
  } catch (error) {
    console.error('Lỗi khi xóa nhà trọ:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server, vui lòng thử lại sau'
    });
  }
};

module.exports = {
  getDashboardStats,
  getUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser,
  getBoardingHouses,
  getBoardingHouseById,
  updateBoardingHouse,
  deleteBoardingHouse
}; 