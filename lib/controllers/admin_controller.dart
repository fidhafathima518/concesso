// controllers/admin_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/shared_pref_service.dart';

class AdminController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== INSTITUTION MANAGEMENT ====================

  // Get pending institutions for verification
  static Future<List<Map<String, dynamic>>> getPendingInstitutions() async {
    try {
      print("🔵 Fetching pending institutions...");

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'institution')
          .where('isVerified', isEqualTo: false)
          .get();

      List<Map<String, dynamic>> institutions = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Filter out rejected institutions manually
        bool isRejected = data['isRejected'] ?? false;
        if (!isRejected) {
          institutions.add(data);
        }
      }

      // Sort by createdAt
      institutions.sort((a, b) {
        int createdAtA = a['createdAt'] ?? 0;
        int createdAtB = b['createdAt'] ?? 0;
        return createdAtB.compareTo(createdAtA);
      });

      print("✅ Found ${institutions.length} pending institutions");
      return institutions;

    } catch (e) {
      print("❌ Error fetching pending institutions: $e");
      return [];
    }
  }

  // Get verified institutions
  static Future<List<Map<String, dynamic>>> getVerifiedInstitutions() async {
    try {
      print("🔵 Fetching verified institutions...");

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'institution')
          .where('isVerified', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> institutions = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort by createdAt
      institutions.sort((a, b) {
        int createdAtA = a['createdAt'] ?? 0;
        int createdAtB = b['createdAt'] ?? 0;
        return createdAtB.compareTo(createdAtA);
      });

      print("✅ Found ${institutions.length} verified institutions");
      return institutions;

    } catch (e) {
      print("❌ Error fetching verified institutions: $e");
      return [];
    }
  }

  // Verify institution
  static Future<Map<String, dynamic>> verifyInstitution(String institutionId) async {
    try {
      print("🔵 Verifying institution: $institutionId");

      await _firestore.collection('users').doc(institutionId).update({
        'isVerified': true,
        'verifiedAt': DateTime.now().millisecondsSinceEpoch,
        'verifiedBy': SharedPrefService.getUserId(),
      });

      print("✅ Institution verified successfully");
      return {
        'success': true,
        'message': 'Institution verified successfully',
      };

    } catch (e) {
      print("❌ Error verifying institution: $e");
      return {
        'success': false,
        'message': 'Failed to verify institution',
      };
    }
  }

  // Reject institution
  static Future<Map<String, dynamic>> rejectInstitution(String institutionId, String reason) async {
    try {
      print("🔵 Rejecting institution: $institutionId");

      await _firestore.collection('users').doc(institutionId).update({
        'isRejected': true,
        'rejectionReason': reason,
        'rejectedAt': DateTime.now().millisecondsSinceEpoch,
        'rejectedBy': SharedPrefService.getUserId(),
      });

      print("✅ Institution rejected successfully");
      return {
        'success': true,
        'message': 'Institution rejected successfully',
      };

    } catch (e) {
      print("❌ Error rejecting institution: $e");
      return {
        'success': false,
        'message': 'Failed to reject institution',
      };
    }
  }

  // Get pending students for verification (by institution)
  static Future<List<Map<String, dynamic>>> getPendingStudents() async {
    try {
      print("🔵 Fetching pending students...");

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('isVerified', isEqualTo: false)
          .get();

      List<Map<String, dynamic>> students = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Filter out rejected students manually
        bool isRejected = data['isRejected'] ?? false;
        if (!isRejected) {
          students.add(data);
        }
      }

      // Sort by createdAt
      students.sort((a, b) {
        int createdAtA = a['createdAt'] ?? 0;
        int createdAtB = b['createdAt'] ?? 0;
        return createdAtB.compareTo(createdAtA);
      });

      print("✅ Found ${students.length} pending students");
      return students;

    } catch (e) {
      print("❌ Error fetching pending students: $e");
      return [];
    }
  }

  // ==================== APPLICATION MANAGEMENT ====================

  // Get all bus card applications
  static Future<List<Map<String, dynamic>>> getAllBusApplications() async {
    try {
      print("🔵 Admin fetching all bus applications");

      QuerySnapshot snapshot = await _firestore
          .collection('bus_applications')
          .get();

      List<Map<String, dynamic>> applications = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Get student details
        String studentId = data['studentId'];
        try {
          DocumentSnapshot studentDoc = await _firestore
              .collection('users')
              .doc(studentId)
              .get();

          if (studentDoc.exists) {
            Map<String, dynamic> studentData = studentDoc.data() as Map<String, dynamic>;
            data['studentName'] = studentData['name'];
            data['studentEmail'] = studentData['email'];
            data['course'] = studentData['course'];
            data['phone'] = studentData['phone'];
            data['address'] = studentData['address'];
          }
        } catch (e) {
          print("⚠️ Error fetching student data for $studentId: $e");
        }

        applications.add(data);
      }

      // Sort by appliedAt (most recent first)
      applications.sort((a, b) {
        int appliedAtA = a['appliedAt'] ?? 0;
        int appliedAtB = b['appliedAt'] ?? 0;
        return appliedAtB.compareTo(appliedAtA);
      });

      print("✅ Admin found ${applications.length} applications");
      return applications;

    } catch (e) {
      print("❌ Error fetching applications: $e");
      return [];
    }
  }

  // Approve application
  static Future<Map<String, dynamic>> approveApplication(String applicationId, String adminComment) async {
    try {
      print("🔵 Approving application: $applicationId");

      await _firestore.collection('bus_applications').doc(applicationId).update({
        'status': 'approved',
        'approvedAt': DateTime.now().millisecondsSinceEpoch,
        'approvedBy': SharedPrefService.getUserId(),
        'adminComment': adminComment,
      });

      print("✅ Application approved successfully");
      return {'success': true, 'message': 'Application approved successfully'};
    } catch (e) {
      print("❌ Error approving application: $e");
      return {'success': false, 'message': 'Failed to approve application'};
    }
  }

  // Reject application
  static Future<Map<String, dynamic>> rejectApplication(String applicationId, String reason) async {
    try {
      print("🔵 Rejecting application: $applicationId");

      await _firestore.collection('bus_applications').doc(applicationId).update({
        'status': 'rejected',
        'rejectedAt': DateTime.now().millisecondsSinceEpoch,
        'rejectedBy': SharedPrefService.getUserId(),
        'rejectionReason': reason,
      });

      print("✅ Application rejected successfully");
      return {'success': true, 'message': 'Application rejected successfully'};
    } catch (e) {
      print("❌ Error rejecting application: $e");
      return {'success': false, 'message': 'Failed to reject application'};
    }
  }

  // Generate digital concession card
  static Future<Map<String, dynamic>> generateDigitalConcessionCard({
    required String studentId,
    required String applicationId,
    required String routeFrom,
    required String routeTo,
    required DateTime validFrom,
    required DateTime validUntil,
  }) async {
    try {
      print("🔵 Generating digital concession card for student: $studentId");

      String cardId = "CARD_${DateTime.now().millisecondsSinceEpoch}";

      Map<String, dynamic> cardData = {
        'cardId': cardId,
        'studentId': studentId,
        'applicationId': applicationId,
        'routeFrom': routeFrom,
        'routeTo': routeTo,
        'validFrom': validFrom.millisecondsSinceEpoch,
        'validUntil': validUntil.millisecondsSinceEpoch,
        'isActive': true,
        'generatedAt': DateTime.now().millisecondsSinceEpoch,
        'generatedBy': SharedPrefService.getUserId(),
        'cardType': 'bus_concession',
        'qrCodeData': "CONCESSION_CARD:$cardId:$studentId:$routeFrom:$routeTo",
      };

      DocumentReference docRef = await _firestore
          .collection('digital_cards')
          .add(cardData);

      // Update the application with card reference
      await _firestore.collection('bus_applications').doc(applicationId).update({
        'digitalCardId': docRef.id,
        'digitalCardGenerated': true,
        'cardGeneratedAt': DateTime.now().millisecondsSinceEpoch,
      });

      print("✅ Digital card generated: ${docRef.id}");

      return {
        'success': true,
        'message': 'Digital concession card generated successfully',
        'cardId': docRef.id,
        'customCardId': cardId,
      };

    } catch (e) {
      print("❌ Error generating digital card: $e");
      return {
        'success': false,
        'message': 'Failed to generate digital card',
      };
    }
  }

  // Get digital card by application ID
  static Future<Map<String, dynamic>?> getDigitalCardByApplication(String applicationId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('digital_cards')
          .where('applicationId', isEqualTo: applicationId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> cardData = snapshot.docs.first.data() as Map<String, dynamic>;
        cardData['id'] = snapshot.docs.first.id;
        return cardData;
      }

      return null;
    } catch (e) {
      print("❌ Error fetching digital card: $e");
      return null;
    }
  }

  // ==================== STATISTICS & ANALYTICS ====================

  // Get application statistics
  static Future<Map<String, int>> getApplicationStatistics() async {
    try {
      print("🔵 Fetching application statistics");

      QuerySnapshot snapshot = await _firestore
          .collection('bus_applications')
          .get();

      Map<String, int> stats = {
        'total': 0,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
      };

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? 'pending';

        stats['total'] = (stats['total'] ?? 0) + 1;
        stats[status] = (stats[status] ?? 0) + 1;
      }

      print("✅ Application statistics: $stats");
      return stats;
    } catch (e) {
      print("❌ Error fetching application statistics: $e");
      return {
        'total': 0,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
      };
    }
  }

  // Get institution statistics
  static Future<Map<String, int>> getInstitutionStatistics() async {
    try {
      print("🔵 Fetching institution statistics");

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'institution')
          .get();

      Map<String, int> stats = {
        'total': 0,
        'verified': 0,
        'pending': 0,
        'rejected': 0,
      };

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        stats['total'] = (stats['total'] ?? 0) + 1;

        if (data['isVerified'] == true) {
          stats['verified'] = (stats['verified'] ?? 0) + 1;
        } else if (data['isRejected'] == true) {
          stats['rejected'] = (stats['rejected'] ?? 0) + 1;
        } else {
          stats['pending'] = (stats['pending'] ?? 0) + 1;
        }
      }

      print("✅ Institution statistics: $stats");
      return stats;
    } catch (e) {
      print("❌ Error fetching institution statistics: $e");
      return {
        'total': 0,
        'verified': 0,
        'pending': 0,
        'rejected': 0,
      };
    }
  }

  // Get student statistics
  static Future<Map<String, int>> getStudentStatistics() async {
    try {
      print("🔵 Fetching student statistics");

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      Map<String, int> stats = {
        'total': 0,
        'verified': 0,
        'pending': 0,
        'rejected': 0,
      };

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        stats['total'] = (stats['total'] ?? 0) + 1;

        if (data['isVerified'] == true) {
          stats['verified'] = (stats['verified'] ?? 0) + 1;
        } else if (data['isRejected'] == true) {
          stats['rejected'] = (stats['rejected'] ?? 0) + 1;
        } else {
          stats['pending'] = (stats['pending'] ?? 0) + 1;
        }
      }

      print("✅ Student statistics: $stats");
      return stats;
    } catch (e) {
      print("❌ Error fetching student statistics: $e");
      return {
        'total': 0,
        'verified': 0,
        'pending': 0,
        'rejected': 0,
      };
    }
  }

  // ==================== CARD MANAGEMENT ====================

  // Get all active digital cards
  static Future<List<Map<String, dynamic>>> getAllActiveCards() async {
    try {
      print("🔵 Fetching all active digital cards");

      QuerySnapshot snapshot = await _firestore
          .collection('digital_cards')
          .where('isActive', isEqualTo: true)
          .orderBy('generatedAt', descending: true)
          .get();

      List<Map<String, dynamic>> cards = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Get student details
        String studentId = data['studentId'];
        try {
          DocumentSnapshot studentDoc = await _firestore
              .collection('users')
              .doc(studentId)
              .get();

          if (studentDoc.exists) {
            Map<String, dynamic> studentData = studentDoc.data() as Map<String, dynamic>;
            data['studentName'] = studentData['name'];
            data['studentEmail'] = studentData['email'];
            data['course'] = studentData['course'];
          }
        } catch (e) {
          print("⚠️ Error fetching student data for card: $e");
        }

        cards.add(data);
      }

      print("✅ Found ${cards.length} active digital cards");
      return cards;

    } catch (e) {
      print("❌ Error fetching digital cards: $e");
      return [];
    }
  }

  // Deactivate digital card
  static Future<Map<String, dynamic>> deactivateCard(String cardId, String reason) async {
    try {
      print("🔵 Deactivating digital card: $cardId");

      await _firestore.collection('digital_cards').doc(cardId).update({
        'isActive': false,
        'deactivatedAt': DateTime.now().millisecondsSinceEpoch,
        'deactivatedBy': SharedPrefService.getUserId(),
        'deactivationReason': reason,
      });

      print("✅ Digital card deactivated successfully");
      return {'success': true, 'message': 'Digital card deactivated successfully'};
    } catch (e) {
      print("❌ Error deactivating digital card: $e");
      return {'success': false, 'message': 'Failed to deactivate digital card'};
    }
  }
}