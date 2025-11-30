// views/admin/admin_announcements_screen.dart
import 'package:flutter/material.dart';
import 'package:concessoapp/controllers/announcement_controller.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  @override
  _AdminAnnouncementsScreenState createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  List<Map<String, dynamic>> _allAnnouncements = [];
  List<Map<String, dynamic>> _activeAnnouncements = [];
  List<Map<String, dynamic>> _inactiveAnnouncements = [];
  List<Map<String, dynamic>> _expiredAnnouncements = [];
  bool _isLoading = false;
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnnouncements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
    });

    // Load announcements and statistics
    List<Map<String, dynamic>> announcements = await AnnouncementController.getAllAnnouncements();
    Map<String, dynamic> stats = await AnnouncementController.getAnnouncementStats();

    setState(() {
      _allAnnouncements = announcements;
      _activeAnnouncements = announcements.where((a) =>
      (a['isActive'] ?? true) && !(a['isExpired'] ?? false)).toList();
      _inactiveAnnouncements = announcements.where((a) =>
      !(a['isActive'] ?? true) && !(a['isExpired'] ?? false)).toList();
      _expiredAnnouncements = announcements.where((a) =>
      a['isExpired'] ?? false).toList();
      _statistics = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcement Management'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'Active (${_activeAnnouncements.length})',
              icon: Icon(Icons.notifications_active, size: 16),
            ),
            Tab(
              text: 'Inactive (${_inactiveAnnouncements.length})',
              icon: Icon(Icons.notifications_off, size: 16),
            ),
            Tab(
              text: 'Expired (${_expiredAnnouncements.length})',
              icon: Icon(Icons.schedule, size: 16),
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
            onPressed: _loadAnnouncements,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildAnnouncementList(_activeAnnouncements, 'active'),
          _buildAnnouncementList(_inactiveAnnouncements, 'inactive'),
          _buildAnnouncementList(_expiredAnnouncements, 'expired'),
          _buildStatisticsView(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAnnouncementDialog(),
        backgroundColor: Colors.purple[700],
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('New Announcement', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAnnouncementList(List<Map<String, dynamic>> announcements, String status) {
    if (announcements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'active' ? Icons.notifications_active :
              status == 'inactive' ? Icons.notifications_off :
              Icons.schedule,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No $status announcements',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> announcement = announcements[index];
        return _buildAnnouncementCard(announcement);
      },
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(announcement['createdAt'] ?? 0);
    String category = announcement['category'] ?? 'General';
    String priority = announcement['priority'] ?? 'Normal';
    String targetAudience = announcement['targetAudience'] ?? 'All';
    bool isActive = announcement['isActive'] ?? true;
    bool isExpired = announcement['isExpired'] ?? false;

    Color categoryColor = _getCategoryColor(category);
    Color priorityColor = _getPriorityColor(priority);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: InkWell(
        onTap: () => _showAnnouncementDetails(announcement),
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
                      announcement['title'] ?? 'No Title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpired ? Colors.grey : (isActive ? Colors.green : Colors.orange),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isExpired ? 'EXPIRED' : (isActive ? 'ACTIVE' : 'INACTIVE'),
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

              // Category, Priority, and Target
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
                      priority,
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      targetAudience,
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Content Preview
              Text(
                announcement['content'] ?? 'No content',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 8),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            'Created: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.visibility, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            'Views: ${announcement['viewCount'] ?? 0}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showEditAnnouncementDialog(announcement),
                        icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                      ),
                      IconButton(
                        onPressed: () => _toggleAnnouncementStatus(announcement),
                        icon: Icon(
                          isActive ? Icons.pause_circle : Icons.play_circle,
                          color: isActive ? Colors.orange : Colors.green,
                          size: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _deleteAnnouncement(announcement),
                        icon: Icon(Icons.delete, color: Colors.red, size: 20),
                      ),
                    ],
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Announcement Statistics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),

            // Overview Statistics
            Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('Total', _statistics['total'] ?? 0, Colors.blue)),
                SizedBox(width: 12),
                Expanded(child: _buildStatCard('Active', _statistics['active'] ?? 0, Colors.green)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('Inactive', _statistics['inactive'] ?? 0, Colors.orange)),
                SizedBox(width: 12),
                Expanded(child: _buildStatCard('Expired', _statistics['expired'] ?? 0, Colors.grey)),
              ],
            ),
            SizedBox(height: 24),

            // Category Statistics
            Text(
              'By Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            _buildCategoryStats(),
            SizedBox(height: 24),

            // Priority Statistics
            Text(
              'By Priority',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            _buildPriorityStats(),
            SizedBox(height: 24),

            // Total Views
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.visibility, color: Colors.purple[700], size: 24),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Views',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_statistics['totalViews'] ?? 0}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                  ],
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

  Widget _buildCategoryStats() {
    Map<String, int> categoryStats = Map<String, int>.from(_statistics['byCategory'] ?? {});

    if (categoryStats.isEmpty) {
      return Text('No category data available');
    }

    return Column(
      children: categoryStats.entries.map((entry) {
        Color color = _getCategoryColor(entry.key);
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.key,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                entry.value.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriorityStats() {
    Map<String, int> priorityStats = Map<String, int>.from(_statistics['byPriority'] ?? {});

    if (priorityStats.isEmpty) {
      return Text('No priority data available');
    }

    return Column(
      children: priorityStats.entries.map((entry) {
        Color color = _getPriorityColor(entry.key);
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.key,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                entry.value.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showAnnouncementDetails(Map<String, dynamic> announcement) {
    DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(announcement['createdAt'] ?? 0);
    DateTime? expiryDate;
    if (announcement['expiryDate'] != null) {
      expiryDate = DateTime.fromMillisecondsSinceEpoch(announcement['expiryDate']);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Announcement Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', announcement['announcementId'] ?? 'N/A'),
              _buildDetailRow('Title', announcement['title'] ?? 'N/A'),
              _buildDetailRow('Category', announcement['category'] ?? 'N/A'),
              _buildDetailRow('Priority', announcement['priority'] ?? 'N/A'),
              _buildDetailRow('Target Audience', announcement['targetAudience'] ?? 'N/A'),
              _buildDetailRow('Created By', announcement['createdByName'] ?? 'N/A'),
              _buildDetailRow('Created', '${createdAt.day}/${createdAt.month}/${createdAt.year}'),
              if (expiryDate != null)
                _buildDetailRow('Expires', '${expiryDate.day}/${expiryDate.month}/${expiryDate.year}'),
              _buildDetailRow('Views', '${announcement['viewCount'] ?? 0}'),
              SizedBox(height: 8),
              Text(
                'Content:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(announcement['content'] ?? 'No content'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditAnnouncementDialog(announcement);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700]),
            child: Text('Edit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateAnnouncementDialog() {
    _showAnnouncementForm();
  }

  void _showEditAnnouncementDialog(Map<String, dynamic> announcement) {
    _showAnnouncementForm(announcement: announcement);
  }

  void _showAnnouncementForm({Map<String, dynamic>? announcement}) {
    TextEditingController titleController = TextEditingController(
      text: announcement?['title'] ?? '',
    );
    TextEditingController contentController = TextEditingController(
      text: announcement?['content'] ?? '',
    );

    String selectedCategory = announcement?['category'] ?? 'General';
    String selectedPriority = announcement?['priority'] ?? 'Normal';
    String selectedTargetAudience = announcement?['targetAudience'] ?? 'All';
    DateTime? selectedExpiryDate;

    if (announcement?['expiryDate'] != null) {
      selectedExpiryDate = DateTime.fromMillisecondsSinceEpoch(announcement!['expiryDate']);
    }

    bool isEdit = announcement != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Announcement' : 'Create New Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(),
                  ),
                  items: ['General', 'Academic', 'Transport', 'Emergency', 'Maintenance']
                      .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  decoration: InputDecoration(
                    labelText: 'Priority *',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Low', 'Normal', 'High', 'Urgent']
                      .map((priority) => DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getPriorityColor(priority),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(priority),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedPriority = value!;
                    });
                  },
                ),
                SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: selectedTargetAudience,
                  decoration: InputDecoration(
                    labelText: 'Target Audience *',
                    border: OutlineInputBorder(),
                  ),
                  items: ['All', 'Students', 'Institutions', 'Specific Institution']
                      .map((audience) => DropdownMenuItem(
                    value: audience,
                    child: Text(audience),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedTargetAudience = value!;
                    });
                  },
                ),
                SizedBox(height: 16),

                InkWell(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedExpiryDate ?? DateTime.now().add(Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      setDialogState(() {
                        selectedExpiryDate = pickedDate;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Expiry Date (Optional)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      selectedExpiryDate != null
                          ? '${selectedExpiryDate!.day}/${selectedExpiryDate!.month}/${selectedExpiryDate!.year}'
                          : 'Select expiry date',
                    ),
                  ),
                ),
                SizedBox(height: 16),

                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Content *',
                    border: OutlineInputBorder(),
                    hintText: 'Enter announcement content...',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty ||
                    contentController.text.trim().isEmpty) {
                  _showSnackBar('Please fill all required fields', Colors.red);
                  return;
                }

                Navigator.pop(context);

                Map<String, dynamic> result;

                if (isEdit) {
                  result = await AnnouncementController.updateAnnouncement(
                    announcementId: announcement!['id'],
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    category: selectedCategory,
                    priority: selectedPriority,
                    targetAudience: selectedTargetAudience,
                    expiryDate: selectedExpiryDate,
                  );
                } else {
                  result = await AnnouncementController.createAnnouncement(
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    category: selectedCategory,
                    priority: selectedPriority,
                    targetAudience: selectedTargetAudience,
                    expiryDate: selectedExpiryDate,
                  );
                }

                if (result['success']) {
                  _showSnackBar(result['message'], Colors.green);
                  _loadAnnouncements();
                } else {
                  _showSnackBar(result['message'], Colors.red);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700]),
              child: Text(isEdit ? 'Update' : 'Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleAnnouncementStatus(Map<String, dynamic> announcement) async {
    bool currentStatus = announcement['isActive'] ?? true;

    Map<String, dynamic> result = await AnnouncementController.toggleAnnouncementStatus(
      announcement['id'],
      !currentStatus,
    );

    if (result['success']) {
      _showSnackBar(result['message'], Colors.green);
      _loadAnnouncements();
    } else {
      _showSnackBar(result['message'], Colors.red);
    }
  }

  void _deleteAnnouncement(Map<String, dynamic> announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Announcement'),
        content: Text('Are you sure you want to delete this announcement? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              Map<String, dynamic> result = await AnnouncementController.deleteAnnouncement(
                announcement['id'],
              );

              if (result['success']) {
                _showSnackBar(result['message'], Colors.green);
                _loadAnnouncements();
              } else {
                _showSnackBar(result['message'], Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'emergency':
        return Colors.red;
      case 'academic':
        return Colors.purple;
      case 'transport':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'general':
      default:
        return Colors.teal;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'low':
      default:
        return Colors.green;
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