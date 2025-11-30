import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concessoapp/services/shared_pref_service.dart';

class InstitutionController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get students registered under this institution (pending verification)
  static Future<List<Map<String, dynamic>>> getPendingStudents(String institutionId) async {
    try {
      print("🔵 Fetching pending students for institution: $institutionId");

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('institutionId', isEqualTo: institutionId)
          .where('isVerified', isEqualTo: false)
          .get();

      List<Map<String, dynamic>> students = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Filter out rejected students manually (since isRejected field might not exist)
        bool isRejected = data['isRejected'] ?? false;
        if (!isRejected) {
          students.add(data);
        }
      }

      // Sort by createdAt if available, otherwise by document ID
      students.sort((a, b) {
        int createdAtA = a['createdAt'] ?? 0;
        int createdAtB = b['createdAt'] ?? 0;
        return createdAtB.compareTo(createdAtA); // Descending order
      });

      print("✅ Found ${students.length} pending students");
      return students;

    } catch (e) {
      print("❌ Error fetching pending students: $e");
      return [];
    }
  }

  // Get verified students under this institution
  static Future<List<Map<String, dynamic>>> getVerifiedStudents(String institutionId) async {
    try {
      print("🔵 Fetching verified students for institution: $institutionId");

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('institutionId', isEqualTo: institutionId)
          .where('isVerified', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> students = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort by createdAt if available, otherwise by document ID
      students.sort((a, b) {
        int createdAtA = a['createdAt'] ?? 0;
        int createdAtB = b['createdAt'] ?? 0;
        return createdAtB.compareTo(createdAtA); // Descending order
      });

      print("✅ Found ${students.length} verified students");
      return students;

    } catch (e) {
      print("❌ Error fetching verified students: $e");
      return [];
    }
  }

  // Get ALL students (both verified and pending) for easier debugging
  static Future<List<Map<String, dynamic>>> getAllStudents(String institutionId) async {
    try {
      print("🔵 Fetching ALL students for institution: $institutionId");

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('institutionId', isEqualTo: institutionId)
          .get();

      List<Map<String, dynamic>> students = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort by createdAt if available
      students.sort((a, b) {
        int createdAtA = a['createdAt'] ?? 0;
        int createdAtB = b['createdAt'] ?? 0;
        return createdAtB.compareTo(createdAtA); // Descending order
      });

      print("✅ Found ${students.length} total students");

      // Debug: Print details of each student
      for (var student in students) {
        print("📋 Student: ${student['name']} | ID: ${student['id']} | Verified: ${student['isVerified']} | Institution: ${student['institutionId']}");
      }

      return students;

    } catch (e) {
      print("❌ Error fetching all students: $e");
      return [];
    }
  }

  // Verify a student
  static Future<Map<String, dynamic>> verifyStudent(String studentId) async {
    try {
      print("🔵 Verifying student: $studentId");

      String institutionId = SharedPrefService.getUserId();

      await _firestore.collection('users').doc(studentId).update({
        'isVerified': true,
        'verifiedAt': DateTime.now().millisecondsSinceEpoch,
        'verifiedBy': institutionId,
      });

      print("✅ Student verified successfully");
      return {
        'success': true,
        'message': 'Student verified successfully',
      };

    } catch (e) {
      print("❌ Error verifying student: $e");
      return {
        'success': false,
        'message': 'Failed to verify student',
      };
    }
  }

  // Reject a student verification
  static Future<Map<String, dynamic>> rejectStudent(String studentId, String reason) async {
    try {
      print("🔵 Rejecting student: $studentId");

      String institutionId = SharedPrefService.getUserId();

      await _firestore.collection('users').doc(studentId).update({
        'isRejected': true,
        'rejectionReason': reason,
        'rejectedAt': DateTime.now().millisecondsSinceEpoch,
        'rejectedBy': institutionId,
      });

      print("✅ Student rejected successfully");
      return {
        'success': true,
        'message': 'Student verification rejected',
      };

    } catch (e) {
      print("❌ Error rejecting student: $e");
      return {
        'success': false,
        'message': 'Failed to reject student',
      };
    }
  }

  // Get bus card applications from verified students of this institution
  static Future<List<Map<String, dynamic>>> getStudentBusApplications(String institutionId) async {
    try {
      print("🔵 Fetching bus applications from institution students");

      // First get all verified students of this institution
      List<Map<String, dynamic>> verifiedStudents = await getVerifiedStudents(institutionId);
      List<String> studentIds = verifiedStudents.map((student) => student['id'] as String).toList();

      print("📋 Found ${studentIds.length} verified students for applications");

      if (studentIds.isEmpty) {
        print("⚠️ No verified students found");
        return [];
      }

      // Firestore 'whereIn' has a limit of 10 items, so we need to batch the queries
      List<Map<String, dynamic>> applications = [];

      // Split studentIds into chunks of 10
      for (int i = 0; i < studentIds.length; i += 10) {
        int end = (i + 10 < studentIds.length) ? i + 10 : studentIds.length;
        List<String> batch = studentIds.sublist(i, end);

        QuerySnapshot snapshot = await _firestore
            .collection('bus_applications')
            .where('studentId', whereIn: batch)
            .get();

        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;

          // Add student details to the application
          String studentId = data['studentId'];
          Map<String, dynamic>? student = verifiedStudents.where((s) => s['id'] == studentId).isNotEmpty
              ? verifiedStudents.firstWhere((s) => s['id'] == studentId)
              : null;

          if (student != null) {
            data['studentName'] = student['name'];
            data['studentEmail'] = student['email'];
            data['course'] = student['course'];
          }

          applications.add(data);
        }
      }

      // Sort applications by appliedAt
      applications.sort((a, b) {
        int appliedAtA = a['appliedAt'] ?? 0;
        int appliedAtB = b['appliedAt'] ?? 0;
        return appliedAtB.compareTo(appliedAtA); // Descending order
      });

      print("✅ Found ${applications.length} bus applications");
      return applications;

    } catch (e) {
      print("❌ Error fetching bus applications: $e");
      return [];
    }
  }

  // Debug method to check what's in the database
  static Future<void> debugInstitutionData(String institutionId) async {
    try {
      print("🔍 DEBUG: Checking data for institution: $institutionId");

      // Check all users
      QuerySnapshot allUsers = await _firestore.collection('users').get();
      print("📊 Total users in database: ${allUsers.docs.length}");

      // Check students
      QuerySnapshot students = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
      print("📊 Total students in database: ${students.docs.length}");

      // Check students for this institution
      QuerySnapshot institutionStudents = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('institutionId', isEqualTo: institutionId)
          .get();
      print("📊 Students for this institution: ${institutionStudents.docs.length}");

      for (var doc in institutionStudents.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print("🎓 Student: ${data['name']} | Verified: ${data['isVerified']} | Institution: ${data['institutionId']}");
      }

    } catch (e) {
      print("❌ Debug error: $e");
    }
  }

  // Get institution profile
  static Future<Map<String, dynamic>?> getInstitutionProfile(String institutionId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(institutionId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data;
      }
      return null;
    } catch (e) {
      print("❌ Error fetching institution profile: $e");
      return null;
    }
  }
}