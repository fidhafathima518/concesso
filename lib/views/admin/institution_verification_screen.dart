// controllers/admin_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concessoapp/services/shared_pref_service.dart';
import 'package:flutter/material.dart';

class AdminController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get pending institutions for verification
  static Future<List<Map<String, dynamic>>> getPendingInstitutions() async {
    try {
      print("🔵 Fetching pending institutions...");

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'institution')
          .where('isVerified', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> institutions = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Ensure ID is included
        return data;
      }).toList();

      print("✅ Found ${institutions.length} pending institutions");
      return institutions;

    } catch (e) {
      print("❌ Error fetching pending institutions: $e");
      return [];
    }
  }

  // Get verified institutions
  static Future<List<Map<String, dynamic>>> getVerifiedInstitutions() async {
    try {
      print("🔵 Fetching verified institutions...");

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'institution')
          .where('isVerified', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> institutions = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      print("✅ Found ${institutions.length} verified institutions");
      return institutions;

    } catch (e) {
      print("❌ Error fetching verified institutions: $e");
      return [];
    }
  }

  // Verify institution
  static Future<Map<String, dynamic>> verifyInstitution(String institutionId) async {
    try {
      print("🔵 Verifying institution: $institutionId");

      await _firestore.collection('users').doc(institutionId).update({
        'isVerified': true,
        'verifiedAt': DateTime.now().millisecondsSinceEpoch,
        'verifiedBy': SharedPrefService.getUserId(),
      });

      print("✅ Institution verified successfully");
      return {
        'success': true,
        'message': 'Institution verified successfully',
      };

    } catch (e) {
      print("❌ Error verifying institution: $e");
      return {
        'success': false,
        'message': 'Failed to verify institution',
      };
    }
  }

  // Reject institution
  static Future<Map<String, dynamic>> rejectInstitution(String institutionId, String reason) async {
    try {
      print("🔵 Rejecting institution: $institutionId");

      await _firestore.collection('users').doc(institutionId).update({
        'isRejected': true,
        'rejectionReason': reason,
        'rejectedAt': DateTime.now().millisecondsSinceEpoch,
        'rejectedBy': SharedPrefService.getUserId(),
      });

      print("✅ Institution rejected successfully");
      return {
        'success': true,
        'message': 'Institution rejected successfully',
      };

    } catch (e) {
      print("❌ Error rejecting institution: $e");
      return {
        'success': false,
        'message': 'Failed to reject institution',
      };
    }
  }

  // Get pending students for verification (by institution)
  static Future<List<Map<String, dynamic>>> getPendingStudents() async {
    try {
      print("🔵 Fetching pending students...");

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('isVerified', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> students = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      print("✅ Found ${students.length} pending students");
      return students;

    } catch (e) {
      print("❌ Error fetching pending students: $e");
      return [];
    }
  }
}



class InstitutionVerificationScreen extends StatefulWidget {
  @override
  _InstitutionVerificationScreenState createState() => _InstitutionVerificationScreenState();
}

class _InstitutionVerificationScreenState extends State<InstitutionVerificationScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  List<Map<String, dynamic>> _pendingInstitutions = [];
  List<Map<String, dynamic>> _verifiedInstitutions = [];
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

    // Load both pending and verified institutions
    List<Map<String, dynamic>> pending = await AdminController.getPendingInstitutions();
    List<Map<String, dynamic>> verified = await AdminController.getVerifiedInstitutions();

    setState(() {
      _pendingInstitutions = pending;
      _verifiedInstitutions = verified;
      _isLoading = false;
    });
  }

  _verifyInstitution(String institutionId, String institutionName) async {
    // Show confirmation dialog
    bool? confirm = await _showConfirmationDialog(
      'Verify Institution',
      'Are you sure you want to verify "$institutionName"?',
    );

    if (confirm == true) {
      Map<String, dynamic> result = await AdminController.verifyInstitution(institutionId);

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

  _rejectInstitution(String institutionId, String institutionName) async {
    String? reason = await _showRejectDialog(institutionName);

    if (reason != null && reason.isNotEmpty) {
      Map<String, dynamic> result = await AdminController.rejectInstitution(institutionId, reason);

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
            child: Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<String?> _showRejectDialog(String institutionName) {
    TextEditingController reasonController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Institution'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Provide reason for rejecting "$institutionName":'),
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
        title: Text('Institution Verification'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'Pending (${_pendingInstitutions.length})',
              icon: Icon(Icons.pending_actions),
            ),
            Tab(
              text: 'Verified (${_verifiedInstitutions.length})',
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
    if (_pendingInstitutions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Pending Institutions',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'All institutions have been processed',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _pendingInstitutions.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> institution = _pendingInstitutions[index];
        return _buildInstitutionCard(institution, isPending: true);
      },
    );
  }

  Widget _buildVerifiedTab() {
    if (_verifiedInstitutions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Verified Institutions',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Verify institutions from pending tab',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _verifiedInstitutions.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> institution = _verifiedInstitutions[index];
        return _buildInstitutionCard(institution, isPending: false);
      },
    );
  }

  Widget _buildInstitutionCard(Map<String, dynamic> institution, {required bool isPending}) {
    DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(institution['createdAt'] ?? 0);

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
                  Icons.business,
                  color: isPending ? Colors.orange : Colors.green,
                  size: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    institution['name'] ?? 'Unknown Institution',
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

            _buildInfoRow('Code', institution['institutionCode'] ?? 'N/A'),
            _buildInfoRow('Type', institution['institutionType'] ?? 'N/A'),
            _buildInfoRow('Principal', institution['principalName'] ?? 'N/A'),
            _buildInfoRow('Email', institution['email'] ?? 'N/A'),
            _buildInfoRow('Phone', institution['phone'] ?? 'N/A'),
            _buildInfoRow('Address', institution['address'] ?? 'N/A'),
            _buildInfoRow('Applied', '${createdAt.day}/${createdAt.month}/${createdAt.year}'),

            if (isPending) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _verifyInstitution(institution['id'], institution['name']),
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
                      onPressed: () => _rejectInstitution(institution['id'], institution['name']),
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
