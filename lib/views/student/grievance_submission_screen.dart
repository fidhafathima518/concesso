import 'package:concessoapp/views/student/student_grievances_screen.dart';
import 'package:concessoapp/controllers/grievance_controller.dart';
import 'package:flutter/material.dart';
import '../../services/shared_pref_service.dart';

class GrievanceSubmissionScreen extends StatefulWidget {
  @override
  _GrievanceSubmissionScreenState createState() => _GrievanceSubmissionScreenState();
}

class _GrievanceSubmissionScreenState extends State<GrievanceSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Academic';
  String _selectedPriority = 'Medium';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'value': 'Academic',
      'icon': Icons.school,
      'description': 'Issues related to academics, courses, exams',
      'assignedTo': 'Institution'
    },
    {
      'value': 'Transport',
      'icon': Icons.directions_bus,
      'description': 'Bus services, routes, transport issues',
      'assignedTo': 'Admin'
    },
    {
      'value': 'Facilities',
      'icon': Icons.business,
      'description': 'Infrastructure, hostel, library issues',
      'assignedTo': 'Institution'
    },
    {
      'value': 'Administrative',
      'icon': Icons.admin_panel_settings,
      'description': 'Administrative processes, documentation',
      'assignedTo': 'Institution'
    },
    {
      'value': 'Other',
      'icon': Icons.help_outline,
      'description': 'Other issues not covered above',
      'assignedTo': 'Institution'
    }
  ];

  final List<Map<String, dynamic>> _priorities = [
    {
      'value': 'Low',
      'color': Colors.green,
      'description': 'Non-urgent, can wait'
    },
    {
      'value': 'Medium',
      'color': Colors.orange,
      'description': 'Normal priority'
    },
    {
      'value': 'High',
      'color': Colors.red,
      'description': 'Urgent, needs immediate attention'
    }
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  _submitGrievance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> result = await GrievanceController.submitGrievance(
        studentId: SharedPrefService.getUserId(),
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
      );

      setState(() {
        _isLoading = false;
      });

      // Show result message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result['message'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (result['success']) ...[
                SizedBox(height: 4),
                Text(
                  'Grievance ID: ${result['customGrievanceId']}',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  'Assigned to: ${result['assignedToType'] == 'admin' ? 'Admin' : 'Institution'}',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
          duration: Duration(seconds: result['success'] ? 4 : 3),
        ),
      );

      if (result['success']) {
        // Show success dialog with options
        _showSuccessDialog(result);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Grievance Submitted'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your grievance has been successfully submitted.'),
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
                    'Grievance Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('ID: ${result['customGrievanceId']}'),
                  Text('Category: $_selectedCategory'),
                  Text('Priority: $_selectedPriority'),
                  Text('Assigned to: ${result['assignedToType'] == 'admin' ? 'Admin Team' : 'Institution'}'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'You will receive a response within 24-48 hours. You can track the status in "My Grievances" section.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentGrievancesScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('View My Grievances', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getCategoryAssignment(String category) {
    Map<String, dynamic>? categoryData = _categories.firstWhere(
          (cat) => cat['value'] == category,
      orElse: () => {'assignedTo': 'Institution'},
    );
    return categoryData['assignedTo'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Grievance'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Card(
                color: Colors.orange[50],
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange[700]),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Submit your concerns or issues',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Our team will review and respond within 24-48 hours. Choose the appropriate category for faster resolution.',
                        style: TextStyle(color: Colors.orange[700], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              Text(
                'Grievance Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // Category Selection
              Text(
                'Category *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: _categories.map((category) {
                    bool isSelected = _selectedCategory == category['value'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category['value'];
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange[50] : null,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: category['value'],
                              groupValue: _selectedCategory,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                              activeColor: Colors.orange[700],
                            ),
                            Icon(
                              category['icon'],
                              color: isSelected ? Colors.orange[700] : Colors.grey[600],
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category['value'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.orange[700] : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    category['description'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (category['assignedTo'] == 'Admin' ? Colors.red : Colors.blue).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                category['assignedTo'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: category['assignedTo'] == 'Admin' ? Colors.red : Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),

              // Priority Selection
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  labelText: 'Priority *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: _priorities.map((priority) {
                  return DropdownMenuItem<String>(
                    value: priority['value'],
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: priority['color'],
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(priority['value']),
                        SizedBox(width: 8),
                        Text(
                          '(${priority['description']})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),
              SizedBox(height: 16),

              // Subject Field
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject *',
                  border: OutlineInputBorder(),
                  hintText: 'Brief summary of your issue',
                  prefixIcon: Icon(Icons.subject),
                  counterText: '${_subjectController.text.length}/100',
                ),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject';
                  }
                  if (value.length < 5) {
                    return 'Subject should be at least 5 characters';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {}); // To update counter
                },
              ),
              SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  hintText: 'Provide detailed information about your grievance.\n\nInclude:\n• What happened?\n• When did it occur?\n• What outcome do you expect?',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description),
                  ),
                  counterText: '${_descriptionController.text.length}/500',
                ),
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.length < 20) {
                    return 'Please provide more details (minimum 20 characters)';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {}); // To update counter
                },
              ),
              SizedBox(height: 8),

              // Assignment Info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getCategoryAssignment(_selectedCategory) == 'Admin'
                      ? Colors.red[50]
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getCategoryAssignment(_selectedCategory) == 'Admin'
                        ? Colors.red[200]!
                        : Colors.blue[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.assignment_ind,
                      color: _getCategoryAssignment(_selectedCategory) == 'Admin'
                          ? Colors.red[700]
                          : Colors.blue[700],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This grievance will be assigned to: ${_getCategoryAssignment(_selectedCategory)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getCategoryAssignment(_selectedCategory) == 'Admin'
                              ? Colors.red[700]
                              : Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitGrievance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Submitting...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Submit Grievance',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // View Grievances Button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentGrievancesScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.list, color: Colors.orange[700]),
                  label: Text(
                    'View My Grievances',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}