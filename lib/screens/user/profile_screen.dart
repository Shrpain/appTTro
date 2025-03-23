import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildProfileMenu(),
            _buildBookingHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tên người dùng
          const Text(
            'Nguyễn Văn B',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            'nguyenvanb@email.com',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          // Điểm uy tín
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                color: Colors.amber.shade700,
                size: 20,
              ),
              const SizedBox(width: 4),
              const Text(
                '4.5',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' - Điểm uy tín',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu() {
    final menuItems = [
      {
        'icon': Icons.person_outline,
        'title': 'Thông tin cá nhân',
        'subtitle': 'Chỉnh sửa thông tin cá nhân của bạn',
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Thông báo',
        'subtitle': 'Quản lý thông báo của bạn',
      },
      {
        'icon': Icons.security_outlined,
        'title': 'Bảo mật',
        'subtitle': 'Thay đổi mật khẩu và bảo mật tài khoản',
      },
      {
        'icon': Icons.help_outline,
        'title': 'Trợ giúp & Hỗ trợ',
        'subtitle': 'Trung tâm trợ giúp, liên hệ hỗ trợ',
      },
      {
        'icon': Icons.info_outline,
        'title': 'Về ứng dụng',
        'subtitle': 'Điều khoản sử dụng, chính sách bảo mật',
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return ListTile(
          leading: Icon(
            item['icon'] as IconData,
            color: Colors.blue.shade700,
          ),
          title: Text(item['title'] as String),
          subtitle: Text(item['subtitle'] as String),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to respective screens
          },
        );
      },
    );
  }

  Widget _buildBookingHistory() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch sử đặt phòng',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Phòng trọ ${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildBookingStatus(index),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Địa chỉ mẫu ${index + 1}, Quận ${1 + (index % 12)}, TP.HCM',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '2.${5 - index}00.000đ/tháng',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${1 + index} tháng trước',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingStatus(int index) {
    final statuses = ['Đã duyệt', 'Đang chờ', 'Đã hủy'];
    final colors = [Colors.green, Colors.orange, Colors.red];
    final status = statuses[index % 3];
    final color = colors[index % 3];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
