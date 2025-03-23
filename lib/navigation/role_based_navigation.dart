import 'package:flutter/material.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/landlord/landlord_dashboard.dart';
import '../screens/user/user_dashboard.dart';

class RoleBasedNavigation {
  static Route<dynamic> generateRoute(String role) {
    Widget dashboard;
    switch (role.toLowerCase()) {
      case 'admin':
        dashboard = const AdminDashboard();
        break;
      case 'owner':
        dashboard = const LandlordDashboard();
        break;
      case 'student':
        dashboard = const UserDashboard();
        break;
      default:
        throw Exception('Không tìm thấy role phù hợp');
    }

    return MaterialPageRoute(
      builder: (context) => dashboard,
    );
  }

  static void navigateBasedOnRole(BuildContext context, String role) {
    try {
      Navigator.pushReplacement(context, generateRoute(role));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
