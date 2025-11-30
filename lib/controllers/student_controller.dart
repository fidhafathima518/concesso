// controllers/student_controller.dart - Corrected Full Code
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../services/image_service.dart';

class StudentController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final ImageService _imageService = ImageService();

  // Check if student is verified before allowing applications
  static Future<Map<String, dynamic>> checkStudentVerificationStatus(String studentId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(studentId)
          .get();

      if (!doc.exists) {
        return {
          'verified': false,
          'message': 'Student record not found',
        };
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      bool isVerified = data['isVerified'] ?? false;
      bool isRejected = data['isRejected'] ?? false;

      if (isRejected) {
        return {
          'verified': false,
          'rejected': true,
          'message': data['rejectionReason'] ?? 'Your verification was rejected by the institution',
        };
      }

      if (!isVerified) {
        return {
          'verified': false,
          'message': 'Your account is pending verification by your institution',
        };
      }

      return {
        'verified': true,
        'message': 'Account verified',
      };

    } catch (e) {
      print("❌ Error checking verification status: $e");
      return {
        'verified': false,
        'message': 'Error checking verification status',
      };
    }
  }

  // Apply for bus concession card - Updated with verification check and ImageService
  static Future<Map<String, dynamic>> applyForBusCard({
    required String studentId,
    required String routeFrom,
    required String routeTo,
    required String reason,
    required String guardianName,
    required String guardianPhone,
    required double familyIncome,
    required List<File> documents,
  }) async {
    try {
      print("🔵 Starting bus card application for student: $studentId");

      // First check if student is verified
      Map<String, dynamic> verificationStatus = await checkStudentVerificationStatus(studentId);

      if (!verificationStatus['verified']) {
        return {
          'success': false,
          'message': verificationStatus['message'],
          'requiresVerification': true,
        };
      }

      // Validate input
      if (routeFrom.isEmpty || routeTo.isEmpty || reason.isEmpty) {
        return {
          'success': false,
          'message': 'Please fill all required fields',
        };
      }

      if (guardianName.isEmpty || guardianPhone.isEmpty) {
        return {
          'success': false,
          'message': 'Please provide guardian information',
        };
      }

      if (familyIncome <= 0) {
        return {
          'success': false,
          'message': 'Please enter valid family income',
        };
      }

      if (documents.isEmpty) {
        return {
          'success': false,
          'message': 'Please upload at least one document',
        };
      }

      print("🔵 Uploading ${documents.length} documents...");

      // Upload documents using ImageService
      List<String> documentUrls = [];
      for (int i = 0; i < documents.length; i++) {
        print("📤 Uploading document ${i + 1}/${documents.length}");

        // Use unique identifier for each document
        String businessId = "${studentId}_bus_app_${DateTime.now().millisecondsSinceEpoch}_$i";
        String? uploadedUrl = await _imageService.uploadImageWorking(documents[i], businessId);

        if (uploadedUrl != null) {
          documentUrls.add(uploadedUrl);
          print("✅ Document ${i + 1} uploaded successfully: $uploadedUrl");
        } else {
          print("❌ Failed to upload document ${i + 1}");

          // Clean up previously uploaded documents if any upload fails
          if (documentUrls.isNotEmpty) {
            await deleteApplicationDocuments(documentUrls);
          }

          return {
            'success': false,
            'message': 'Failed to upload document ${i + 1}. Please try again.',
          };
        }
      }

      print("✅ All documents uploaded successfully");

      // Generate unique application ID
      String applicationId = "APP_${DateTime.now().millisecondsSinceEpoch}";

      // Create application data
      Map<String, dynamic> applicationData = {
        'studentId': studentId,
        'routeFrom': routeFrom,
        'routeTo': routeTo,
        'reason': reason,
        'guardianName': guardianName,
        'guardianPhone': guardianPhone,
        'familyIncome': familyIncome,
        'documents': documentUrls,
        'documentCount': documentUrls.length,
        'status': 'pending', // pending, approved, rejected
        'appliedAt': DateTime.now().millisecondsSinceEpoch,
        'applicationId': applicationId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      print("🔵 Saving application to Firestore...");

      // Save to Firestore
      DocumentReference docRef = await _firestore
          .collection('bus_applications')
          .add(applicationData);

      print("✅ Bus card application submitted successfully with ID: ${docRef.id}");

      return {
        'success': true,
        'message': 'Bus card application submitted successfully',
        'applicationId': docRef.id,
        'customApplicationId': applicationId,
      };

    } catch (e) {
      print("❌ Error submitting bus card application: $e");
      return {
        'success': false,
        'message': 'Failed to submit application. Please try again.',
      };
    }
  }

  // Get student's applications
  static Future<List<Map<String, dynamic>>> getStudentApplications(String studentId) async {
    try {
      print("🔵 Fetching applications for student: $studentId");

      QuerySnapshot snapshot = await _firestore
          .collection('bus_applications')
          .where('studentId', isEqualTo: studentId)
          .orderBy('appliedAt', descending: true)
          .get();

      List<Map<String, dynamic>> applications = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      print("✅ Found ${applications.length} applications");
      return applications;

    } catch (e) {
      print("❌ Error fetching student applications: $e");
      return [];
    }
  }

  // Submit grievance
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

      // Generate unique grievance ID
      String grievanceId = "GRV_${DateTime.now().millisecondsSinceEpoch}";

      Map<String, dynamic> grievanceData = {
        'studentId': studentId,
        'subject': subject,
        'description': description,
        'category': category, // Academic, Transport, Facilities, Administrative, Other
        'priority': priority, // Low, Medium, High
        'status': 'open', // open, in_progress, resolved, closed
        'submittedAt': DateTime.now().millisecondsSinceEpoch,
        'grievanceId': grievanceId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      DocumentReference docRef = await _firestore
          .collection('grievances')
          .add(grievanceData);

      print("✅ Grievance submitted successfully");
      return {
        'success': true,
        'message': 'Grievance submitted successfully',
        'grievanceId': docRef.id,
        'customGrievanceId': grievanceId,
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

  // Get announcements
  static Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      print("🔵 Fetching announcements...");

      QuerySnapshot snapshot = await _firestore
          .collection('announcements')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      List<Map<String, dynamic>> announcements = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      print("✅ Found ${announcements.length} announcements");
      return announcements;
    } catch (e) {
      print("❌ Error fetching announcements: $e");
      return [];
    }
  }

  // Helper method to pick documents using ImageService
  static Future<List<File>> pickDocuments() async {
    List<File> selectedFiles = [];

    try {
      // Allow user to pick multiple documents (up to 5)
      for (int i = 0; i < 5; i++) {
        File? pickedFile = await _imageService.showImagePickerDialog(null);

        if (pickedFile != null) {
          selectedFiles.add(pickedFile);
          break; // For now, just pick one at a time in UI
        } else {
          break; // User cancelled
        }
      }

      return selectedFiles;
    } catch (e) {
      print("❌ Error picking documents: $e");
      return [];
    }
  }

  // Delete application documents when application is cancelled/rejected
  static Future<bool> deleteApplicationDocuments(List<String> documentUrls) async {
    try {
      bool allDeleted = true;

      for (String url in documentUrls) {
        bool deleted = await _imageService.deleteImage(url);
        if (!deleted) {
          allDeleted = false;
          print("⚠️ Failed to delete document: $url");
        } else {
          print("✅ Deleted document: $url");
        }
      }

      return allDeleted;
    } catch (e) {
      print("❌ Error deleting documents: $e");
      return false;
    }
  }

  // Get student profile information
  static Future<Map<String, dynamic>?> getStudentProfile(String studentId) async {
    try {
      print("🔵 Fetching student profile: $studentId");

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(studentId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        print("✅ Student profile fetched successfully");
        return data;
      } else {
        print("❌ Student profile not found");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching student profile: $e");
      return null;
    }
  }

  // Update student profile
  static Future<Map<String, dynamic>> updateStudentProfile({
    required String studentId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      print("🔵 Updating student profile: $studentId");

      // Add update timestamp
      updateData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      await _firestore
          .collection('users')
          .doc(studentId)
          .update(updateData);

      print("✅ Student profile updated successfully");
      return {
        'success': true,
        'message': 'Profile updated successfully',
      };
    } catch (e) {
      print("❌ Error updating student profile: $e");
      return {
        'success': false,
        'message': 'Failed to update profile. Please try again.',
      };
    }
  }

  // Get application statistics for student
  static Future<Map<String, int>> getApplicationStatistics(String studentId) async {
    try {
      print("🔵 Fetching application statistics for student: $studentId");

      QuerySnapshot snapshot = await _firestore
          .collection('bus_applications')
          .where('studentId', isEqualTo: studentId)
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

  // Get student's digital concession card
  static Future<Map<String, dynamic>?> getStudentDigitalCard(String studentId) async {
    try {
      print("🔵 Fetching digital card for student: $studentId");

      QuerySnapshot snapshot = await _firestore
          .collection('digital_cards')
          .where('studentId', isEqualTo: studentId)
          .where('isActive', isEqualTo: true)
          .orderBy('generatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> cardData = snapshot.docs.first.data() as Map<String, dynamic>;
        cardData['id'] = snapshot.docs.first.id;

        print("✅ Found digital card for student");
        return cardData;
      } else {
        print("⚠️ No active digital card found for student");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching digital card: $e");
      return null;
    }
  }

  // Get all digital cards for student (including inactive)
  static Future<List<Map<String, dynamic>>> getStudentDigitalCards(String studentId) async {
    try {
      print("🔵 Fetching all digital cards for student: $studentId");

      QuerySnapshot snapshot = await _firestore
          .collection('digital_cards')
          .where('studentId', isEqualTo: studentId)
          .orderBy('generatedAt', descending: true)
          .get();

      List<Map<String, dynamic>> cards = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      print("✅ Found ${cards.length} digital cards for student");
      return cards;
    } catch (e) {
      print("❌ Error fetching digital cards: $e");
      return [];
    }
  }

  // Check if student has approved application with digital card
  static Future<bool> hasActiveDigitalCard(String studentId) async {
    try {
      Map<String, dynamic>? card = await getStudentDigitalCard(studentId);
      return card != null;
    } catch (e) {
      print("❌ Error checking for active digital card: $e");
      return false;
    }
  }
}