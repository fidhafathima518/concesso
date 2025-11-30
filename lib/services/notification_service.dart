import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Get FCM token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');
  }

  static Future<void> sendWelcomeNotification(String userRole) async {
    // This would typically be handled by your backend
    // For now, just log the action
    print('Welcome notification sent for $userRole');
  }
}

// Updated controllers/auth_controller.dart (Add notification after registration)
// Add this import at the top of auth_controller.dart
// import '../services/notification_service.dart';

// Update the registration success sections in both registerStudent and registerInstitution:
// After saving user data to SharedPreferences, add:
// await NotificationService.sendWelcomeNotification(user.role);