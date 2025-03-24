import 'package:flutter/material.dart';
import '../../utils/auth_utils.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'admin_users.dart'; // Import trang quản lý người dùng
import 'admin_boarding_houses.dart'; // Import trang quản lý phòng trọ

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;

  // Dữ liệu giả lập
  final Map<String, dynamic> _dashboardData = {
    'totalUsers': 256,
    'totalRooms': 128,
    'newReports': 15,
    'newReviews': 42,
    'newBookings': 23,
    'pendingApprovals': 8,
    'userGrowth': [12, 19, 25, 32, 38, 42, 50, 56, 60, 65, 72, 78],
    'bookingTrend': [5, 8, 12, 18, 24, 30, 35, 28, 20, 25, 35, 45],
    'userTypes': {'student': 180, 'owner': 65, 'admin': 11},
    'recentActivities': [
      {
        'user': 'Nguyễn Văn A',
        'action': 'Đăng phòng mới',
        'time': '10 phút trước'
      },
      {
        'user': 'Trần Thị B',
        'action': 'Đánh giá phòng',
        'time': '25 phút trước'
      },
      {
        'user': 'Lê Văn C',
        'action': 'Đăng ký tài khoản',
        'time': '1 giờ trước'
      },
      {'user': 'Phạm Thị D', 'action': 'Báo cáo vấn đề', 'time': '2 giờ trước'},
      {'user': 'Hoàng Văn E', 'action': 'Đặt phòng', 'time': '3 giờ trước'},
    ]
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _loadData();
    _animationController.forward();
  }

  // Tải dữ liệu từ API
  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      // Kiểm tra token
      if (token.isEmpty) {
        print('Chưa đăng nhập. Vui lòng đăng nhập trước khi tải dữ liệu.');
        setState(() => _isLoading = false);
        return;
      }

      print('Đang gọi API với token: ${token.substring(0, 20)}...');

      // Gọi API lấy danh sách người dùng
      final response = await http.get(
        Uri.parse('http://localhost:3001/api/admin/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Không thể kết nối đến máy chủ. Hết thời gian chờ.');
          return http.Response('{"success":false,"message":"Timeout"}', 408);
        },
      );

      print('API response code: ${response.statusCode}');
      print('API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Decoded data: $data');

        if (data['success'] == true && data['users'] != null) {
          final users = data['users'];
          final totalUsers = data['total'] ?? users.length;

          // Đếm số người dùng theo vai trò
          final studentCount =
              users.where((user) => user['role'] == 'student').length;
          final ownerCount =
              users.where((user) => user['role'] == 'owner').length;
          final adminCount =
              users.where((user) => user['role'] == 'admin').length;

          print(
              'Total users: $totalUsers (students: $studentCount, owners: $ownerCount, admins: $adminCount)');

          setState(() {
            // Cập nhật số liệu tổng người dùng
            _dashboardData['totalUsers'] = totalUsers;
            _dashboardData['userTypes'] = {
              'student': studentCount,
              'owner': ownerCount,
              'admin': adminCount,
            };
            _isLoading = false;
          });

          print(
              'Đã tải và cập nhật dữ liệu người dùng: $totalUsers người dùng');
          return;
        } else {
          print('API response không đúng định dạng: ${response.body}');
        }
      } else {
        print('Lỗi khi tải dữ liệu: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Lỗi khi gọi API: $e');
    }

    // Nếu có lỗi, vẫn hiển thị dữ liệu mô phỏng sau 1 giây
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
    print('Đã hiển thị dữ liệu mô phỏng do xảy ra lỗi');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        builder: (context, val, child) {
          return Transform.scale(
            scale: val,
            child: Card(
              elevation: 5,
              shadowColor: color.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.7),
                      color,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimpleLineChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tăng trưởng người dùng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Năm 2024',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 16, bottom: 20),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: LineChartPainter(
                    dataPoints: _dashboardData['userGrowth'],
                    maxValue: 100,
                    lineColor: Colors.blue,
                    fillColor: Colors.blue.withOpacity(0.1),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Người dùng', Colors.blue),
                const SizedBox(width: 24),
                _buildLegendItem('Đặt phòng', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phân bố người dùng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Theo vai trò',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            Expanded(
              child: Center(
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: DonutChartPainter(
                    values: [
                      _dashboardData['userTypes']['student'],
                      _dashboardData['userTypes']['owner'],
                      _dashboardData['userTypes']['admin'],
                    ],
                    colors: [Colors.blue, Colors.green, Colors.red],
                    centerText: '${_dashboardData['totalUsers']}',
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Sinh viên', Colors.blue),
                const SizedBox(width: 20),
                _buildLegendItem('Chủ trọ', Colors.green),
                const SizedBox(width: 20),
                _buildLegendItem('Admin', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hoạt động gần đây',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              _dashboardData['recentActivities'].length,
              (index) => _buildActivityItem(
                _dashboardData['recentActivities'][index]['user'],
                _dashboardData['recentActivities'][index]['action'],
                _dashboardData['recentActivities'][index]['time'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String user, String action, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors
                .primaries[math.Random().nextInt(Colors.primaries.length)],
            child: Text(
              user[0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  action,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _selectedIndex == 0
          ? (_isLoading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tiêu đề trang tổng quan giống như trang quản lý người dùng
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              child: Row(
                                children: [
                                  Container(
                                    height: 24,
                                    width: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Tổng quan',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: () {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      _loadData();
                                    },
                                    tooltip: 'Làm mới dữ liệu',
                                  ),
                                ],
                              ),
                            ),

                            // Cards thống kê
                            GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.3,
                              children: [
                                _buildStatCard(
                                  'Tổng người dùng',
                                  '${_dashboardData['totalUsers']}',
                                  Icons.people,
                                  Colors.blue,
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = 1;
                                    });
                                  },
                                ),
                                _buildStatCard(
                                  'Phòng đã đăng ký',
                                  '${_dashboardData['totalRooms']}',
                                  Icons.home,
                                  Colors.green,
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = 2;
                                    });
                                  },
                                ),
                                _buildStatCard(
                                  'Báo cáo mới',
                                  '${_dashboardData['newReports']}',
                                  Icons.report_problem,
                                  Colors.orange,
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = 3;
                                    });
                                  },
                                ),
                                _buildStatCard(
                                  'Đánh giá mới',
                                  '${_dashboardData['newReviews']}',
                                  Icons.star,
                                  Colors.purple,
                                ),
                                _buildStatCard(
                                  'Đặt phòng mới',
                                  '${_dashboardData['newBookings']}',
                                  Icons.book_online,
                                  Colors.teal,
                                ),
                                _buildStatCard(
                                  'Chờ duyệt',
                                  '${_dashboardData['pendingApprovals']}',
                                  Icons.pending_actions,
                                  Colors.amber,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Biểu đồ đường đơn giản
                            AspectRatio(
                              aspectRatio: 1.5,
                              child: _buildSimpleLineChart(),
                            ),

                            const SizedBox(height: 24),

                            // Phần biểu đồ và hoạt động gần đây
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Biểu đồ tròn
                                Expanded(
                                  flex: 1,
                                  child: AspectRatio(
                                    aspectRatio: 1.0,
                                    child: _buildDonutChart(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Hoạt động gần đây
                                Expanded(
                                  flex: 1,
                                  child: _buildRecentActivities(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ))
          : _getSelectedPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Người dùng',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_work),
            label: 'Phòng trọ',
          ),
          NavigationDestination(
            icon: Icon(Icons.report),
            label: 'Báo cáo',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Thiết lập',
          ),
        ],
      ),
    );
  }

  // Lấy trang từ bottom navigation bar
  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 1:
        return const AdminUsers();
      case 2:
        return const AdminBoardingHouses();
      case 3:
        return const Center(
            child: Text('Trang quản lý báo cáo - Đang phát triển'));
      case 4:
        return const Center(child: Text('Trang cài đặt - Đang phát triển'));
      default:
        return Container(); // Mặc định là dashboard
    }
  }
}

