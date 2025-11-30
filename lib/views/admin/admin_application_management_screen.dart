// views/admin/admin_application_management_screen.dart
import 'package:flutter/material.dart';
import 'package:concessoapp/controllers/admin_controller.dart';
import 'package:concessoapp/views/admin/digital_concession_card_screen.dart';

class AdminApplicationManagementScreen extends StatefulWidget {
  @override
  _AdminApplicationManagementScreenState createState() => _AdminApplicationManagementScreenState();
}

class _AdminApplicationManagementScreenState extends State<AdminApplicationManagementScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  List<Map<String, dynamic>> _pendingApplications = [];
  List<Map<String, dynamic>> _approvedApplications = [];
  List<Map<String, dynamic>> _rejectedApplications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadApplications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _loadApplications() async {
    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> applications = await AdminController.getAllBusApplications();

    setState(() {
      _pendingApplications = applications.where((app) => app['status'] == 'pending').toList();
      _approvedApplications = applications.where((app) => app['status'] == 'approved').toList();
      _rejectedApplications = applications.where((app) => app['status'] == 'rejected').toList();
      _isLoading = false;
    });
  }

  // Approve application and generate digital card
  _approveApplication(Map<String, dynamic> application) async {
    try {
      // Show confirmation dialog
      bool? confirmed = await _showApprovalDialog(application);
      if (confirmed != true) return;

      setState(() {
        _isLoading = true;
      });

      // Approve the application
      Map<String, dynamic> result = await AdminController.approveApplication(
        application['id'],
        'Application approved by admin',
      );

      if (result['success']) {
        // Generate digital concession card
        Map<String, dynamic> cardResult = await AdminController.generateDigitalConcessionCard(
          studentId: application['studentId'],
          applicationId: application['id'],
          routeFrom: application['routeFrom'],
          routeTo: application['routeTo'],
          validFrom: DateTime.now(),
          validUntil: DateTime.now().add(Duration(days: 365)), // Valid for 1 year
        );

        if (cardResult['success']) {
          _showSnackBar('Application approved and digital card generated!', Colors.green);
          _loadApplications(); // Refresh the list

          // Show the generated card
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DigitalConcessionCardScreen(
                cardId: cardResult['cardId'],
                studentData: {
                  'name': application['studentName'],
                  'studentId': application['studentId'],
                  'course': application['course'],
                  'email': application['studentEmail'],
                },
                routeData: {
                  'from': application['routeFrom'],
                  'to': application['routeTo'],
                },
              ),
            ),
          );
        } else {
          _showSnackBar('Application approved but failed to generate card', Colors.orange);
        }
      } else {
        _showSnackBar('Failed to approve application', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Reject application
  _rejectApplication(Map<String, dynamic> application) async {
    String? reason = await _showRejectionDialog();
    if (reason == null || reason.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> result = await AdminController.rejectApplication(
      application['id'],
      reason,
    );

    if (result['success']) {
      _showSnackBar('Application rejected', Colors.orange);
      _loadApplications();
    } else {
      _showSnackBar('Failed to reject application', Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool?> _showApprovalDialog(Map<String, dynamic> application) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Approve Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to approve this application?'),
            SizedBox(height: 12),
            Text('Student: ${application['studentName']}', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Route: ${application['routeFrom']} → ${application['routeTo']}'),
            Text('This will generate a digital concession card.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Approve & Generate Card'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showRejectionDialog() {
    TextEditingController reasonController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for rejection:'),
            SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Rejection Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Applications'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'Pending (${_pendingApplications.length})',
              icon: Icon(Icons.pending_actions),
            ),
            Tab(
              text: 'Approved (${_approvedApplications.length})',
              icon: Icon(Icons.check_circle),
            ),
            Tab(
              text: 'Rejected (${_rejectedApplications.length})',
              icon: Icon(Icons.cancel),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadApplications,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildApplicationList(_pendingApplications, 'pending'),
          _buildApplicationList(_approvedApplications, 'approved'),
          _buildApplicationList(_rejectedApplications, 'rejected'),
        ],
      ),
    );
  }

  Widget _buildApplicationList(List<Map<String, dynamic>> applications, String status) {
    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'pending' ? Icons.pending_actions :
              status == 'approved' ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No ${status} applications',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> application = applications[index];
        return _buildApplicationCard(application, status);
      },
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application, String status) {
    DateTime appliedAt = DateTime.fromMillisecondsSinceEpoch(application['appliedAt'] ?? 0);
    Color statusColor = status == 'approved' ? Colors.green :
    status == 'rejected' ? Colors.red : Colors.orange;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(Icons.person, color: statusColor),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['studentName'] ?? 'Unknown Student',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'ID: ${application['studentId']} | Course: ${application['course'] ?? 'N/A'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            _buildInfoRow(Icons.directions_bus, 'Route', '${application['routeFrom']} → ${application['routeTo']}'),
            _buildInfoRow(Icons.calendar_today, 'Applied', '${appliedAt.day}/${appliedAt.month}/${appliedAt.year}'),
            _buildInfoRow(Icons.family_restroom, 'Guardian', '${application['guardianName']} (${application['guardianPhone']})'),
            _buildInfoRow(Icons.attach_money, 'Family Income', '₹${application['familyIncome']}'),

            SizedBox(height: 8),
            Text(
              'Reason: ${application['reason'] ?? 'No reason provided'}',
              style: TextStyle(color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (application['documents'] != null && application['documents'].isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'Documents: ${application['documents'].length} file(s) uploaded',
                style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600),
              ),
            ],

            SizedBox(height: 12),

            // Action buttons based on status
            if (status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.check, size: 16),
                      label: Text('Approve & Generate Card'),
                      onPressed: () => _approveApplication(application),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.close, size: 16),
                      label: Text('Reject'),
                      onPressed: () => _rejectApplication(application),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'approved') ...[
              ElevatedButton.icon(
                icon: Icon(Icons.credit_card, size: 16),
                label: Text('View Digital Card'),
                onPressed: () {
                  // Navigate to view the generated digital card
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DigitalConcessionCardScreen(
                        cardId: application['id'],
                        studentData: {
                          'name': application['studentName'],
                          'studentId': application['studentId'],
                          'course': application['course'],
                          'email': application['studentEmail'],
                        },
                        routeData: {
                          'from': application['routeFrom'],
                          'to': application['routeTo'],
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}