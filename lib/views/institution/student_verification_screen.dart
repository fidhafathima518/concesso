import 'package:flutter/material.dart';
import 'package:concessoapp/controllers/institution_controller.dart';
import 'package:concessoapp/services/shared_pref_service.dart';

class StudentVerificationScreen extends StatefulWidget {
  @override
  _StudentVerificationScreenState createState() => _StudentVerificationScreenState();
}

class _StudentVerificationScreenState extends State<StudentVerificationScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  List<Map<String, dynamic>> _pendingStudents = [];
  List<Map<String, dynamic>> _verifiedStudents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _loadData() async {
    setState(() {
      _isLoading = true;
    });

    String institutionId = SharedPrefService.getUserId();

    List<Map<String, dynamic>> pending = await InstitutionController.getPendingStudents(institutionId);
    List<Map<String, dynamic>> verified = await InstitutionController.getVerifiedStudents(institutionId);

    setState(() {
      _pendingStudents = pending;
      _verifiedStudents = verified;
      _isLoading = false;
    });
  }

  _verifyStudent(String studentId, String studentName) async {
    bool? confirm = await _showConfirmationDialog(
      'Verify Student',
      'Are you sure you want to verify "$studentName"?\n\nThis will allow them to apply for bus concession cards.',
    );

    if (confirm == true) {
      Map<String, dynamic> result = await InstitutionController.verifyStudent(studentId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

      if (result['success']) {
        _loadData(); // Refresh data
      }
    }
  }

  _rejectStudent(String studentId, String studentName) async {
    String? reason = await _showRejectDialog(studentName);

    if (reason != null && reason.isNotEmpty) {
      Map<String, dynamic> result = await InstitutionController.rejectStudent(studentId, reason);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.orange : Colors.red,
        ),
      );

      if (result['success']) {
        _loadData(); // Refresh data
      }
    }
  }

  Future<bool?> _showConfirmationDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Verify', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<String?> _showRejectDialog(String studentName) {
    TextEditingController reasonController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Student Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Provide reason for rejecting "$studentName":'),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Verification'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'Pending (${_pendingStudents.length})',
              icon: Icon(Icons.pending_actions),
            ),
            Tab(
              text: 'Verified (${_verifiedStudents.length})',
              icon: Icon(Icons.verified),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(),
          _buildVerifiedTab(),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_pendingStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Pending Students',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'All students have been verified',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _pendingStudents.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> student = _pendingStudents[index];
        return _buildStudentCard(student, isPending: true);
      },
    );
  }

  Widget _buildVerifiedTab() {
    if (_verifiedStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Verified Students',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Verify students from pending tab',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _verifiedStudents.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> student = _verifiedStudents[index];
        return _buildStudentCard(student, isPending: false);
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, {required bool isPending}) {
    DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(student['createdAt'] ?? 0);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: isPending ? Colors.orange : Colors.green,
                  size: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    student['name'] ?? 'Unknown Student',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPending ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPending ? 'PENDING' : 'VERIFIED',
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

            _buildInfoRow('Student ID', student['studentId'] ?? 'N/A'),
            _buildInfoRow('Course', student['course'] ?? 'N/A'),
            _buildInfoRow('Email', student['email'] ?? 'N/A'),
            _buildInfoRow('Phone', student['phone'] ?? 'N/A'),
            _buildInfoRow('Address', student['address'] ?? 'N/A'),
            _buildInfoRow('Registered', '${createdAt.day}/${createdAt.month}/${createdAt.year}'),

            if (isPending) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _verifyStudent(student['id'], student['name']),
                      icon: Icon(Icons.check, color: Colors.white),
                      label: Text('Verify', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectStudent(student['id'], student['name']),
                      icon: Icon(Icons.close, color: Colors.white),
                      label: Text('Reject', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}