// Lớp vẽ biểu đồ đường đơn giản
class LineChartPainter extends CustomPainter {
  final List<dynamic> dataPoints;
  final double maxValue;
  final Color lineColor;
  final Color fillColor;

  LineChartPainter({
    required this.dataPoints,
    required this.maxValue,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // Bắt đầu ở góc dưới bên trái
    fillPath.moveTo(0, size.height);

    if (dataPoints.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final step = width / (dataPoints.length - 1);

    // Vẽ đường biểu đồ
    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * step;
      final y = height - (dataPoints[i] / maxValue * height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Hoàn thành đường dẫn điền đầy
    fillPath.lineTo(width, size.height);
    fillPath.close();

    // Vẽ đường dẫn điền đầy trước
    canvas.drawPath(fillPath, fillPaint);

    // Sau đó vẽ đường chính
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) => true;
}

// Lớp vẽ biểu đồ tròn đơn giản
class DonutChartPainter extends CustomPainter {
  final List<dynamic> values;
  final List<Color> colors;
  final String centerText;

  DonutChartPainter({
    required this.values,
    required this.colors,
    required this.centerText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = radius * 0.6; // Kích thước lỗ trung tâm

    // Vẽ vòng tròn
    double startAngle = -math.pi / 2; // Bắt đầu từ đỉnh
    final total = values.reduce((a, b) => a + b);

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = 2 * math.pi * values[i] / total;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      // Vẽ đoạn cung
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Vẽ lỗ trung tâm
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, centerPaint);

    // Vẽ văn bản trung tâm
    final textPainter = TextPainter(
      text: TextSpan(
        text: centerText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) => true;
}
