// controllers/grievance_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/shared_pref_service.dart';

class GrievanceController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== STUDENT GRIEVANCE SUBMISSION ====================

  // Submit grievance (Updated with category routing)
  static Future<Map<String, dynamic>> submitGrievance({
    required String studentId,
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) async {
    try {
      print("🔵 Submitting grievance for student: $studentId");

      // Validate input
      if (subject.isEmpty || description.isEmpty) {
        return {
          'success': false,
          'message': 'Please fill all required fields',
        };
      }

      if (description.length < 10) {
        return {
          'success': false,
          'message': 'Please provide more detailed description (minimum 10 characters)',
        };
      }

      // Get student details for routing
      DocumentSnapshot studentDoc = await _firestore
          .collection('users')
          .doc(studentId)
          .get();

      if (!studentDoc.exists) {
        return {
          'success': false,
          'message': 'Student profile not found',
        };
      }

      Map<String, dynamic> studentData = studentDoc.data() as Map<String, dynamic>;
      String institutionId = studentData['institutionId'] ?? '';

      // Determine assigned to based on category
      String assignedTo = '';
      String assignedToType = '';

      if (['Academic', 'Facilities', 'Administrative'].contains(category)) {
        assignedTo = institutionId;
        assignedToType = 'institution';
      } else if (category == 'Transport') {
        assignedTo = 'admin'; // Will be assigned to admin
        assignedToType = 'admin';
      } else {
        assignedTo = institutionId; // Default to institution
        assignedToType = 'institution';
      }

      // Generate unique grievance ID
      String grievanceId = "GRV_${DateTime.now().millisecondsSinceEpoch}";

      Map<String, dynamic> grievanceData = {
        'studentId': studentId,
        'studentName': studentData['name'] ?? 'Unknown',
        'studentEmail': studentData['email'] ?? '',
        'studentPhone': studentData['phone'] ?? '',
        'institutionId': institutionId,
        'subject': subject,
        'description': description,
        'category': category, // Academic, Transport, Facilities, Administrative, Other
        'priority': priority, // Low, Medium, High
        'status': 'open', // open, in_progress, resolved, closed
        'assignedTo': assignedTo,
        'assignedToType': assignedToType, // institution, admin
        'submittedAt': DateTime.now().millisecondsSinceEpoch,
        'grievanceId': grievanceId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'lastUpdatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      DocumentReference docRef = await _firestore
          .collection('grievances')
          .add(grievanceData);

      print("✅ Grievance submitted successfully and assigned to $assignedToType");
      return {
        'success': true,
        'message': 'Grievance submitted successfully',
        'grievanceId': docRef.id,
        'customGrievanceId': grievanceId,
        'assignedToType': assignedToType,
      };

    } catch (e) {
      print("❌ Error submitting grievance: $e");
      return {
        'success': false,
        'message': 'Failed to submit grievance. Please try again.',
      };
    }
  }

  // Get student's grievances
  static Future<List<Map<String, dynamic>>> getStudentGrievances(String studentId) async {
    try {
      print("🔵 Fetching grievances for student: $studentId");

      QuerySnapshot snapshot = await _firestore
          .collection('grievances')
          .where('studentId', isEqualTo: studentId)
          .orderBy('submittedAt', descending: true)
          .get();

      List<Map<String, dynamic>> grievances = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      print("✅ Found ${grievances.length} grievances");
      return grievances;
    } catch (e) {
      print("❌ Error fetching grievances: $e");
      return [];
    }
  }

  // ==================== INSTITUTION GRIEVANCE MANAGEMENT ====================

  // Get grievances assigned to institution
  static Future<List<Map<String, dynamic>>> getInstitutionGrievances(String institutionId) async {
    try {
      print("🔵 Fetching grievances for institution: $institutionId");

      QuerySnapshot snapshot = await _firestore
          .collection('grievances')
          .where('assignedTo', isEqualTo: institutionId)
          .where('assignedToType', isEqualTo: 'institution')
          .orderBy('submittedAt', descending: true)
          .get();

      List<Map<String, dynamic>> grievances = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      print("✅ Found ${grievances.length} grievances for institution");
      return grievances;
    } catch (e) {
      print("❌ Error fetching institution grievances: $e");
      return [];
    }
  }

  // Update grievance status by institution
  static Future<Map<String, dynamic>> updateGrievanceByInstitution({
    required String grievanceId,
    required String status,
    required String response,
  }) async {
    try {
      print("🔵 Institution updating grievance: $grievanceId");

      String institutionId = SharedPrefService.getUserId();

      Map<String, dynamic> updateData = {
        'status': status,
        'institutionResponse': response,
        'responseBy': institutionId,
        'responseAt': DateTime.now().millisecondsSinceEpoch,
        'lastUpdatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (status == 'resolved') {
        updateData['resolvedAt'] = DateTime.now().millisecondsSinceEpoch;
        updateData['resolvedBy'] = institutionId;
      }

      await _firestore
          .collection('grievances')
          .doc(grievanceId)
          .update(updateData);

      print("✅ Grievance updated successfully by institution");
      return {
        'success': true,
        'message': 'Grievance updated successfully',
      };
    } catch (e) {
      print("❌ Error updating grievance: $e");
      return {
        'success': false,
        'message': 'Failed to update grievance',
      };
    }
  }

  // ==================== ADMIN GRIEVANCE MANAGEMENT ====================

  // Get grievances assigned to admin (Transport category)
  static Future<List<Map<String, dynamic>>> getAdminGrievances() async {
    try {
      print("🔵 Fetching grievances for admin");

      QuerySnapshot snapshot = await _firestore
          .collection('grievances')
          .where('assignedToType', isEqualTo: 'admin')
          .orderBy('submittedAt', descending: true)
          .get();

      List<Map<String, dynamic>> grievances = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      print("✅ Found ${grievances.length} grievances for admin");
      return grievances;
    } catch (e) {
      print("❌ Error fetching admin grievances: $e");
      return [];
    }
  }

  // Update grievance status by admin
  static Future<Map<String, dynamic>> updateGrievanceByAdmin({
    required String grievanceId,
    required String status,
    required String response,
  }) async {
    try {
      print("🔵 Admin updating grievance: $grievanceId");

      String adminId = SharedPrefService.getUserId();

      Map<String, dynamic> updateData = {
        'status': status,
        'adminResponse': response,
        'responseBy': adminId,
        'responseAt': DateTime.now().millisecondsSinceEpoch,
        'lastUpdatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (status == 'resolved') {
        updateData['resolvedAt'] = DateTime.now().millisecondsSinceEpoch;
        updateData['resolvedBy'] = adminId;
      }

      await _firestore
          .collection('grievances')
          .doc(grievanceId)
          .update(updateData);

      print("✅ Grievance updated successfully by admin");
      return {
        'success': true,
        'message': 'Grievance updated successfully',
      };
    } catch (e) {
      print("❌ Error updating grievance: $e");
      return {
        'success': false,
        'message': 'Failed to update grievance',
      };
    }
  }

  // Get all grievances for admin overview
  static Future<List<Map<String, dynamic>>> getAllGrievancesForAdmin() async {
    try {
      print("🔵 Fetching all grievances for admin overview");

      QuerySnapshot snapshot = await _firestore
          .collection('grievances')
          .orderBy('submittedAt', descending: true)
          .get();

      List<Map<String, dynamic>> grievances = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      print("✅ Found ${grievances.length} total grievances");
      return grievances;
    } catch (e) {
      print("❌ Error fetching all grievances: $e");
      return [];
    }
  }

  // ==================== STATISTICS & ANALYTICS ====================

  // Get grievance statistics for institution
  static Future<Map<String, int>> getInstitutionGrievanceStats(String institutionId) async {
    try {
      print("🔵 Fetching grievance statistics for institution: $institutionId");

      QuerySnapshot snapshot = await _firestore
          .collection('grievances')
          .where('assignedTo', isEqualTo: institutionId)
          .where('assignedToType', isEqualTo: 'institution')
          .get();

      Map<String, int> stats = {
        'total': 0,
        'open': 0,
        'in_progress': 0,
        'resolved': 0,
        'closed': 0,
      };

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? 'open';

        stats['total'] = (stats['total'] ?? 0) + 1;
        stats[status] = (stats[status] ?? 0) + 1;
      }

      print("✅ Institution grievance statistics: $stats");
      return stats;
    } catch (e) {
      print("❌ Error fetching institution grievance statistics: $e");
      return {
        'total': 0,
        'open': 0,
        'in_progress': 0,
        'resolved': 0,
        'closed': 0,
      };
    }
  }

  // Get grievance statistics for admin
  static Future<Map<String, int>> getAdminGrievanceStats() async {
    try {
      print("🔵 Fetching grievance statistics for admin");

      QuerySnapshot snapshot = await _firestore
          .collection('grievances')
          .get();

      Map<String, int> stats = {
        'total': 0,
        'transport': 0,
        'academic': 0,
        'facilities': 0,
        'administrative': 0,
        'open': 0,
        'resolved': 0,
      };

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String category = (data['category'] ?? 'Other').toLowerCase();
        String status = data['status'] ?? 'open';

        stats['total'] = (stats['total'] ?? 0) + 1;
        stats[status] = (stats[status] ?? 0) + 1;

        if (category == 'transport') {
          stats['transport'] = (stats['transport'] ?? 0) + 1;
        } else if (category == 'academic') {
          stats['academic'] = (stats['academic'] ?? 0) + 1;
        } else if (category == 'facilities') {
          stats['facilities'] = (stats['facilities'] ?? 0) + 1;
        } else if (category == 'administrative') {
          stats['administrative'] = (stats['administrative'] ?? 0) + 1;
        }
      }

      print("✅ Admin grievance statistics: $stats");
      return stats;
    } catch (e) {
      print("❌ Error fetching admin grievance statistics: $e");
      return {
        'total': 0,
        'transport': 0,
        'academic': 0,
        'facilities': 0,
        'administrative': 0,
        'open': 0,
        'resolved': 0,
      };
    }
  }

  // ==================== HELPER METHODS ====================

  // Get grievance details by ID
  static Future<Map<String, dynamic>?> getGrievanceById(String grievanceId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('grievances')
          .doc(grievanceId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print("❌ Error fetching grievance details: $e");
      return null;
    }
  }

  // Close grievance (mark as closed)
  static Future<Map<String, dynamic>> closeGrievance(String grievanceId, String reason) async {
    try {
      String userId = SharedPrefService.getUserId();

      await _firestore
          .collection('grievances')
          .doc(grievanceId)
          .update({
        'status': 'closed',
        'closedAt': DateTime.now().millisecondsSinceEpoch,
        'closedBy': userId,
        'closeReason': reason,
        'lastUpdatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      return {
        'success': true,
        'message': 'Grievance closed successfully',
      };
    } catch (e) {
      print("❌ Error closing grievance: $e");
      return {
        'success': false,
        'message': 'Failed to close grievance',
      };
    }
  }

  // Reassign grievance (admin can reassign between categories)
  static Future<Map<String, dynamic>> reassignGrievance({
    required String grievanceId,
    required String newAssignedTo,
    required String newAssignedToType,
    required String reason,
  }) async {
    try {
      String adminId = SharedPrefService.getUserId();

      await _firestore
          .collection('grievances')
          .doc(grievanceId)
          .update({
        'assignedTo': newAssignedTo,
        'assignedToType': newAssignedToType,
        'reassignedAt': DateTime.now().millisecondsSinceEpoch,
        'reassignedBy': adminId,
        'reassignReason': reason,
        'lastUpdatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      return {
        'success': true,
        'message': 'Grievance reassigned successfully',
      };
    } catch (e) {
      print("❌ Error reassigning grievance: $e");
      return {
        'success': false,
        'message': 'Failed to reassign grievance',
      };
    }
  }
}