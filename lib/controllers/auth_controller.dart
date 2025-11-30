import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/shared_pref_service.dart';
import '../utils/constants.dart';

class AuthController {

  // Login method
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print("🔵 Starting login for: $email");

      // Validate input
      if (email.isEmpty || password.isEmpty) {
        print("❌ Empty email or password");
        return {
          'success': false,
          'message': 'Please enter both email and password',
        };
      }

      print("🔵 Attempting Firebase Auth...");
      // Sign in with Firebase Auth
      UserCredential userCredential = await FirebaseService.signInWithEmailPassword(email, password);
      print("✅ Firebase Auth successful. UID: ${userCredential.user!.uid}");

      print("🔵 Fetching user data from Firestore...");
      // Get user data from Firestore
      DocumentSnapshot userDoc = await FirebaseService.getUserData(userCredential.user!.uid);
      print("🔵 Firestore document exists: ${userDoc.exists}");

      if (!userDoc.exists) {
        print("❌ User document not found in Firestore");
        return {
          'success': false,
          'message': 'User data not found. Please contact support.',
        };
      }

      // Create user model from Firestore data
      print("🔵 Creating user model...");
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      print("🔵 User data from Firestore: $userData");

      userData['id'] = userCredential.user!.uid; // Ensure ID is set
      UserModel user = UserModel.fromMap(userData);
      print("✅ User model created. Role: ${user.role}");

      print("🔵 Saving to SharedPreferences...");
      // Save user data to SharedPreferences
      await SharedPrefService.saveUserData(user);
      print("✅ Data saved to SharedPreferences");

      return {
        'success': true,
        'user': user,
        'message': 'Login successful',
      };

    } on FirebaseAuthException catch (e) {
      print("❌ Firebase Auth Exception: ${e.code} - ${e.message}");
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      print("❌ Unexpected error: $e");
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }
  // Auto login check
  static Future<Map<String, dynamic>> checkAutoLogin() async {
    try {
      // Check if user data exists in SharedPreferences
      if (!SharedPrefService.isLoggedIn()) {
        return {
          'success': false,
          'message': 'No saved login found',
        };
      }

      // Get stored user data
      UserModel? user = SharedPrefService.getStoredUser();
      if (user == null) {
        return {
          'success': false,
          'message': 'Invalid stored user data',
        };
      }

      // Check if Firebase user is still authenticated
      User? firebaseUser = FirebaseService.getCurrentUser();
      if (firebaseUser == null) {
        // Clear stored data if Firebase session expired
        await SharedPrefService.clearUserData();
        return {
          'success': false,
          'message': 'Session expired',
        };
      }

      return {
        'success': true,
        'user': user,
        'message': 'Auto login successful',
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Auto login failed',
      };
    }
  }
  static Future<Map<String, dynamic>> registerStudent({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String institutionId,
    required String studentId,
    required String course,
    required String address,
  }) async {
    try {
      // Validate input
      if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
        return {
          'success': false,
          'message': 'Please fill all required fields',
        };
      }

      // Create user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
      Map<String, dynamic> userData = {
        'id': userCredential.user!.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': AppConstants.STUDENT,
        'institutionId': institutionId,
        'studentId': studentId,
        'course': course,
        'address': address,
        'isVerified': false,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection(AppConstants.USERS_COLLECTION)
          .doc(userCredential.user!.uid)
          .set(userData);

      UserModel user = UserModel.fromMap(userData);

      // Save user data to SharedPreferences
      await SharedPrefService.saveUserData(user);

      return {
        'success': true,
        'user': user,
        'message': 'Registration successful',
      };

    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed. Please try again.',
      };
    }
  }

  // Institution Registration
  static Future<Map<String, dynamic>> registerInstitution({
    required String institutionName,
    required String email,
    required String password,
    required String phone,
    required String institutionCode,
    required String principalName,
    required String address,
    required String institutionType,
  }) async {
    try {
      // Validate input
      if (institutionName.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
        return {
          'success': false,
          'message': 'Please fill all required fields',
        };
      }

      // Create user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
      Map<String, dynamic> userData = {
        'id': userCredential.user!.uid,
        'name': institutionName,
        'email': email,
        'phone': phone,
        'role': AppConstants.INSTITUTION,
        'institutionCode': institutionCode,
        'principalName': principalName,
        'address': address,
        'institutionType': institutionType,
        'isVerified': false,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection(AppConstants.USERS_COLLECTION)
          .doc(userCredential.user!.uid)
          .set(userData);

      UserModel user = UserModel.fromMap(userData);

      // Save user data to SharedPreferences
      await SharedPrefService.saveUserData(user);

      return {
        'success': true,
        'user': user,
        'message': 'Institution registration successful',
      };

    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Institution registration failed. Please try again.',
      };
    }
  }

  // Get list of institutions for student registration
  static Future<List<Map<String, dynamic>>> getInstitutions() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(AppConstants.USERS_COLLECTION)
          .where('role', isEqualTo: AppConstants.INSTITUTION)
          .where('isVerified', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'institutionCode': data['institutionCode'] ?? '',
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
  // Logout method
  static Future<Map<String, dynamic>> logout() async {
    try {
      // Sign out from Firebase
      await FirebaseService.signOut();

      // Clear local data
      await SharedPrefService.clearUserData();

      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Logout failed. Please try again.',
      };
    }
  }

  // Get Firebase Auth error messages
  static String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Login failed. Please try again.';
    }
  }
}