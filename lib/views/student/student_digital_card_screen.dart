// views/student/student_digital_card_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:concessoapp/controllers/student_controller.dart';
import 'package:concessoapp/services/shared_pref_service.dart';

class StudentDigitalCardScreen extends StatefulWidget {
  @override
  _StudentDigitalCardScreenState createState() => _StudentDigitalCardScreenState();
}

class _StudentDigitalCardScreenState extends State<StudentDigitalCardScreen> {
  Map<String, dynamic>? _digitalCard;
  Map<String, dynamic>? _studentProfile;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDigitalCard();
  }

  _loadDigitalCard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String studentId = SharedPrefService.getUserId();

    // Get student's digital card
    Map<String, dynamic>? cardData = await StudentController.getStudentDigitalCard(studentId);
    Map<String, dynamic>? profileData = await StudentController.getStudentProfile(studentId);

    setState(() {
      _digitalCard = cardData;
      _studentProfile = profileData;
      _isLoading = false;

      if (cardData == null) {
        _errorMessage = 'No digital card found. Please check if your bus application has been approved.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Digital Card'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDigitalCard,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _digitalCard == null
          ? _buildNoCardState()
          : _buildCardView(),
    );
  }

  Widget _buildNoCardState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_off,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No Digital Card Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.assignment),
              label: Text('Check My Applications'),
              onPressed: () {
                Navigator.pop(context);
                // Navigate to applications screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Digital Card
          _buildDigitalCard(),
          SizedBox(height: 24),

          // Card Status
          _buildCardStatus(),
          SizedBox(height: 16),

          // Card Details
          _buildCardDetails(),
          SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(),
          SizedBox(height: 16),

          // Usage Instructions
          _buildUsageInstructions(),
        ],
      ),
    );
  }

  Widget _buildDigitalCard() {
    if (_digitalCard == null) return SizedBox.shrink();

    DateTime validFrom = DateTime.fromMillisecondsSinceEpoch(_digitalCard!['validFrom'] ?? 0);
    DateTime validUntil = DateTime.fromMillisecondsSinceEpoch(_digitalCard!['validUntil'] ?? 0);
    String qrData = _digitalCard!['qrCodeData'] ?? '';
    bool isActive = _digitalCard!['isActive'] ?? false;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [Colors.green[700]!, Colors.green[500]!]
              : [Colors.grey[600]!, Colors.grey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.directions_bus, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'BUS CONCESSION CARD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                if (!isActive)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'INACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20),

            // Student Info and QR Code
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Student Info
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardInfoRow('Name', _studentProfile?['name'] ?? 'N/A'),
                      SizedBox(height: 8),
                      _buildCardInfoRow('Student ID', _studentProfile?['studentId'] ?? 'N/A'),
                      SizedBox(height: 8),
                      _buildCardInfoRow('Course', _studentProfile?['course'] ?? 'N/A'),
                      SizedBox(height: 8),
                      _buildCardInfoRow('Route', '${_digitalCard!['routeFrom']} → ${_digitalCard!['routeTo']}'),
                      SizedBox(height: 8),
                      _buildCardInfoRow('Valid Until', '${validUntil.day}/${validUntil.month}/${validUntil.year}'),
                    ],
                  ),
                ),

                // Right side - QR Code
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: qrData.isNotEmpty
                        ? QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 120.0,
                      foregroundColor: Colors.black,
                    )
                        : Icon(Icons.qr_code, size: 120, color: Colors.grey),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Card ID
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Card ID: ${_digitalCard!['cardId'] ?? 'N/A'}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCardStatus() {
    if (_digitalCard == null) return SizedBox.shrink();

    bool isActive = _digitalCard!['isActive'] ?? false;
    DateTime validUntil = DateTime.fromMillisecondsSinceEpoch(_digitalCard!['validUntil'] ?? 0);
    bool isExpired = DateTime.now().isAfter(validUntil);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (!isActive) {
      statusColor = Colors.red;
      statusText = 'Card Deactivated';
      statusIcon = Icons.block;
    } else if (isExpired) {
      statusColor = Colors.orange;
      statusText = 'Card Expired';
      statusIcon = Icons.schedule;
    } else {
      statusColor = Colors.green;
      statusText = 'Card Active';
      statusIcon = Icons.check_circle;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 16,
                  ),
                ),
                if (isActive && !isExpired)
                  Text(
                    'Valid until ${validUntil.day}/${validUntil.month}/${validUntil.year}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                if (!isActive && _digitalCard!['deactivationReason'] != null)
                  Text(
                    'Reason: ${_digitalCard!['deactivationReason']}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetails() {
    if (_digitalCard == null) return SizedBox.shrink();

    DateTime generatedAt = DateTime.fromMillisecondsSinceEpoch(_digitalCard!['generatedAt'] ?? 0);
    DateTime validFrom = DateTime.fromMillisecondsSinceEpoch(_digitalCard!['validFrom'] ?? 0);
    DateTime validUntil = DateTime.fromMillisecondsSinceEpoch(_digitalCard!['validUntil'] ?? 0);

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            _buildDetailRow('Card Holder', _studentProfile?['name'] ?? 'N/A'),
            _buildDetailRow('Student ID', _studentProfile?['studentId'] ?? 'N/A'),
            _buildDetailRow('Course', _studentProfile?['course'] ?? 'N/A'),
            _buildDetailRow('Email', _studentProfile?['email'] ?? 'N/A'),
            _buildDetailRow('Phone', _studentProfile?['phone'] ?? 'N/A'),
            Divider(),
            _buildDetailRow('Route From', _digitalCard!['routeFrom'] ?? 'N/A'),
            _buildDetailRow('Route To', _digitalCard!['routeTo'] ?? 'N/A'),
            Divider(),
            _buildDetailRow('Card ID', _digitalCard!['cardId'] ?? 'N/A'),
            _buildDetailRow('Issue Date', '${generatedAt.day}/${generatedAt.month}/${generatedAt.year}'),
            _buildDetailRow('Valid From', '${validFrom.day}/${validFrom.month}/${validFrom.year}'),
            _buildDetailRow('Valid Until', '${validUntil.day}/${validUntil.month}/${validUntil.year}'),
            _buildDetailRow('Card Type', _digitalCard!['cardType'] ?? 'Bus Concession'),
            _buildDetailRow('Status', (_digitalCard!['isActive'] ?? false) ? 'Active' : 'Inactive'),
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
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary Actions
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.download),
                label: Text('Save Card'),
                onPressed: () => _saveCard(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.share),
                label: Text('Share'),
                onPressed: () => _shareCard(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Secondary Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(Icons.copy),
                label: Text('Copy Card ID'),
                onPressed: () => _copyCardId(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(Icons.qr_code_scanner),
                label: Text('Show QR'),
                onPressed: () => _showQRCode(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsageInstructions() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue[700], size: 20),
              SizedBox(width: 8),
              Text(
                'How to Use Your Digital Card',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Show this card to bus conductors when boarding\n'
                '• Conductors can scan the QR code for verification\n'
                '• Save a screenshot as backup on your phone\n'
                '• Report lost phone immediately to prevent misuse\n'
                '• Card is valid only for the specified route\n'
                '• Check expiry date regularly and renew before it expires',
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _copyCardId() {
    if (_digitalCard != null) {
      Clipboard.setData(ClipboardData(text: _digitalCard!['cardId'] ?? ''));
      _showSnackBar('Card ID copied to clipboard', Colors.green);
    }
  }

  void _shareCard() {
    _showSnackBar('Share functionality would be implemented here', Colors.blue);
  }

  void _saveCard() {
    _showSnackBar('Save functionality would be implemented here', Colors.green);
  }

  void _showQRCode() {
    if (_digitalCard == null) return;

    String qrData = _digitalCard!['qrCodeData'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code for Verification'),
        content: Container(
          width: 250,
          height: 250,
          child: qrData.isNotEmpty
              ? QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 250.0,
            foregroundColor: Colors.black,
          )
              : Center(child: Text('No QR code available')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          if (qrData.isNotEmpty)
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: qrData));
                Navigator.pop(context);
                _showSnackBar('QR data copied to clipboard', Colors.green);
              },
              child: Text('Copy Data'),
            ),
        ],
      ),
    );
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