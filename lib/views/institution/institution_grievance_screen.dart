// views/institution/institution_grievance_screen.dart
import 'package:flutter/material.dart';
import 'package:concessoapp/controllers/grievance_controller.dart';
import 'package:concessoapp/services/shared_pref_service.dart';

class InstitutionGrievanceScreen extends StatefulWidget {
  @override
  _InstitutionGrievanceScreenState createState() => _InstitutionGrievanceScreenState();
}

class _InstitutionGrievanceScreenState extends State<InstitutionGrievanceScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  List<Map<String, dynamic>> _allGrievances = [];
  List<Map<String, dynamic>> _openGrievances = [];
  List<Map<String, dynamic>> _inProgressGrievances = [];
  List<Map<String, dynamic>> _resolvedGrievances = [];
  bool _isLoading = false;
  Map<String, int> _statistics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadGrievances();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _loadGrievances() async {
    setState(() {
      _isLoading = true;
    });

    String institutionId = SharedPrefService.getUserId();

    // Load grievances and statistics
    List<Map<String, dynamic>> grievances = await GrievanceController.getInstitutionGrievances(institutionId);
    Map<String, int> stats = await GrievanceController.getInstitutionGrievanceStats(institutionId);

    setState(() {
      _allGrievances = grievances;
      _openGrievances = grievances.where((g) => g['status'] == 'open').toList();
      _inProgressGrievances = grievances.where((g) => g['status'] == 'in_progress').toList();
      _resolvedGrievances = grievances.where((g) => g['status'] == 'resolved' || g['status'] == 'closed').toList();
      _statistics = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grievance Management'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'Open (${_openGrievances.length})',
              icon: Icon(Icons.new_releases, size: 16),
            ),
            Tab(
              text: 'In Progress (${_inProgressGrievances.length})',
              icon: Icon(Icons.pending_actions, size: 16),
            ),
            Tab(
              text: 'Resolved (${_resolvedGrievances.length})',
              icon: Icon(Icons.check_circle, size: 16),
            ),
            Tab(
              text: 'Statistics',
              icon: Icon(Icons.analytics, size: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadGrievances,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildGrievanceList(_openGrievances, 'open'),
          _buildGrievanceList(_inProgressGrievances, 'in_progress'),
          _buildGrievanceList(_resolvedGrievances, 'resolved'),
          _buildStatisticsView(),
        ],
      ),
    );
  }

  Widget _buildGrievanceList(List<Map<String, dynamic>> grievances, String status) {
    if (grievances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'open' ? Icons.assignment_outlined :
              status == 'in_progress' ? Icons.pending_actions :
              Icons.check_circle_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No ${status.replaceAll('_', ' ')} grievances',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: grievances.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> grievance = grievances[index];
        return _buildGrievanceCard(grievance);
      },
    );
  }

  Widget _buildGrievanceCard(Map<String, dynamic> grievance) {
    DateTime submittedAt = DateTime.fromMillisecondsSinceEpoch(grievance['submittedAt'] ?? 0);
    String status = grievance['status'] ?? 'open';
    String priority = grievance['priority'] ?? 'Medium';
    String category = grievance['category'] ?? 'Other';

    Color statusColor = _getStatusColor(status);
    Color priorityColor = _getPriorityColor(priority);
    Color categoryColor = _getCategoryColor(category);

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
              // Header
              Row(
                children: [
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
              SizedBox(height: 12),

              // Student Info
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'Student: ${grievance['studentName'] ?? 'Unknown'}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 4),

              // Category and Priority
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
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$priority Priority',
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Description Preview
              Text(
                grievance['description'] ?? 'No description',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 8),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        'Submitted: ${submittedAt.day}/${submittedAt.month}/${submittedAt.year}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  if (status == 'open' || status == 'in_progress')
                    ElevatedButton(
                      onPressed: () => _showResponseDialog(grievance),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: Text('Respond', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsView() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grievance Statistics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),

          // Status Statistics
          Text(
            'By Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total', _statistics['total'] ?? 0, Colors.blue)),
              SizedBox(width: 12),
              Expanded(child: _buildStatCard('Open', _statistics['open'] ?? 0, Colors.orange)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('In Progress', _statistics['in_progress'] ?? 0, Colors.purple)),
              SizedBox(width: 12),
              Expanded(child: _buildStatCard('Resolved', _statistics['resolved'] ?? 0, Colors.green)),
            ],
          ),
          SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.assignment, color: Colors.green[700]),
          title: Text('View All Grievances'),
          subtitle: Text('See complete list of all grievances'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            _tabController.animateTo(0);
          },
        ),
        ListTile(
          leading: Icon(Icons.analytics, color: Colors.blue[700]),
          title: Text('Export Report'),
          subtitle: Text('Download grievance report'),
          trailing: Icon(Icons.download),
          onTap: () {
            _showSnackBar('Export feature coming soon', Colors.blue);
          },
        ),
      ],
    );
  }

  void _showGrievanceDetails(Map<String, dynamic> grievance) {
    DateTime submittedAt = DateTime.fromMillisecondsSinceEpoch(grievance['submittedAt'] ?? 0);

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
              _buildDetailRow('Student', grievance['studentName'] ?? 'N/A'),
              _buildDetailRow('Email', grievance['studentEmail'] ?? 'N/A'),
              _buildDetailRow('Phone', grievance['studentPhone'] ?? 'N/A'),
              _buildDetailRow('Category', grievance['category'] ?? 'N/A'),
              _buildDetailRow('Priority', grievance['priority'] ?? 'N/A'),
              _buildDetailRow('Status', grievance['status'] ?? 'N/A'),
              _buildDetailRow('Submitted', '${submittedAt.day}/${submittedAt.month}/${submittedAt.year}'),
              SizedBox(height: 8),
              Text(
                'Subject:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(grievance['subject'] ?? 'No subject'),
              SizedBox(height: 8),
              Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(grievance['description'] ?? 'No description'),

              if (grievance['institutionResponse'] != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Institution Response:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(grievance['institutionResponse']),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (grievance['status'] == 'open' || grievance['status'] == 'in_progress')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showResponseDialog(grievance);
              },
              child: Text('Respond'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showResponseDialog(Map<String, dynamic> grievance) {
    TextEditingController responseController = TextEditingController();
    String selectedStatus = grievance['status'] == 'open' ? 'in_progress' : 'resolved';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Respond to Grievance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Subject: ${grievance['subject']}'),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: InputDecoration(
                labelText: 'Update Status',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'in_progress', child: Text('Mark as In Progress')),
                DropdownMenuItem(value: 'resolved', child: Text('Mark as Resolved')),
              ],
              onChanged: (value) {
                selectedStatus = value!;
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: responseController,
              decoration: InputDecoration(
                labelText: 'Your Response',
                border: OutlineInputBorder(),
                hintText: 'Enter your response to the student...',
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (responseController.text.trim().isEmpty) {
                _showSnackBar('Please enter a response', Colors.red);
                return;
              }

              Navigator.pop(context);

              Map<String, dynamic> result = await GrievanceController.updateGrievanceByInstitution(
                grievanceId: grievance['id'],
                status: selectedStatus,
                response: responseController.text.trim(),
              );

              if (result['success']) {
                _showSnackBar('Grievance updated successfully', Colors.green);
                _loadGrievances();
              } else {
                _showSnackBar(result['message'], Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: Text('Submit Response', style: TextStyle(color: Colors.white)),
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
            width: 80,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'closed':
        return Colors.green;
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
        return Colors.blue;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'academic':
        return Colors.purple;
      case 'facilities':
        return Colors.teal;
      case 'administrative':
        return Colors.indigo;
      case 'transport':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}