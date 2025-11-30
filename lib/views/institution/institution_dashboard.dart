import 'package:concessoapp/views/institution/institution_applications_screen.dart';
import 'package:concessoapp/views/institution/student_records_screen.dart';
import 'package:concessoapp/views/institution/student_verification_screen.dart';
import 'package:concessoapp/views/institution/institution_grievance_screen.dart';
import 'package:flutter/material.dart';
import 'package:concessoapp/services/shared_pref_service.dart';
import 'package:concessoapp/controllers/auth_controller.dart';
import 'package:concessoapp/controllers/grievance_controller.dart';
import 'package:concessoapp/utils/route_helper.dart';

class InstitutionDashboard extends StatefulWidget {
  @override
  _InstitutionDashboardState createState() => _InstitutionDashboardState();
}

class _InstitutionDashboardState extends State<InstitutionDashboard> {
  String institutionName = '';
  String institutionId = '';
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
      institutionName = SharedPrefService.getUserName();
      institutionId = SharedPrefService.getUserId();
    });
  }

  _loadDashboardStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load grievance statistics for the institution
      Map<String, int> grievanceStats = await GrievanceController.getInstitutionGrievanceStats(institutionId);

      // You can add more statistics here from other controllers
      // Map<String, int> applicationStats = await ApplicationController.getInstitutionStats(institutionId);
      // Map<String, int> studentStats = await StudentController.getInstitutionStats(institutionId);

      setState(() {
        _dashboardStats = {
          'totalGrievances': grievanceStats['total'] ?? 0,
          'openGrievances': grievanceStats['open'] ?? 0,
          'inProgressGrievances': grievanceStats['in_progress'] ?? 0,
          'resolvedGrievances': grievanceStats['resolved'] ?? 0,
          // Add more stats as needed
          'pendingApplications': 0, // Placeholder
          'totalStudents': 0, // Placeholder
          'pendingVerifications': 0, // Placeholder
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
        title: Text('Institution Dashboard'),
        backgroundColor: Colors.green[700],
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
                    colors: [Colors.green[700]!, Colors.green[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome,',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Text(
                      institutionName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage your institution\'s bus concession system',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
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

              // Main Actions Section
              Text(
                'Institution Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // Dashboard Cards
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
                children: [
                  _buildDashboardCard(
                    'Verify Students',
                    'Approve student registrations\nand verify documents',
                    Icons.verified_user,
                    Colors.blue,
                    _navigateToStudentVerification,
                    badgeCount: _dashboardStats['pendingVerifications'],
                  ),
                  _buildDashboardCard(
                    'Handle Grievances',
                    'Review and respond to\nstudent grievances',
                    Icons.support_agent,
                    Colors.orange,
                    _navigateToGrievanceManagement,
                    badgeCount: _dashboardStats['openGrievances'],
                  ),
                  _buildDashboardCard(
                    'View Applications',
                    'Monitor bus card\napplication status',
                    Icons.assignment,
                    Colors.purple,
                    _navigateToApplications,
                    badgeCount: _dashboardStats['pendingApplications'],
                  ),
                  _buildDashboardCard(
                    'Student Records',
                    'View and manage\nstudent database',
                    Icons.people,
                    Colors.teal,
                    _navigateToStudentRecords,
                  ),
                  _buildDashboardCard(
                    'Reports & Analytics',
                    'Generate reports and\nview statistics',
                    Icons.analytics,
                    Colors.indigo,
                        () {
                      _showComingSoon(context, 'Reports & Analytics');
                    },
                  ),
                  _buildDashboardCard(
                    'Institution Settings',
                    'Configure institution\nsettings and preferences',
                    Icons.settings,
                    Colors.grey,
                        () {
                      _showComingSoon(context, 'Institution Settings');
                    },
                  ),
                ],
              ),
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
          'Quick Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
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
                'Open',
                _dashboardStats['openGrievances'] ?? 0,
                Icons.new_releases,
                Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'In Progress',
                _dashboardStats['inProgressGrievances'] ?? 0,
                Icons.pending_actions,
                Colors.purple,
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

  // Navigation Methods
  _navigateToStudentVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentVerificationScreen(),
      ),
    ).then((_) {
      _loadDashboardStats();
    });
  }

  _navigateToGrievanceManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstitutionGrievanceScreen(),
      ),
    ).then((_) {
      _loadDashboardStats();
    });
  }

  _navigateToApplications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstitutionApplicationsScreen(),
      ),
    ).then((_) {
      _loadDashboardStats();
    });
  }

  _navigateToStudentRecords() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentRecordsScreen(),
      ),
    ).then((_) {
      _loadDashboardStats();
    });
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