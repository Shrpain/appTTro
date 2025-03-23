import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthUtils {
  static void logout(BuildContext context) {
    // Xóa thông tin user và token trong AuthProvider
    context.read<AuthProvider>().clearUser();

    // Điều hướng về màn hình đăng nhập và xóa tất cả các màn hình trong stack
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false,
    );
  }
}
