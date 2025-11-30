// views/student/bus_card_application_screen.dart - Updated with ImageService
import 'package:flutter/material.dart';
import 'package:concessoapp/services/shared_pref_service.dart';
import 'package:concessoapp/controllers/student_controller.dart';
import 'package:concessoapp/services/image_service.dart'; // Add this import
import 'dart:io';

class BusCardApplicationScreen extends StatefulWidget {
  @override
  _BusCardApplicationScreenState createState() => _BusCardApplicationScreenState();
}

class _BusCardApplicationScreenState extends State<BusCardApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _routeFromController = TextEditingController();
  final _routeToController = TextEditingController();
  final _reasonController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _familyIncomeController = TextEditingController();

  final ImageService _imageService = ImageService(); // Add this instance
  List<File> _documents = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _routeFromController.dispose();
    _routeToController.dispose();
    _reasonController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _familyIncomeController.dispose();
    super.dispose();
  }

  // Updated document picker using your ImageService
  _pickDocument() async {
    if (_documents.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum 5 documents allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      File? pickedFile = await _imageService.showImagePickerDialog(context);

      if (pickedFile != null) {
        setState(() {
          _documents.add(pickedFile);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document added successfully (${_documents.length}/5)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error picking document: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick document. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  _removeDocument(int index) {
    setState(() {
      _documents.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Document removed'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  _submitApplication() async {
    try {
      // 1. Check verification status first
      print("🔵 Checking student verification status...");
      Map<String, dynamic> verificationStatus = await StudentController.checkStudentVerificationStatus(
          SharedPrefService.getUserId()
      );

      if (!verificationStatus['verified']) {
        String message = verificationStatus['message'] ?? 'Account verification required';

        // Show verification error dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Verification Required'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                if (verificationStatus['rejected'] == true) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Your verification was rejected. Please contact your institution to resolve this issue.',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ] else ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Please wait for your institution to verify your account before applying for bus cards.',
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
              if (verificationStatus['rejected'] != true)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Refresh verification status
                    setState(() {
                      // This will trigger a rebuild and recheck verification
                    });
                  },
                  child: Text('Check Again'),
                ),
            ],
          ),
        );
        return;
      }

      // 2. Validate form
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill all required fields correctly'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 3. Check documents
      if (_documents.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please upload at least one document'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Upload',
              textColor: Colors.white,
              onPressed: _pickDocument,
            ),
          ),
        );
        return;
      }

      // 4. Validate family income
      double? familyIncome = double.tryParse(_familyIncomeController.text.trim());
      if (familyIncome == null || familyIncome <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid family income'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 5. Show confirmation dialog
      bool? confirmed = await _showConfirmationDialog();
      if (confirmed != true) return;

      // 6. Start submission process
      setState(() {
        _isLoading = true;
      });

      print("🔵 Starting bus card application submission...");

      // 7. Submit application
      Map<String, dynamic> result = await StudentController.applyForBusCard(
        studentId: SharedPrefService.getUserId(),
        routeFrom: _routeFromController.text.trim(),
        routeTo: _routeToController.text.trim(),
        reason: _reasonController.text.trim(),
        guardianName: _guardianNameController.text.trim(),
        guardianPhone: _guardianPhoneController.text.trim(),
        familyIncome: familyIncome,
        documents: _documents,
      );

      setState(() {
        _isLoading = false;
      });

      // 8. Handle response
      if (result['success']) {
        // Success response
        print("✅ Application submitted successfully");

        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Application Submitted'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(result['message'] ?? 'Your bus card application has been submitted successfully.'),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (result['applicationId'] != null) ...[
                        Text(
                          'Application ID: ${result['applicationId']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                      Text(
                        'You will be notified once your application is reviewed. You can track the status in the "My Applications" section.',
                        style: TextStyle(color: Colors.green[700]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to dashboard
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      } else {
        // Error response
        print("❌ Application submission failed: ${result['message']}");

        // Check if it's a verification error
        if (result['requiresVerification'] == true) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Verification Required'),
                ],
              ),
              content: Text(result['message'] ?? 'Your account needs to be verified before applying.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // General error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to submit application'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  // Retry submission
                  _submitApplication();
                },
              ),
            ),
          );
        }
      }

    } catch (e) {
      // Handle unexpected errors
      print("❌ Unexpected error during submission: $e");

      setState(() {
        _isLoading = false;
      });

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Submission Error'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('An unexpected error occurred while submitting your application.'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Please check your internet connection and try again. If the problem persists, contact support.',
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitApplication(); // Retry
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please review your application:'),
            SizedBox(height: 12),
            Text('• Route: ${_routeFromController.text} → ${_routeToController.text}'),
            Text('• Guardian: ${_guardianNameController.text}'),
            Text('• Documents: ${_documents.length} file(s)'),
            SizedBox(height: 12),
            Text(
              'Once submitted, you cannot edit this application.',
              style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Review Again'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
            child: Text('Submit Application', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Card Application'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Information Card
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700]),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Fill all details carefully. Upload clear images of required documents (ID proof, income certificate, etc.)',
                          style: TextStyle(color: Colors.blue[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Route Information Section
              Text(
                'Route Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _routeFromController,
                decoration: InputDecoration(
                  labelText: 'From (Starting Point) *',
                  prefixIcon: Icon(Icons.my_location),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: 'Enter your starting location',
                ),
                validator: (value) => value?.isEmpty == true ? 'Starting point is required' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _routeToController,
                decoration: InputDecoration(
                  labelText: 'To (Destination) *',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: 'Enter your destination (college/school)',
                ),
                validator: (value) => value?.isEmpty == true ? 'Destination is required' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason for Application *',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: 'Explain why you need the bus concession card',
                  alignLabelWithHint: true,
                ),
                validator: (value) => value?.isEmpty == true ? 'Reason is required' : null,
              ),
              SizedBox(height: 24),

              // Guardian Information Section
              Text(
                'Guardian Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _guardianNameController,
                decoration: InputDecoration(
                  labelText: 'Guardian/Parent Name *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) => value?.isEmpty == true ? 'Guardian name is required' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _guardianPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Guardian Phone Number *',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value?.isEmpty == true) return 'Phone number is required';
                  if (value!.length < 10) return 'Enter valid phone number';
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _familyIncomeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Annual Family Income (₹) *',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: 'Enter amount in rupees',
                ),
                validator: (value) {
                  if (value?.isEmpty == true) return 'Family income is required';
                  if (double.tryParse(value!) == null) return 'Enter valid amount';
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Documents Section
              Text(
                'Required Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Upload clear images of: Student ID, Income Certificate, Address Proof, etc.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              SizedBox(height: 16),

              // Document Upload Card
              Card(
                elevation: 2,
                child: InkWell(
                  onTap: _isLoading ? null : _pickDocument,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.upload_file,
                          size: 48,
                          color: _isLoading ? Colors.grey : Colors.blue[700],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to Upload Document',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _isLoading ? Colors.grey : Colors.blue[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Maximum 5 documents allowed',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Selected Documents List
              if (_documents.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  'Selected Documents (${_documents.length}/5)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                ...List.generate(_documents.length, (index) {
                  String fileName = _documents[index].path.split('/').last;
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.description, color: Colors.blue[700]),
                      title: Text(
                        fileName,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('Document ${index + 1}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: _isLoading ? null : () => _removeDocument(index),
                      ),
                    ),
                  );
                }),
              ],

              SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                        'Submitting Application...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  )
                      : Text(
                    'Submit Application',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}