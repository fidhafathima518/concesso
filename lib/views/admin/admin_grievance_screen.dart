// views/admin/admin_grievance_screen.dart
import 'package:flutter/material.dart';
import 'package:concessoapp/controllers/grievance_controller.dart';

class AdminGrievanceScreen extends StatefulWidget {
  @override
  _AdminGrievanceScreenState createState() => _AdminGrievanceScreenState();
}

class _AdminGrievanceScreenState extends State<AdminGrievanceScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  List<Map<String, dynamic>> _transportGrievances = [];
  List<Map<String, dynamic>> _allGrievances = [];
  bool _isLoading = false;
  Map<String, int> _statistics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

    // Load transport grievances assigned to admin
    List<Map<String, dynamic>> adminGrievances = await GrievanceController.getAdminGrievances();

    // Load all grievances for overview
    List<Map<String, dynamic>> allGrievances = await GrievanceController.getAllGrievancesForAdmin();

    // Load statistics
    Map<String, int> stats = await GrievanceController.getAdminGrievanceStats();

    setState(() {
      _transportGrievances = adminGrievances;
      _allGrievances = allGrievances;
      _statistics = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grievance Management'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'Transport (${_transportGrievances.length})',
              icon: Icon(Icons.directions_bus, size: 16),
            ),
            Tab(
              text: 'All Grievances (${_allGrievances.length})',
              icon: Icon(Icons.list, size: 16),
            ),
            Tab(
              text: 'Analytics',
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
          _buildTransportGrievances(),
          _buildAllGrievancesView(),
          _buildAnalyticsView(),
        ],
      ),
    );
  }

  Widget _buildTransportGrievances() {
    List<Map<String, dynamic>> openGrievances = _transportGrievances
        .where((g) => g['status'] == 'open' || g['status'] == 'in_progress')
        .toList();
    List<Map<String, dynamic>> resolvedGrievances = _transportGrievances
        .where((g) => g['status'] == 'resolved' || g['status'] == 'closed')
        .toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.grey[100],
            child: TabBar(
              labelColor: Colors.red[700],
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.red[700],
              tabs: [
                Tab(text: 'Pending (${openGrievances.length})'),
                Tab(text: 'Resolved (${resolvedGrievances.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildGrievanceList(openGrievances, true),
                _buildGrievanceList(resolvedGrievances, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllGrievancesView() {
    Map<String, List<Map<String, dynamic>>> categorizedGrievances = {
      'Transport': _allGrievances.where((g) => g['category'] == 'Transport').toList(),
      'Academic': _allGrievances.where((g) => g['category'] == 'Academic').toList(),
      'Facilities': _allGrievances.where((g) => g['category'] == 'Facilities').toList(),
      'Administrative': _allGrievances.where((g) => g['category'] == 'Administrative').toList(),
      'Other': _allGrievances.where((g) => !['Transport', 'Academic', 'Facilities', 'Administrative'].contains(g['category'])).toList(),
    };

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Grievances by Category',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ...categorizedGrievances.entries.map((entry) {
          if (entry.value.isEmpty) return SizedBox.shrink();

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Row(
                children: [
                  Icon(_getCategoryIcon(entry.key), color: _getCategoryColor(entry.key)),
                  SizedBox(width: 8),
                  Text(
                    '${entry.key} (${entry.value.length})',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              children: entry.value.take(5).map((grievance) {
                return ListTile(
                  title: Text(
                    grievance['subject'] ?? 'No Subject',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('Student: ${grievance['studentName'] ?? 'Unknown'}'),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(grievance['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (grievance['status'] ?? 'open').toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () => _showGrievanceDetails(grievance, entry.key == 'Transport'),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAnalyticsView() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Grievance Analytics',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 24),

        // Overall Statistics
        Text(
          'Overall Statistics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Total Grievances', _statistics['total'] ?? 0, Colors.blue)),
            SizedBox(width: 12),
            Expanded(child: _buildStatCard('Open', _statistics['open'] ?? 0, Colors.orange)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Resolved', _statistics['resolved'] ?? 0, Colors.green)),
            SizedBox(width: 12),
            Expanded(child: _buildStatCard('Transport', _statistics['transport'] ?? 0, Colors.red)),
          ],
        ),
        SizedBox(height: 24),

        // Category Breakdown
        Text(
          'Category Breakdown',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        _buildCategoryBreakdown(),
        SizedBox(height: 24),

        // Performance Metrics
        Text(
          'Performance Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        _buildPerformanceMetrics(),
      ],
    );
  }

  Widget _buildGrievanceList(List<Map<String, dynamic>> grievances, bool canRespond) {
    if (grievances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              canRespond ? Icons.assignment_outlined : Icons.check_circle_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              canRespond ? 'No pending transport grievances' : 'No resolved grievances',
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
        return _buildTransportGrievanceCard(grievance, canRespond);
      },
    );
  }

  Widget _buildTransportGrievanceCard(Map<String, dynamic> grievance, bool canRespond) {
    DateTime submittedAt = DateTime.fromMillisecondsSinceEpoch(grievance['submittedAt'] ?? 0);
    String status = grievance['status'] ?? 'open';
    String priority = grievance['priority'] ?? 'Medium';

    Color statusColor = _getStatusColor(status);
    Color priorityColor = _getPriorityColor(priority);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: InkWell(
        onTap: () => _showGrievanceDetails(grievance, true),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.directions_bus, color: Colors.red[700]),
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
                  Spacer(),
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
                maxLines: 2,
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
                  if (canRespond)
                    ElevatedButton(
                      onPressed: () => _showResponseDialog(grievance),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
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

  Widget _buildCategoryBreakdown() {
    return Column(
      children: [
        _buildCategoryRow('Academic', _statistics['academic'] ?? 0, Colors.purple),
        _buildCategoryRow('Transport', _statistics['transport'] ?? 0, Colors.red),
        _buildCategoryRow('Facilities', _statistics['facilities'] ?? 0, Colors.teal),
        _buildCategoryRow('Administrative', _statistics['administrative'] ?? 0, Colors.indigo),
      ],
    );
  }

  Widget _buildCategoryRow(String category, int count, Color color) {
    int total = _statistics['total'] ?? 1;
    double percentage = total > 0 ? (count / total) * 100 : 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              category,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              color: color,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '$count (${percentage.toStringAsFixed(1)}%)',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.trending_up, color: Colors.green),
              title: Text('Resolution Rate'),
              subtitle: Text('Percentage of grievances resolved'),
              trailing: Text(
                '${_calculateResolutionRate()}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.schedule, color: Colors.orange),
              title: Text('Pending Grievances'),
              subtitle: Text('Grievances awaiting response'),
              trailing: Text(
                '${_statistics['open'] ?? 0}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
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
              textAlign: TextAlign.center,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showGrievanceDetails(Map<String, dynamic> grievance, bool isTransport) {
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
              _buildDetailRow('Category', grievance['category'] ?? 'N/A'),
              _buildDetailRow('Priority', grievance['priority'] ?? 'N/A'),
              _buildDetailRow('Status', grievance['status'] ?? 'N/A'),
              _buildDetailRow('Assigned To', grievance['assignedToType'] ?? 'N/A'),
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

              if (grievance['adminResponse'] != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Response:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(grievance['adminResponse']),
                    ],
                  ),
                ),
              ],

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
          if (isTransport && (grievance['status'] == 'open' || grievance['status'] == 'in_progress'))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showResponseDialog(grievance);
              },
              child: Text('Respond'),
            ),
          if (!isTransport && grievance['assignedToType'] == 'institution')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showReassignDialog(grievance);
              },
              child: Text('Reassign'),
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
        title: Text('Respond to Transport Grievance'),
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
                hintText: 'Enter your response to resolve this transport issue...',
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

              Map<String, dynamic> result = await GrievanceController.updateGrievanceByAdmin(
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: Text('Submit Response', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReassignDialog(Map<String, dynamic> grievance) {
    TextEditingController reasonController = TextEditingController();
    String selectedAssignee = 'institution';
    String selectedInstitution = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Reassign Grievance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Subject: ${grievance['subject']}'),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedAssignee,
                decoration: InputDecoration(
                  labelText: 'Reassign To',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'institution', child: Text('Institution')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin (Transport)')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedAssignee = value!;
                  });
                },
              ),
              if (selectedAssignee == 'institution') ...[
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) => selectedInstitution = value,
                  decoration: InputDecoration(
                    labelText: 'Institution ID',
                    border: OutlineInputBorder(),
                    hintText: 'Enter institution ID',
                  ),
                ),
              ],
              SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Reason for Reassignment',
                  border: OutlineInputBorder(),
                  hintText: 'Enter reason for reassigning this grievance...',
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
              onPressed: () async {
                if (reasonController.text.trim().isEmpty) {
                  _showSnackBar('Please enter a reason', Colors.red);
                  return;
                }

                if (selectedAssignee == 'institution' && selectedInstitution.trim().isEmpty) {
                  _showSnackBar('Please enter institution ID', Colors.red);
                  return;
                }

                Navigator.pop(context);

                String newAssignedTo = selectedAssignee == 'admin' ? 'admin' : selectedInstitution;

                Map<String, dynamic> result = await GrievanceController.reassignGrievance(
                  grievanceId: grievance['id'],
                  newAssignedTo: newAssignedTo,
                  newAssignedToType: selectedAssignee,
                  reason: reasonController.text.trim(),
                );

                if (result['success']) {
                  _showSnackBar('Grievance reassigned successfully', Colors.green);
                  _loadGrievances();
                } else {
                  _showSnackBar(result['message'], Colors.red);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text('Reassign', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'open':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return Icons.directions_bus;
      case 'academic':
        return Icons.school;
      case 'facilities':
        return Icons.business;
      case 'administrative':
        return Icons.admin_panel_settings;
      default:
        return Icons.help_outline;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return Colors.red;
      case 'academic':
        return Colors.purple;
      case 'facilities':
        return Colors.teal;
      case 'administrative':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  int _calculateResolutionRate() {
    int total = _statistics['total'] ?? 0;
    int resolved = _statistics['resolved'] ?? 0;

    if (total == 0) return 0;
    return ((resolved / total) * 100).round();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }
}