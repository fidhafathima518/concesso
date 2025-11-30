// controllers/announcement_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/shared_pref_service.dart';

class AnnouncementController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== ADMIN ANNOUNCEMENT MANAGEMENT ====================

  // Create new announcement
  static Future<Map<String, dynamic>> createAnnouncement({
    required String title,
    required String content,
    required String category,
    required String priority,
    required String targetAudience,
    String? institutionId,
    DateTime? expiryDate,
  }) async {
    try {
      print("🔵 Creating announcement: $title");

      // Validate input
      if (title.isEmpty || content.isEmpty) {
        return {
          'success': false,
          'message': 'Please fill all required fields',
        };
      }

      String adminId = SharedPrefService.getUserId();
      String adminName = SharedPrefService.getUserName();

      // Generate unique announcement ID
      String announcementId = "ANN_${DateTime.now().millisecondsSinceEpoch}";

      Map<String, dynamic> announcementData = {
        'announcementId': announcementId,
        'title': title,
        'content': content,
        'category': category, // General, Academic, Transport, Emergency, Maintenance
        'priority': priority, // Low, Normal, High, Urgent
        'targetAudience': targetAudience, // All, Students, Institutions, Specific Institution
        'institutionId': institutionId, // null for all, specific ID for targeted
        'createdBy': adminId,
        'createdByName': adminName,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'expiryDate': expiryDate?.millisecondsSinceEpoch,
        'isActive': true,
        'viewCount': 0,
        'readByUsers': [], // List of user IDs who have read this announcement
      };

      DocumentReference docRef = await _firestore
          .collection('announcements')
          .add(announcementData);

      print("✅ Announcement created successfully");
      return {
        'success': true,
        'message': 'Announcement posted successfully',
        'announcementId': docRef.id,
        'customAnnouncementId': announcementId,
      };

    } catch (e) {
      print("❌ Error creating announcement: $e");
      return {
        'success': false,
        'message': 'Failed to create announcement. Please try again.',
      };
    }
  }

  // Get all announcements for admin
  static Future<List<Map<String, dynamic>>> getAllAnnouncements() async {
    try {
      print("🔵 Fetching all announcements for admin");

      QuerySnapshot snapshot = await _firestore
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> announcements = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Check if announcement is expired
        if (data['expiryDate'] != null) {
          DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(data['expiryDate']);
          data['isExpired'] = DateTime.now().isAfter(expiryDate);
        } else {
          data['isExpired'] = false;
        }

        return data;
      }).toList();

      print("✅ Found ${announcements.length} announcements");
      return announcements;
    } catch (e) {
      print("❌ Error fetching announcements: $e");
      return [];
    }
  }

  // Update announcement
  static Future<Map<String, dynamic>> updateAnnouncement({
    required String announcementId,
    required String title,
    required String content,
    required String category,
    required String priority,
    required String targetAudience,
    String? institutionId,
    DateTime? expiryDate,
  }) async {
    try {
      print("🔵 Updating announcement: $announcementId");

      Map<String, dynamic> updateData = {
        'title': title,
        'content': content,
        'category': category,
        'priority': priority,
        'targetAudience': targetAudience,
        'institutionId': institutionId,
        'expiryDate': expiryDate?.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _firestore
          .collection('announcements')
          .doc(announcementId)
          .update(updateData);

      print("✅ Announcement updated successfully");
      return {
        'success': true,
        'message': 'Announcement updated successfully',
      };
    } catch (e) {
      print("❌ Error updating announcement: $e");
      return {
        'success': false,
        'message': 'Failed to update announcement',
      };
    }
  }

  // Delete announcement
  static Future<Map<String, dynamic>> deleteAnnouncement(String announcementId) async {
    try {
      print("🔵 Deleting announcement: $announcementId");

      await _firestore
          .collection('announcements')
          .doc(announcementId)
          .delete();

      print("✅ Announcement deleted successfully");
      return {
        'success': true,
        'message': 'Announcement deleted successfully',
      };
    } catch (e) {
      print("❌ Error deleting announcement: $e");
      return {
        'success': false,
        'message': 'Failed to delete announcement',
      };
    }
  }

  // Toggle announcement active status
  static Future<Map<String, dynamic>> toggleAnnouncementStatus(String announcementId, bool isActive) async {
    try {
      print("🔵 Toggling announcement status: $announcementId to $isActive");

      await _firestore
          .collection('announcements')
          .doc(announcementId)
          .update({
        'isActive': isActive,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      print("✅ Announcement status updated successfully");
      return {
        'success': true,
        'message': isActive ? 'Announcement activated' : 'Announcement deactivated',
      };
    } catch (e) {
      print("❌ Error toggling announcement status: $e");
      return {
        'success': false,
        'message': 'Failed to update announcement status',
      };
    }
  }

  // ==================== STUDENT/INSTITUTION ANNOUNCEMENT VIEWING ====================

  // Get announcements for students
  static Future<List<Map<String, dynamic>>> getAnnouncementsForStudent(String studentId) async {
    try {
      print("🔵 Fetching announcements for student: $studentId");

      // Get student's institution
      DocumentSnapshot studentDoc = await _firestore
          .collection('users')
          .doc(studentId)
          .get();

      String? institutionId;
      if (studentDoc.exists) {
        Map<String, dynamic> studentData = studentDoc.data() as Map<String, dynamic>;
        institutionId = studentData['institutionId'];
      }

      // Query for announcements
      Query query = _firestore
          .collection('announcements')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      QuerySnapshot snapshot = await query.get();

      List<Map<String, dynamic>> announcements = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Check if announcement is expired
        if (data['expiryDate'] != null) {
          DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(data['expiryDate']);
          if (DateTime.now().isAfter(expiryDate)) {
            continue; // Skip expired announcements
          }
        }

        // Filter by target audience
        String targetAudience = data['targetAudience'] ?? 'All';

        if (targetAudience == 'All' || targetAudience == 'Students') {
          announcements.add(data);
        } else if (targetAudience == 'Specific Institution' &&
            institutionId != null &&
            data['institutionId'] == institutionId) {
          announcements.add(data);
        }
      }

      print("✅ Found ${announcements.length} announcements for student");
      return announcements;
    } catch (e) {
      print("❌ Error fetching student announcements: $e");
      return [];
    }
  }

  // Get announcements for institutions
  static Future<List<Map<String, dynamic>>> getAnnouncementsForInstitution(String institutionId) async {
    try {
      print("🔵 Fetching announcements for institution: $institutionId");

      Query query = _firestore
          .collection('announcements')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      QuerySnapshot snapshot = await query.get();

      List<Map<String, dynamic>> announcements = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Check if announcement is expired
        if (data['expiryDate'] != null) {
          DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(data['expiryDate']);
          if (DateTime.now().isAfter(expiryDate)) {
            continue; // Skip expired announcements
          }
        }

        // Filter by target audience
        String targetAudience = data['targetAudience'] ?? 'All';

        if (targetAudience == 'All' || targetAudience == 'Institutions') {
          announcements.add(data);
        } else if (targetAudience == 'Specific Institution' &&
            data['institutionId'] == institutionId) {
          announcements.add(data);
        }
      }

      print("✅ Found ${announcements.length} announcements for institution");
      return announcements;
    } catch (e) {
      print("❌ Error fetching institution announcements: $e");
      return [];
    }
  }

  // Mark announcement as read
  static Future<Map<String, dynamic>> markAnnouncementAsRead(String announcementId, String userId) async {
    try {
      print("🔵 Marking announcement as read: $announcementId by $userId");

      DocumentReference announcementRef = _firestore
          .collection('announcements')
          .doc(announcementId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot announcementDoc = await transaction.get(announcementRef);

        if (announcementDoc.exists) {
          Map<String, dynamic> data = announcementDoc.data() as Map<String, dynamic>;
          List<dynamic> readByUsers = data['readByUsers'] ?? [];

          if (!readByUsers.contains(userId)) {
            readByUsers.add(userId);
            int viewCount = (data['viewCount'] ?? 0) + 1;

            transaction.update(announcementRef, {
              'readByUsers': readByUsers,
              'viewCount': viewCount,
            });
          }
        }
      });

      print("✅ Announcement marked as read");
      return {
        'success': true,
        'message': 'Announcement marked as read',
      };
    } catch (e) {
      print("❌ Error marking announcement as read: $e");
      return {
        'success': false,
        'message': 'Failed to mark announcement as read',
      };
    }
  }

  // ==================== ANALYTICS & STATISTICS ====================

  // Get announcement statistics
  static Future<Map<String, dynamic>> getAnnouncementStats() async {
    try {
      print("🔵 Fetching announcement statistics");

      QuerySnapshot snapshot = await _firestore
          .collection('announcements')
          .get();

      Map<String, dynamic> stats = {
        'total': 0,
        'active': 0,
        'inactive': 0,
        'expired': 0,
        'byCategory': <String, int>{},
        'byPriority': <String, int>{},
        'totalViews': 0,
      };

      DateTime now = DateTime.now();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        stats['total'] = (stats['total'] as int) + 1;

        bool isActive = data['isActive'] ?? true;
        bool isExpired = false;

        if (data['expiryDate'] != null) {
          DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(data['expiryDate']);
          isExpired = now.isAfter(expiryDate);
        }

        if (isExpired) {
          stats['expired'] = (stats['expired'] as int) + 1;
        } else if (isActive) {
          stats['active'] = (stats['active'] as int) + 1;
        } else {
          stats['inactive'] = (stats['inactive'] as int) + 1;
        }

        // Category stats
        String category = data['category'] ?? 'General';
        Map<String, int> categoryStats = stats['byCategory'] as Map<String, int>;
        categoryStats[category] = (categoryStats[category] ?? 0) + 1;

        // Priority stats
        String priority = data['priority'] ?? 'Normal';
        Map<String, int> priorityStats = stats['byPriority'] as Map<String, int>;
        priorityStats[priority] = (priorityStats[priority] ?? 0) + 1;

        // Total views
        stats['totalViews'] = (stats['totalViews'] as int) + (data['viewCount'] ?? 0);
      }

      print("✅ Announcement statistics fetched");
      return stats;
    } catch (e) {
      print("❌ Error fetching announcement statistics: $e");
      return {
        'total': 0,
        'active': 0,
        'inactive': 0,
        'expired': 0,
        'byCategory': <String, int>{},
        'byPriority': <String, int>{},
        'totalViews': 0,
      };
    }
  }

  // Get recent announcements (for dashboard widgets)
  static Future<List<Map<String, dynamic>>> getRecentAnnouncements({int limit = 5}) async {
    try {
      print("🔵 Fetching recent announcements");

      QuerySnapshot snapshot = await _firestore
          .collection('announcements')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      List<Map<String, dynamic>> announcements = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      print("✅ Found ${announcements.length} recent announcements");
      return announcements;
    } catch (e) {
      print("❌ Error fetching recent announcements: $e");
      return [];
    }
  }

  // ==================== HELPER METHODS ====================

  // Get announcement by ID
  static Future<Map<String, dynamic>?> getAnnouncementById(String announcementId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('announcements')
          .doc(announcementId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print("❌ Error fetching announcement details: $e");
      return null;
    }
  }

  // Search announcements
  static Future<List<Map<String, dynamic>>> searchAnnouncements(String query) async {
    try {
      print("🔵 Searching announcements for: $query");

      QuerySnapshot snapshot = await _firestore
          .collection('announcements')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> announcements = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        String title = (data['title'] ?? '').toLowerCase();
        String content = (data['content'] ?? '').toLowerCase();
        String category = (data['category'] ?? '').toLowerCase();
        String searchQuery = query.toLowerCase();

        if (title.contains(searchQuery) ||
            content.contains(searchQuery) ||
            category.contains(searchQuery)) {
          announcements.add(data);
        }
      }

      print("✅ Found ${announcements.length} matching announcements");
      return announcements;
    } catch (e) {
      print("❌ Error searching announcements: $e");
      return [];
    }
  }
}