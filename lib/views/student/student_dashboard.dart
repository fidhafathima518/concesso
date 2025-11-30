// views/student/student_dashboard.dart - Complete Corrected Version
import 'package:concessoapp/views/student/bus_card_application_screen.dart';
import 'package:concessoapp/views/student/grievance_submission_screen.dart';
import 'package:concessoapp/views/student/student_announcements_screen.dart';
import 'package:concessoapp/views/student/student_applications_screen.dart';
import 'package:concessoapp/views/student/student_digital_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:concessoapp/services/shared_pref_service.dart';
import 'package:concessoapp/controllers/auth_controller.dart';
import 'package:concessoapp/controllers/student_controller.dart';
import 'package:concessoapp/controllers/announcement_controller.dart';
import 'package:concessoapp/utils/route_helper.dart';

class StudentDashboard extends StatefulWidget {
  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String userName = '';
  String studentId = '';
  bool isVerified = false;
  bool isRejected = false;
  String verificationMessage = '';
  List<Map<String, dynamic>> recentApplications = [];
  List<Map<String, dynamic>> announcements = [];
  bool isLoadingVerification = true;
  bool isLoadingAnnouncements = false;
  bool hasDigitalCard = false;
  bool isLoadingCard = false;
  Map<String, dynamic>? digitalCardData;
  int unreadAnnouncementsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkVerificationStatus();
    _loadDashboardData();
    _loadAnnouncements();
  }

  _loadUserData() {
    setState(() {
      userName = SharedPrefService.getUserName();
      studentId = SharedPrefService.getUserId();
    });
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      isLoadingVerification = true;
    });

    Map<String, dynamic> status = await StudentController.checkStudentVerificationStatus(studentId);

    setState(() {
      isVerified = status['verified'] ?? false;
      isRejected = status['rejected'] ?? false;
      verificationMessage = status['message'] ?? '';
      isLoadingVerification = false;
    });

    // Check for digital card if verified
    if (isVerified) {
      _checkDigitalCard();
    }
  }

  Future<void> _checkDigitalCard() async {
    setState(() {
      isLoadingCard = true;
    });

    Map<String, dynamic>? cardData = await StudentController.getStudentDigitalCard(studentId);

    setState(() {
      hasDigitalCard = cardData != null;
      digitalCardData = cardData;
      isLoadingCard = false;
    });
  }

  Future<void> _loadDashboardData() async {
    // Only load applications if student is verified
    if (isVerified) {
      List<Map<String, dynamic>> apps = await StudentController.getStudentApplications(studentId);
      setState(() {
        recentApplications = apps.take(3).toList();
      });
    }
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      isLoadingAnnouncements = true;
    });

    try {
      List<Map<String, dynamic>> studentAnnouncements =
      await AnnouncementController.getAnnouncementsForStudent(studentId);

      // Calculate unread count
      int unreadCount = 0;
      for (var announcement in studentAnnouncements) {
        List<dynamic> readByUsers = announcement['readByUsers'] ?? [];
        if (!readByUsers.contains(studentId)) {
          unreadCount++;
        }
      }

      setState(() {
        announcements = studentAnnouncements.take(3).toList(); // Show top 3
        unreadAnnouncementsCount = unreadCount;
        isLoadingAnnouncements = false;
      });
    } catch (e) {
      print("Error loading announcements: $e");
      setState(() {
        announcements = [];
        unreadAnnouncementsCount = 0;
        isLoadingAnnouncements = false;
      });
    }
  }

  _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              Map<String, dynamic> result = await AuthController.logout();
              if (result['success']) {
                RouteHelper.navigateToLogin(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentAnnouncementsScreen(),
                    ),
                  ).then((_) => _loadAnnouncements());
                },
              ),
              if (unreadAnnouncementsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadAnnouncementsCount > 99 ? '99+' : unreadAnnouncementsCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _checkVerificationStatus();
              _loadDashboardData();
              _loadAnnouncements();
              if (isVerified) _checkDigitalCard();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _checkVerificationStatus();
          await _loadDashboardData();
          await _loadAnnouncements();
          if (isVerified) await _checkDigitalCard();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[700]!, Colors.blue[500]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Student ID: $studentId',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Verification Status Card
                _buildVerificationStatusCard(),
                SizedBox(height: 16),

                // Announcements Widget
                _buildAnnouncementsWidget(),
                SizedBox(height: 16),

                // Digital Card Banner (show if verified and has card)
                if (isVerified && hasDigitalCard && !isLoadingCard) ...[
                  _buildDigitalCardBanner(),
                  SizedBox(height: 16),
                ],

                // Digital Card Status (show if verified but no card yet)
                if (isVerified && !hasDigitalCard && !isLoadingCard) ...[
                  _buildNoCardStatus(),
                  SizedBox(height: 16),
                ],

                // Quick Actions (only show if verified)
                if (isVerified) ...[
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Active Card Info Banner (show if card is active)
                  if (hasDigitalCard && digitalCardData != null) ...[
                    _buildActiveCardInfoBanner(),
                    SizedBox(height: 12),
                  ],

                  // First row: Digital Card + Apply for Bus Card
                  Row(
                    children: [
                      Expanded(
                        child: _buildDigitalCardActionCard(),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildApplyCardActionCard(),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Second row: Applications + Grievance
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          'My Applications',
                          Icons.assignment_turned_in,
                          Colors.orange,
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentApplicationsScreen(),
                              ),
                            ).then((_) => _loadDashboardData());
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          'Submit Grievance',
                          Icons.report_problem,
                          Colors.red,
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GrievanceSubmissionScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Recent Applications
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Applications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentApplicationsScreen(),
                            ),
                          );
                        },
                        child: Text('View All'),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildRecentApplications(),
                  SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // NEW: Built-in Announcements Widget
  Widget _buildAnnouncementsWidget() {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[700],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Latest Announcements',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (unreadAnnouncementsCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadAnnouncementsCount > 99 ? '99+' : unreadAnnouncementsCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: _loadAnnouncements,
                  icon: Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
          ),

          // Content
          Container(
            constraints: BoxConstraints(maxHeight: 300),
            child: isLoadingAnnouncements
                ? Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
                : announcements.isEmpty
                ? _buildAnnouncementsEmptyState()
                : _buildAnnouncementsList(),
          ),

          // View All Button
          if (announcements.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentAnnouncementsScreen(),
                    ),
                  ).then((_) => _loadAnnouncements());
                },
                child: Text(
                  'View All Announcements',
                  style: TextStyle(color: Colors.orange[700]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsEmptyState() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No announcements',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check back later for updates',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> announcement = announcements[index];
        return _buildAnnouncementItem(announcement);
      },
    );
  }

  Widget _buildAnnouncementItem(Map<String, dynamic> announcement) {
    DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(announcement['createdAt'] ?? 0);
    String category = announcement['category'] ?? 'General';
    String priority = announcement['priority'] ?? 'Normal';

    List<dynamic> readByUsers = announcement['readByUsers'] ?? [];
    bool isRead = readByUsers.contains(studentId);

    Color priorityColor = _getPriorityColor(priority);
    Color categoryColor = _getCategoryColor(category);

    return InkWell(
      onTap: () => _showAnnouncementDetails(announcement),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          color: isRead ? null : Colors.orange[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.orange[700],
                      shape: BoxShape.circle,
                    ),
                    margin: EdgeInsets.only(right: 8),
                  ),
                Expanded(
                  child: Text(
                    announcement['title'] ?? 'No Title',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              announcement['content'] ?? 'No content',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showAnnouncementDetails(Map<String, dynamic> announcement) {
    // Mark as read
    AnnouncementController.markAnnouncementAsRead(announcement['id'], studentId);

    // Update UI
    setState(() {
      List<dynamic> readByUsers = announcement['readByUsers'] ?? [];
      if (!readByUsers.contains(studentId)) {
        readByUsers.add(studentId);
        announcement['readByUsers'] = readByUsers;
        unreadAnnouncementsCount = unreadAnnouncementsCount > 0 ? unreadAnnouncementsCount - 1 : 0;
      }
    });

    DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(announcement['createdAt'] ?? 0);
    DateTime? expiryDate;
    if (announcement['expiryDate'] != null) {
      expiryDate = DateTime.fromMillisecondsSinceEpoch(announcement['expiryDate']);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications, color: Colors.orange[700]),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                announcement['title'] ?? 'Announcement',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category and Priority Tags
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(announcement['category'] ?? 'General').withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      announcement['category'] ?? 'General',
                      style: TextStyle(
                        color: _getCategoryColor(announcement['category'] ?? 'General'),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(announcement['priority'] ?? 'Normal').withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      announcement['priority'] ?? 'Normal',
                      style: TextStyle(
                        color: _getPriorityColor(announcement['priority'] ?? 'Normal'),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Content
              Text(
                announcement['content'] ?? 'No content available',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              // Metadata
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Published: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (expiryDate != null)
                      Text(
                        'Expires: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    Text(
                      'By: ${announcement['createdByName'] ?? 'Admin'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'emergency':
        return Colors.red;
      case 'academic':
        return Colors.purple;
      case 'transport':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'general':
      default:
        return Colors.teal;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'low':
      default:
        return Colors.green;
    }
  }

  Widget _buildDigitalCardBanner() {
    if (digitalCardData == null) return SizedBox.shrink();

    bool isActive = digitalCardData!['isActive'] ?? false;
    DateTime validUntil = DateTime.fromMillisecondsSinceEpoch(digitalCardData!['validUntil'] ?? 0);
    bool isExpired = DateTime.now().isAfter(validUntil);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive && !isExpired
              ? [Colors.green[700]!, Colors.green[500]!]
              : [Colors.grey[600]!, Colors.grey[400]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isActive && !isExpired ? Colors.green : Colors.grey).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.credit_card,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive && !isExpired ? 'Digital Card Active!' : 'Digital Card Inactive',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  isActive && !isExpired
                      ? 'Your bus concession card is ready to use'
                      : isExpired
                      ? 'Your card has expired'
                      : 'Your card has been deactivated',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                if (isActive && !isExpired) ...[
                  SizedBox(height: 4),
                  Text(
                    'Route: ${digitalCardData!['routeFrom']} → ${digitalCardData!['routeTo']}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentDigitalCardScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCardStatus() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.blue[700]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Digital Card Yet',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Apply for a bus card to get your digital concession card',
                  style: TextStyle(color: Colors.blue[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCardInfoBanner() {
    if (digitalCardData == null) return SizedBox.shrink();

    bool isActive = digitalCardData!['isActive'] ?? false;
    DateTime validUntil = DateTime.fromMillisecondsSinceEpoch(digitalCardData!['validUntil'] ?? 0);
    bool isExpired = DateTime.now().isAfter(validUntil);
    bool cardIsActive = isActive && !isExpired;

    if (!cardIsActive) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.amber[700], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have an active digital card',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Only one active bus card is allowed per student. To apply for a new route, your current card must expire or be deactivated.',
                  style: TextStyle(
                    color: Colors.amber[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyCardActionCard() {
    bool cardIsActive = false;
    if (digitalCardData != null) {
      bool isActive = digitalCardData!['isActive'] ?? false;
      DateTime validUntil = DateTime.fromMillisecondsSinceEpoch(digitalCardData!['validUntil'] ?? 0);
      bool isExpired = DateTime.now().isAfter(validUntil);
      cardIsActive = isActive && !isExpired;
    }

    return Card(
      elevation: 3,
      child: InkWell(
        onTap: cardIsActive
            ? null  // Disable if card is active
            : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BusCardApplicationScreen(),
            ),
          ).then((_) {
            _loadDashboardData();
            _checkDigitalCard();
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Stack(
                children: [
                  Icon(
                    Icons.directions_bus,
                    size: 32,
                    color: cardIsActive ? Colors.grey[400] : Colors.green,
                  ),
                  if (cardIsActive)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.block,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                cardIsActive ? 'Card Already Issued' : 'Apply for Bus Card',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: cardIsActive ? Colors.grey[600] : Colors.black,
                ),
              ),
              if (cardIsActive) ...[
                SizedBox(height: 4),
                Text(
                  'Only one active card allowed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitalCardActionCard() {
    if (isLoadingCard) {
      return Card(
        elevation: 3,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              CircularProgressIndicator(strokeWidth: 2),
              SizedBox(height: 8),
              Text(
                'Checking Card...',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 3,
      child: InkWell(
        onTap: hasDigitalCard
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDigitalCardScreen(),
            ),
          );
        }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                hasDigitalCard ? Icons.credit_card : Icons.credit_card_off,
                size: 32,
                color: hasDigitalCard ? Colors.green : Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                hasDigitalCard ? 'My Digital Card' : 'No Digital Card',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: hasDigitalCard ? Colors.black : Colors.grey,
                ),
              ),
              if (hasDigitalCard) ...[
                SizedBox(height: 4),
                Text(
                  'Tap to view',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationStatusCard() {
    if (isLoadingVerification) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Checking verification status...'),
            ],
          ),
        ),
      );
    }

    Color statusColor;
    IconData statusIcon;
    String statusText;
    Widget? actionButton;

    if (isRejected) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'VERIFICATION REJECTED';
      actionButton = ElevatedButton(
        onPressed: () {
          _showRejectionDetailsDialog();
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: Text('View Details', style: TextStyle(color: Colors.white)),
      );
    } else if (isVerified) {
      statusColor = Colors.green;
      statusIcon = Icons.verified;
      statusText = 'ACCOUNT VERIFIED';
      actionButton = null;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
      statusText = 'PENDING VERIFICATION';
      actionButton = ElevatedButton(
        onPressed: () {
          _checkVerificationStatus();
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        child: Text('Check Status', style: TextStyle(color: Colors.white)),
      );
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        verificationMessage,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                if (actionButton != null) actionButton,
              ],
            ),
            if (!isVerified && !isRejected) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[700], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your institution needs to verify your account before you can apply for bus cards.',
                        style: TextStyle(color: Colors.orange[800], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRejectionDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text('Verification Rejected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your verification was rejected by your institution.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text('Reason:'),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              child: Text(
                verificationMessage,
                style: TextStyle(color: Colors.red[800]),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Please contact your institution to resolve this issue.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentApplications() {
    bool cardIsActive = false;
    if (digitalCardData != null) {
      bool isActive = digitalCardData!['isActive'] ?? false;
      DateTime validUntil = DateTime.fromMillisecondsSinceEpoch(digitalCardData!['validUntil'] ?? 0);
      bool isExpired = DateTime.now().isAfter(validUntil);
      cardIsActive = isActive && !isExpired;
    }

    if (recentApplications.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                Text(
                  cardIsActive
                      ? 'You have an active digital card!'
                      : 'No applications yet.\nTap "Apply for Bus Card" to get started!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (cardIsActive) ...[
                  SizedBox(height: 8),
                  Text(
                    'Only one active card is allowed per student',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.orange[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: recentApplications.map((app) {
        DateTime appliedAt = DateTime.fromMillisecondsSinceEpoch(app['appliedAt']);
        String status = app['status'] ?? 'pending';
        bool hasDigitalCard = app['digitalCardGenerated'] == true;

        Color statusColor = status == 'approved'
            ? Colors.green
            : status == 'rejected'
            ? Colors.red
            : Colors.orange;

        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.directions_bus, color: Colors.blue),
            title: Text('${app['routeFrom']} → ${app['routeTo']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Applied on ${appliedAt.day}/${appliedAt.month}/${appliedAt.year}'),
                if (status == 'approved' && hasDigitalCard)
                  Text(
                    '✓ Digital card available',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            onTap: status == 'approved' && hasDigitalCard
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentDigitalCardScreen(),
                ),
              );
            }
                : null,
          ),
        );
      }).toList(),
    );
  }
}