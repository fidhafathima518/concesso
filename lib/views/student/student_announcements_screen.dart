// views/student/student_announcements_screen.dart
import 'package:flutter/material.dart';
import 'package:concessoapp/controllers/announcement_controller.dart';
import 'package:concessoapp/services/shared_pref_service.dart';

class StudentAnnouncementsScreen extends StatefulWidget {
  @override
  _StudentAnnouncementsScreenState createState() => _StudentAnnouncementsScreenState();
}

class _StudentAnnouncementsScreenState extends State<StudentAnnouncementsScreen> {
  List<Map<String, dynamic>> _announcements = [];
  List<Map<String, dynamic>> _filteredAnnouncements = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedPriority = 'All';
  TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['All', 'General', 'Academic', 'Transport', 'Emergency', 'Maintenance'];
  final List<String> _priorities = ['All', 'Low', 'Normal', 'High', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
    });

    String studentId = SharedPrefService.getUserId();
    List<Map<String, dynamic>> announcements =
    await AnnouncementController.getAnnouncementsForStudent(studentId);

    setState(() {
      _announcements = announcements;
      _filteredAnnouncements = announcements;
      _isLoading = false;
    });
  }

  _filterAnnouncements() {
    setState(() {
      _filteredAnnouncements = _announcements.where((announcement) {
        bool matchesSearch = _searchQuery.isEmpty ||
            (announcement['title'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (announcement['content'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

        bool matchesCategory = _selectedCategory == 'All' ||
            (announcement['category'] ?? 'General') == _selectedCategory;

        bool matchesPriority = _selectedPriority == 'All' ||
            (announcement['priority'] ?? 'Normal') == _selectedPriority;

        return matchesSearch && matchesCategory && matchesPriority;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAnnouncements,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search announcements...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                        _filterAnnouncements();
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _filterAnnouncements();
                  },
                ),
                SizedBox(height: 12),

                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      bool isSelected = _selectedCategory == category;
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _filterAnnouncements();
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.orange[100],
                          checkmarkColor: Colors.orange[700],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 8),

                // Priority Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _priorities.map((priority) {
                      bool isSelected = _selectedPriority == priority;
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (priority != 'All') ...[
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(priority),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4),
                              ],
                              Text(priority),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedPriority = priority;
                            });
                            _filterAnnouncements();
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue[700],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Results Summary
          if (_filteredAnnouncements.length != _announcements.length)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue[50],
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.blue[700], size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Showing ${_filteredAnnouncements.length} of ${_announcements.length} announcements',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'All';
                        _selectedPriority = 'All';
                        _searchQuery = '';
                        _searchController.clear();
                      });
                      _filterAnnouncements();
                    },
                    child: Text(
                      'Clear Filters',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),

          // Announcements List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredAnnouncements.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: () async {
                await _loadAnnouncements();
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _filteredAnnouncements.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> announcement = _filteredAnnouncements[index];
                  return _buildAnnouncementCard(announcement, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    bool hasFilters = _searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedPriority != 'All';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            hasFilters ? 'No matching announcements' : 'No announcements available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your search or filters'
                : 'Check back later for updates from your institution',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (hasFilters) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _selectedPriority = 'All';
                  _searchQuery = '';
                  _searchController.clear();
                });
                _filterAnnouncements();
              },
              child: Text('Clear All Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement, int index) {
    DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(announcement['createdAt'] ?? 0);
    String category = announcement['category'] ?? 'General';
    String priority = announcement['priority'] ?? 'Normal';

    String studentId = SharedPrefService.getUserId();
    List<dynamic> readByUsers = announcement['readByUsers'] ?? [];
    bool isRead = readByUsers.contains(studentId);

    Color priorityColor = _getPriorityColor(priority);
    Color categoryColor = _getCategoryColor(category);

    DateTime? expiryDate;
    if (announcement['expiryDate'] != null) {
      expiryDate = DateTime.fromMillisecondsSinceEpoch(announcement['expiryDate']);
    }

    bool isExpiring = false;
    bool isExpired = false;
    if (expiryDate != null) {
      DateTime now = DateTime.now();
      Duration difference = expiryDate.difference(now);
      isExpiring = difference.inDays <= 3 && difference.inDays >= 0;
      isExpired = difference.inDays < 0;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: isRead ? 1 : 3,
      child: InkWell(
        onTap: () => _showAnnouncementDetails(announcement, index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isRead ? null : Border.all(color: Colors.orange[300]!, width: 1),
            color: isExpired ? Colors.grey[50] : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.orange[700],
                          shape: BoxShape.circle,
                        ),
                        margin: EdgeInsets.only(right: 8),
                      ),
                    Expanded(
                      child: Text(
                        announcement['title'] ?? 'No Title',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                          color: isExpired ? Colors.grey[600] : Colors.black,
                        ),
                      ),
                    ),
                    if (isExpired)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Expired',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (isExpiring)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Expiring Soon',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12),

                // Tags
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            size: 12,
                            color: categoryColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            category,
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: priorityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            priority,
                            style: TextStyle(
                              color: priorityColor,
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

                // Content Preview
                Text(
                  announcement['content'] ?? 'No content',
                  style: TextStyle(
                    color: isExpired ? Colors.grey[600] : Colors.grey[700],
                    fontSize: 15,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),

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
                              'Published: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                        if (expiryDate != null)
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text(
                                'Expires: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
                                style: TextStyle(
                                  color: isExpiring || isExpired ? Colors.red[600] : Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: isExpiring || isExpired ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Text(
                      'By ${announcement['createdByName'] ?? 'Admin'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAnnouncementDetails(Map<String, dynamic> announcement, int index) {
    // Mark as read
    String studentId = SharedPrefService.getUserId();
    AnnouncementController.markAnnouncementAsRead(announcement['id'], studentId);

    // Update UI
    setState(() {
      List<dynamic> readByUsers = announcement['readByUsers'] ?? [];
      if (!readByUsers.contains(studentId)) {
        readByUsers.add(studentId);
        announcement['readByUsers'] = readByUsers;

        // Update in both lists
        _announcements[_announcements.indexWhere((a) => a['id'] == announcement['id'])] = announcement;
        _filteredAnnouncements[index] = announcement;
      }
    });

    DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(announcement['createdAt'] ?? 0);
    DateTime? expiryDate;
    if (announcement['expiryDate'] != null) {
      expiryDate = DateTime.fromMillisecondsSinceEpoch(announcement['expiryDate']);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getCategoryIcon(announcement['category'] ?? 'General'),
              color: _getCategoryColor(announcement['category'] ?? 'General'),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                announcement['title'] ?? 'Announcement',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category and Priority Tags
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(announcement['category'] ?? 'General').withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      announcement['category'] ?? 'General',
                      style: TextStyle(
                        color: _getCategoryColor(announcement['category'] ?? 'General'),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(announcement['priority'] ?? 'Normal').withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      announcement['priority'] ?? 'Normal',
                      style: TextStyle(
                        color: _getPriorityColor(announcement['priority'] ?? 'Normal'),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Content
              Text(
                announcement['content'] ?? 'No content available',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 16),

              // Metadata
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Published: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (expiryDate != null)
                      Text(
                        'Expires: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    Text(
                      'By: ${announcement['createdByName'] ?? 'Admin'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'emergency':
        return Icons.warning;
      case 'academic':
        return Icons.school;
      case 'transport':
        return Icons.directions_bus;
      case 'maintenance':
        return Icons.build;
      case 'general':
      default:
        return Icons.info;
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
}