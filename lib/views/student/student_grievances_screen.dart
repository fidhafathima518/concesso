import 'package:flutter/material.dart';

import '../../controllers/student_controller.dart';
import '../../services/shared_pref_service.dart';
import 'grievance_submission_screen.dart';

class StudentGrievancesScreen extends StatefulWidget {
  @override
  _StudentGrievancesScreenState createState() => _StudentGrievancesScreenState();
}

class _StudentGrievancesScreenState extends State<StudentGrievancesScreen> {
  List<Map<String, dynamic>> _grievances = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGrievances();
  }

  _loadGrievances() async {
    setState(() {
      _isLoading = true;
    });

    String studentId = SharedPrefService.getUserId();
    List<Map<String, dynamic>> grievances = await StudentController.getStudentGrievances(studentId);

    setState(() {
      _grievances = grievances;
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'open':
      default:
        return Colors.orange;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Grievances'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadGrievances,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _grievances.isEmpty
          ? _buildEmptyState()
          : _buildGrievancesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GrievanceSubmissionScreen(),
            ),
          ).then((_) => _loadGrievances());
        },
        backgroundColor: Colors.orange[700],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No Grievances Submitted',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Submit a grievance if you have any concerns or issues',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GrievanceSubmissionScreen(),
                  ),
                ).then((_) => _loadGrievances());
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text('Submit Grievance', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrievancesList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _grievances.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> grievance = _grievances[index];
        return _buildGrievanceCard(grievance);
      },
    );
  }

  Widget _buildGrievanceCard(Map<String, dynamic> grievance) {
    DateTime submittedAt = DateTime.fromMillisecondsSinceEpoch(grievance['submittedAt'] ?? 0);
    String status = grievance['status'] ?? 'open';
    String priority = grievance['priority'] ?? 'medium';
    Color statusColor = _getStatusColor(status);
    Color priorityColor = _getPriorityColor(priority);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: InkWell(
        onTap: () => _showGrievanceDetails(grievance),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: priorityColor,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      grievance['subject'] ?? 'No Subject',
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
                    child: Text(
                      status.toUpperCase().replaceAll('_', ' '),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    grievance['category'] ?? 'General',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.flag, size: 16, color: priorityColor),
                  SizedBox(width: 4),
                  Text(
                    '${priority.toUpperCase()} Priority',
                    style: TextStyle(color: priorityColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 8),

              Text(
                grievance['description'] ?? 'No description provided',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Submitted: ${submittedAt.day}/${submittedAt.month}/${submittedAt.year}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  TextButton(
                    onPressed: () => _showGrievanceDetails(grievance),
                    child: Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGrievanceDetails(Map<String, dynamic> grievance) {
    DateTime submittedAt = DateTime.fromMillisecondsSinceEpoch(grievance['submittedAt'] ?? 0);
    String status = grievance['status'] ?? 'open';
    String priority = grievance['priority'] ?? 'medium';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Grievance Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Grievance ID', grievance['grievanceId'] ?? 'N/A'),
              _buildDetailRow('Subject', grievance['subject'] ?? 'N/A'),
              _buildDetailRow('Category', grievance['category'] ?? 'N/A'),
              _buildDetailRow('Priority', priority.toUpperCase()),
              _buildDetailRow('Status', status.toUpperCase().replaceAll('_', ' ')),
              _buildDetailRow('Submitted', '${submittedAt.day}/${submittedAt.month}/${submittedAt.year}'),
              SizedBox(height: 8),
              Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(grievance['description'] ?? 'No description provided'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}