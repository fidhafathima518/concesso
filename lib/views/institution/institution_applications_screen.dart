// views/institution/institution_applications_screen.dart - Enhanced with Document Viewer
import 'package:flutter/material.dart';
import 'package:concessoapp/controllers/institution_controller.dart';
import 'package:concessoapp/services/shared_pref_service.dart';
import 'package:url_launcher/url_launcher.dart';

class InstitutionApplicationsScreen extends StatefulWidget {
  @override
  _InstitutionApplicationsScreenState createState() => _InstitutionApplicationsScreenState();
}

class _InstitutionApplicationsScreenState extends State<InstitutionApplicationsScreen> {
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = false;
  String _selectedFilter = 'all'; // all, pending, approved, rejected

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  _loadApplications() async {
    setState(() {
      _isLoading = true;
    });

    String institutionId = SharedPrefService.getUserId();
    List<Map<String, dynamic>> applications = await InstitutionController.getStudentBusApplications(institutionId);

    setState(() {
      _applications = applications;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredApplications {
    if (_selectedFilter == 'all') {
      return _applications;
    }
    return _applications.where((app) => app['status'] == _selectedFilter).toList();
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

  // Function to launch URL in browser
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open document')),
      );
    }
  }

  // Function to show image in fullscreen
  void _showImageViewer(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.white, size: 64),
                            SizedBox(height: 16),
                            Text(
                              'Could not load image',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _launchURL(imageUrl),
                              child: Text('Open in Browser'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.open_in_browser, color: Colors.white),
                    onPressed: () => _launchURL(imageUrl),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Applications'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadApplications,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        SizedBox(width: 8),
                        _buildFilterChip('Pending', 'pending'),
                        SizedBox(width: 8),
                        _buildFilterChip('Approved', 'approved'),
                        SizedBox(width: 8),
                        _buildFilterChip('Rejected', 'rejected'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Applications List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredApplications.isEmpty
                ? _buildEmptyState()
                : _buildApplicationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _selectedFilter == value;
    int count = value == 'all'
        ? _applications.length
        : _applications.where((app) => app['status'] == value).length;

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: Colors.green[100],
      checkmarkColor: Colors.green[700],
    );
  }

  Widget _buildEmptyState() {
    String message = _selectedFilter == 'all'
        ? 'No applications from your students yet'
        : 'No ${_selectedFilter} applications found';

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
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Applications will appear here once your verified students apply for bus cards',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredApplications.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> application = _filteredApplications[index];
        return _buildApplicationCard(application);
      },
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    DateTime appliedAt = DateTime.fromMillisecondsSinceEpoch(application['appliedAt'] ?? 0);
    String status = application['status'] ?? 'pending';
    Color statusColor = _getStatusColor(status);
    IconData statusIcon = _getStatusIcon(status);
    List<dynamic> documents = application['documents'] ?? [];

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: InkWell(
        onTap: () => _showApplicationDetails(application),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: Colors.green[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      application['studentName'] ?? 'Unknown Student',
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

              Row(
                children: [
                  Icon(Icons.directions_bus, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${application['routeFrom']} → ${application['routeTo']}',
                      style: TextStyle(fontWeight: FontWeight.w600),
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
                    'Applied: ${appliedAt.day}/${appliedAt.month}/${appliedAt.year}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 4),

              Row(
                children: [
                  Icon(Icons.book, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'Course: ${application['course'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),

              // Show documents preview
              if (documents.isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_file, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      '${documents.length} document(s) uploaded',
                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: documents.length > 3 ? 3 : documents.length, // Show max 3 previews
                    itemBuilder: (context, docIndex) {
                      String docUrl = documents[docIndex];
                      return GestureDetector(
                        onTap: () => _showImageViewer(docUrl, 'Document ${docIndex + 1}'),
                        child: Container(
                          width: 60,
                          height: 60,
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              docUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.description,
                                    color: Colors.grey[600],
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (documents.length > 3)
                  Text(
                    '+${documents.length - 3} more documents',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],

              SizedBox(height: 8),
              Text(
                application['reason'] ?? 'No reason provided',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showApplicationDetails(application),
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

  void _showApplicationDetails(Map<String, dynamic> application) {
    DateTime appliedAt = DateTime.fromMillisecondsSinceEpoch(application['appliedAt'] ?? 0);
    String status = application['status'] ?? 'pending';
    List<dynamic> documents = application['documents'] ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Application Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Student Name', application['studentName'] ?? 'N/A'),
              _buildDetailRow('Student Email', application['studentEmail'] ?? 'N/A'),
              _buildDetailRow('Course', application['course'] ?? 'N/A'),
              _buildDetailRow('Application ID', application['applicationId'] ?? 'N/A'),
              _buildDetailRow('Route', '${application['routeFrom']} → ${application['routeTo']}'),
              _buildDetailRow('Status', status.toUpperCase()),
              _buildDetailRow('Applied Date', '${appliedAt.day}/${appliedAt.month}/${appliedAt.year}'),
              _buildDetailRow('Guardian Name', application['guardianName'] ?? 'N/A'),
              _buildDetailRow('Guardian Phone', application['guardianPhone'] ?? 'N/A'),
              _buildDetailRow('Family Income', '₹${application['familyIncome'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text(
                'Reason:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(application['reason'] ?? 'No reason provided'),

              if (documents.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  'Uploaded Documents (${documents.length}):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...documents.asMap().entries.map((entry) {
                  int index = entry.key;
                  String docUrl = entry.value;
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              docUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.description,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Document ${index + 1}',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showImageViewer(docUrl, 'Document ${index + 1}');
                                    },
                                    icon: Icon(Icons.visibility, size: 16),
                                    label: Text('View'),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size(0, 0),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _launchURL(docUrl),
                                    icon: Icon(Icons.open_in_browser, size: 16),
                                    label: Text('Open'),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size(0, 0),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
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