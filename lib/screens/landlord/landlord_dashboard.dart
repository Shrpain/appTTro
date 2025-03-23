import 'package:flutter/material.dart';
import '../../utils/auth_utils.dart';

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({Key? key}) : super(key: key);

  @override
  _LandlordDashboardState createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chủ trọ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthUtils.logout(context),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: const Center(child: Text('Landlord Dashboard')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Phòng trọ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Người thuê',
          ),
        ],
      ),
    );
  }
}
