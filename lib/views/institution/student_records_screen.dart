// views/institution/student_records_screen.dart - Fixed version
import 'package:flutter/material.dart';
import 'package:concessoapp/controllers/institution_controller.dart';
import 'package:concessoapp/services/shared_pref_service.dart';

class StudentRecordsScreen extends StatefulWidget {
  @override
  _StudentRecordsScreenState createState() => _StudentRecordsScreenState();
}

class _StudentRecordsScreenState extends State<StudentRecordsScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  List<Map<String, dynamic>> _verifiedStudents = [];
  List<Map<String, dynamic>> _pendingStudents = [];
  List<Map<String, dynamic>> _allStudents = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStudentRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _loadStudentRecords() async {
    setState(() {
      _isLoading = true;
    });

    String institutionId = SharedPrefService.getUserId();

    List<Map<String, dynamic>> verified = await InstitutionController.getVerifiedStudents(institutionId);
    List<Map<String, dynamic>> pending = await InstitutionController.getPendingStudents(institutionId);

    setState(() {
      _verifiedStudents = verified;
      _pendingStudents = pending;
      _allStudents = [...verified, ...pending];
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getFilteredStudents(List<Map<String, dynamic>> students) {
    if (_searchQuery.isEmpty) {
      return students;
    }

    return students.where((student) {
      String name = student['name']?.toLowerCase() ?? '';
      String email = student['email']?.toLowerCase() ?? '';
      String studentId = student['studentId']?.toLowerCase() ?? '';
      String course = student['course']?.toLowerCase() ?? '';
      String query = _searchQuery.toLowerCase();

      return name.contains(query) ||
          email.contains(query) ||
          studentId.contains(query) ||
          course.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Records'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'All (${_allStudents.length})',
              icon: Icon(Icons.people),
            ),
            Tab(
              text: 'Verified (${_verifiedStudents.length})',
              icon: Icon(Icons.verified),
            ),
            Tab(
              text: 'Pending (${_pendingStudents.length})',
              icon: Icon(Icons.pending_actions),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadStudentRecords,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search students by name, email, ID, or course...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Student Lists
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: [
                _buildStudentList(_getFilteredStudents(_allStudents), 'all'),
                _buildStudentList(_getFilteredStudents(_verifiedStudents), 'verified'),
                _buildStudentList(_getFilteredStudents(_pendingStudents), 'pending'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(List<Map<String, dynamic>> students, String type) {
    if (students.isEmpty) {
      String message = _searchQuery.isNotEmpty
          ? 'No students found matching "$_searchQuery"'
          : type == 'all'
          ? 'No students registered yet'
          : type == 'verified'
          ? 'No verified students'
          : 'No pending students';

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: Text('Clear Search'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> student = students[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(student['createdAt'] ?? 0);
    bool isVerified = student['isVerified'] ?? false;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showStudentDetails(student),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isVerified ? Colors.green[100] : Colors.orange[100],
                    child: Icon(
                      Icons.person,
                      color: isVerified ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['name'] ?? 'Unknown Student',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${student['studentId'] ?? 'N/A'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isVerified ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isVerified ? 'VERIFIED' : 'PENDING',
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

              Row(
                children: [
                  Icon(Icons.book, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      student['course'] ?? 'Course not specified',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),

              Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      student['email'] ?? 'Email not provided',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),

              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'Registered: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentDetails(Map<String, dynamic> student) {
    DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(student['createdAt'] ?? 0);
    bool isVerified = student['isVerified'] ?? false;

    // Create the list of widgets properly
    List<Widget> detailWidgets = [
      _buildDetailRow('Name', student['name'] ?? 'N/A'),
      _buildDetailRow('Student ID', student['studentId'] ?? 'N/A'),
      _buildDetailRow('Course', student['course'] ?? 'N/A'),
      _buildDetailRow('Email', student['email'] ?? 'N/A'),
      _buildDetailRow('Phone', student['phone'] ?? 'N/A'),
      _buildDetailRow('Address', student['address'] ?? 'N/A'),
      _buildDetailRow('Status', isVerified ? 'Verified' : 'Pending Verification'),
      _buildDetailRow('Registered', '${createdAt.day}/${createdAt.month}/${createdAt.year}'),
    ];

    // Add verification date if student is verified
    if (isVerified && student['verifiedAt'] != null) {
      DateTime verifiedAt = DateTime.fromMillisecondsSinceEpoch(student['verifiedAt']);
      detailWidgets.addAll([
        SizedBox(height: 8),
        _buildDetailRow('Verified On', '${verifiedAt.day}/${verifiedAt.month}/${verifiedAt.year}'),
      ]);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Student Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: detailWidgets, // Now this is properly a list of widgets
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