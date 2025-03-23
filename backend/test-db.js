const db = require('./config/db');

async function testConnection() {
  try {
    const [result] = await db.execute('SELECT 1');
    console.log('Kết nối database thành công!');
  } catch (error) {
    console.error('Lỗi kết nối database:', error);
  }
}

testConnection(); 