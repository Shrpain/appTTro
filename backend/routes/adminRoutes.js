const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { verifyToken, isAdmin } = require('../middleware/auth');

// Kiểm tra xác thực và quyền admin cho tất cả các route
router.use(verifyToken, isAdmin);

// Dashboard statistics
router.get('/dashboard', adminController.getDashboardStats);

// User management routes
router.get('/users', adminController.getUsers);
router.get('/users/:id', adminController.getUserById);
router.post('/users', adminController.createUser);
router.put('/users/:id', adminController.updateUser);
router.delete('/users/:id', adminController.deleteUser);

// Boarding house management routes
router.get('/boarding-houses', adminController.getBoardingHouses);
router.get('/boarding-houses/:id', adminController.getBoardingHouseById);
router.put('/boarding-houses/:id', adminController.updateBoardingHouse);
router.delete('/boarding-houses/:id', adminController.deleteBoardingHouse);

module.exports = router; 