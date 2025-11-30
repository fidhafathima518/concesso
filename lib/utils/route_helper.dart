import 'package:concessoapp/views/auth/login_screen.dart';
import 'package:flutter/material.dart';

import '../views/admin/admin_dashboard.dart';
import '../views/institution/institution_dashboard.dart';
import '../views/student/student_dashboard.dart';
import '../views/support/support_dashboard.dart';
import 'constants.dart';

class RouteHelper {

  // Navigate to appropriate dashboard based on user role
  static void navigateToDashboard(BuildContext context, String userRole) {
    Widget dashboard;

    switch (userRole) {
      case AppConstants.STUDENT:
        dashboard = StudentDashboard();
        break;
      case AppConstants.ADMIN:
        dashboard = AdminDashboard();
        break;
      case AppConstants.INSTITUTION:
        dashboard = InstitutionDashboard();
        break;
      case AppConstants.SUPPORT:
        dashboard = SupportDashboard();
        break;
      default:
        dashboard = LoginScreen();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => dashboard),
          (route) => false, // Remove all previous routes
    );
  }

  // Navigate to login screen
  static void navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }
}