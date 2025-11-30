import 'package:concessoapp/services/shared_pref_service.dart';
import 'package:concessoapp/views/admin/admin_announcements_screen.dart';
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/grievance_controller.dart';
import '../../controllers/announcement_controller.dart';
import '../../utils/route_helper.dart';
import 'institution_verification_screen.dart';
import 'admin_application_management_screen.dart';
import 'admin_grievance_screen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String userName = '';
  bool _isLoading = false;
  Map<String, int> _dashboardStats = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDashboardStats();
  }

  _loadUserData() {
    setState(() {
      userName = SharedPrefService.getUserName();
    });
  }

  _loadDashboardStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load grievance statistics
      Map<String, int> grievanceStats = await GrievanceController.getAdminGrievanceStats();

      // Load announcement statistics
      Map<String, dynamic> announcementStats = await AnnouncementController.getAnnouncementStats();

      // You can add more statistics here from other controllers
      // Map<String, int> applicationStats = await ApplicationController.getAdminStats();
      // Map<String, int> institutionStats = await InstitutionController.getAdminStats();

      setState(() {
        _dashboardStats = {
          // Grievance stats
          'totalGrievances': grievanceStats['total'] ?? 0,
          'pendingGrievances': grievanceStats['open'] ?? 0,
          'transportGrievances': grievanceStats['transport'] ?? 0,
          'resolvedGrievances': grievanceStats['resolved'] ?? 0,

          // Announcement stats
          'totalAnnouncements': announcementStats['total'] ?? 0,
          'activeAnnouncements': announcementStats['active'] ?? 0,
          'totalAnnouncementViews': announcementStats['totalViews'] ?? 0,

          // Placeholder stats (replace with actual data)
          'pendingApplications': 0,
          'pendingInstitutions': 0,
        };
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading dashboard stats: $e");
      setState(() {
        _isLoading = false;
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
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardStats,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadDashboardStats();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
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
                    colors: [Colors.red[700]!, Colors.red[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $userName!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage the entire bus concession system from here',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Quick Stats Section
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else
                _buildQuickStats(),

              SizedBox(height: 24),

              // Main Actions Grid
              Text(
                'System Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildDashboardCard(
                    'Manage Applications',
                    'Process bus card applications\nand generate digital cards',
                    Icons.assignment_turned_in,
                    Colors.green,
                    _navigateToApplicationManagement,
                    badgeCount: _dashboardStats['pendingApplications'],
                  ),
                  _buildDashboardCard(
                    'Handle Grievances',
                    'Review and respond to\nstudent grievances',
                    Icons.support_agent,
                    Colors.blue,
                    _navigateToGrievanceManagement,
                    badgeCount: _dashboardStats['pendingGrievances'],
                  ),
                  _buildDashboardCard(
                    'Post Announcements',
                    'Create and manage\nsystem announcements',
                    Icons.campaign,
                    Colors.purple,
                    _navigateToAnnouncementManagement,
                    badgeCount: _getNewAnnouncementsBadge(),
                  ),
                  _buildDashboardCard(
                    'Verify Institutions',
                    'Approve or reject\ninstitution registrations',
                    Icons.business_center,
                    Colors.teal,
                    _navigateToInstitutionVerification,
                    badgeCount: _dashboardStats['pendingInstitutions'],
                  ),
                  _buildDashboardCard(
                    'Generate Reports',
                    'Analytics and reports\nfor system usage',
                    Icons.analytics,
                    Colors.orange,
                        () {
                      _showComingSoon(context, 'Reports & Analytics');
                    },
                  ),
                  _buildDashboardCard(
                    'System Settings',
                    'Configure system\nparameters and settings',
                    Icons.settings,
                    Colors.grey,
                        () {
                      _showComingSoon(context, 'System Settings');
                    },
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Recent Announcements Section
              if (_dashboardStats['totalAnnouncements'] != null &&
                  _dashboardStats['totalAnnouncements']! > 0)
                _buildRecentAnnouncementsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),

        // First Row - Grievances
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Grievances',
                _dashboardStats['totalGrievances'] ?? 0,
                Icons.list,
                Colors.blue,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Pending',
                _dashboardStats['pendingGrievances'] ?? 0,
                Icons.pending,
                Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Second Row - Transport & Resolved
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Transport Issues',
                _dashboardStats['transportGrievances'] ?? 0,
                Icons.directions_bus,
                Colors.red,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Resolved',
                _dashboardStats['resolvedGrievances'] ?? 0,
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Third Row - Announcements
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Announcements',
                _dashboardStats['totalAnnouncements'] ?? 0,
                Icons.campaign,
                Colors.purple,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Views',
                _dashboardStats['totalAnnouncementViews'] ?? 0,
                Icons.visibility,
                Colors.indigo,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      String title,
      String description,
      IconData icon,
      Color color,
      VoidCallback onTap, {
        int? badgeCount,
      }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: color,
                    ),
                  ),
                  if (badgeCount != null && badgeCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
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
              SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAnnouncementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Announcements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: _navigateToAnnouncementManagement,
              child: Text(
                'View All',
                style: TextStyle(color: Colors.purple[700]),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: AnnouncementController.getRecentAnnouncements(limit: 3),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No recent announcements',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              );
            }

            List<Map<String, dynamic>> announcements = snapshot.data!;
            return Column(
              children: announcements.map((announcement) {
                DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(announcement['createdAt'] ?? 0);
                String category = announcement['category'] ?? 'General';
                String priority = announcement['priority'] ?? 'Normal';

                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getAnnouncementCategoryColor(category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getAnnouncementCategoryIcon(category),
                        color: _getAnnouncementCategoryColor(category),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      announcement['title'] ?? 'No Title',
                      style: TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement['content'] ?? 'No content',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getAnnouncementPriorityColor(priority).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                priority,
                                style: TextStyle(
                                  color: _getAnnouncementPriorityColor(priority),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${announcement['viewCount'] ?? 0} views',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: _navigateToAnnouncementManagement,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // Navigation Methods
  _navigateToInstitutionVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstitutionVerificationScreen(),
      ),
    ).then((_) {
      _loadDashboardStats();
    });
  }

  _navigateToApplicationManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminApplicationManagementScreen(),
      ),
    ).then((_) {
      _loadDashboardStats();
    });
  }

  _navigateToGrievanceManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminGrievanceScreen(),
      ),
    ).then((_) {
      _loadDashboardStats();
    });
  }

  _navigateToAnnouncementManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminAnnouncementsScreen(),
      ),
    ).then((_) {
      _loadDashboardStats();
    });
  }

  // Helper Methods
  int? _getNewAnnouncementsBadge() {
    // You can implement logic to show new announcements that need attention
    // For now, return null (no badge)
    return null;
  }

  Color _getAnnouncementCategoryColor(String category) {
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

  IconData _getAnnouncementCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'emergency':
        return Icons.warning;
      case 'academic':
        return Icons.school;
      case 'transport':
        return Icons.directions_bus;
      case 'maintenance':
        return Icons.build;
      case 'general':
      default:
        return Icons.info;
    }
  }

  Color _getAnnouncementPriorityColor(String priority) {
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

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.construction, color: Colors.orange),
            SizedBox(width: 8),
            Text('Coming Soon'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$feature feature is under development and will be available in the next update.'),
            SizedBox(height: 16),
            Text(
              'Stay tuned for more exciting features!',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}