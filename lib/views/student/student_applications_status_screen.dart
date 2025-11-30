// views/student/student_applications_status_screen.dart
import 'package:flutter/material.dart';
import 'package:concessoapp/controllers/student_controller.dart';
import 'package:concessoapp/services/shared_pref_service.dart';
import 'student_digital_card_screen.dart';

class StudentApplicationsStatusScreen extends StatefulWidget {
  @override
  _StudentApplicationsStatusScreenState createState() => _StudentApplicationsStatusScreenState();
}

class _StudentApplicationsStatusScreenState extends State<StudentApplicationsStatusScreen> {
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  _loadApplications() async {
    setState(() {
      _isLoading = true;
    });

    String studentId = SharedPrefService.getUserId();
    List<Map<String, dynamic>> applications = await StudentController.getStudentApplications(studentId);

    setState(() {
      _applications = applications;
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Applications'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadApplications,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _applications.isEmpty
          ? _buildEmptyState()
          : _buildApplicationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Applications Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You haven\'t submitted any bus card applications',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Apply for Bus Card'),
            onPressed: () {
              // Navigate to application form
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _applications.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> application = _applications[index];
        return _buildApplicationCard(application);
      },
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    DateTime appliedAt = DateTime.fromMillisecondsSinceEpoch(application['appliedAt'] ?? 0);
    String status = application['status'] ?? 'pending';
    Color statusColor = _getStatusColor(status);
    IconData statusIcon = _getStatusIcon(status);
    bool hasDigitalCard = application['digitalCardGenerated'] == true;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Icon(Icons.directions_bus, color: Colors.blue[700]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${application['routeFrom']} → ${application['routeTo']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Application details
            _buildInfoRow(Icons.calendar_today, 'Applied', '${appliedAt.day}/${appliedAt.month}/${appliedAt.year}'),
            _buildInfoRow(Icons.confirmation_number, 'Application ID', application['applicationId'] ?? 'N/A'),
            _buildInfoRow(Icons.family_restroom, 'Guardian', application['guardianName'] ?? 'N/A'),

            if (application['familyIncome'] != null)
              _buildInfoRow(Icons.attach_money, 'Family Income', '₹${application['familyIncome']}'),

            SizedBox(height: 8),
            Text(
              'Reason: ${application['reason'] ?? 'No reason provided'}',
              style: TextStyle(color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Status-specific information
            if (status == 'approved') ...[
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Application Approved!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    if (application['adminComment'] != null) ...[
                      SizedBox(height: 4),
                      Text(
                        'Admin Comment: ${application['adminComment']}',
                        style: TextStyle(color: Colors.green[600]),
                      ),
                    ],
                    if (hasDigitalCard) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.credit_card, color: Colors.green[700], size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Digital concession card generated!',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ] else if (status == 'rejected') ...[
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red[700], size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Application Rejected',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    if (application['rejectionReason'] != null) ...[
                      SizedBox(height: 4),
                      Text(
                        'Reason: ${application['rejectionReason']}',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.orange[700], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Application under review by admin',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action buttons
            if (status == 'approved' && hasDigitalCard) ...[
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.credit_card),
                  label: Text('View Digital Card'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentDigitalCardScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                  ),
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