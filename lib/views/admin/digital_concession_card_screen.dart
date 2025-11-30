// views/admin/digital_concession_card_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

class DigitalConcessionCardScreen extends StatelessWidget {
  final String cardId;
  final Map<String, dynamic> studentData;
  final Map<String, dynamic> routeData;

  const DigitalConcessionCardScreen({
    Key? key,
    required this.cardId,
    required this.studentData,
    required this.routeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Concession Card'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareCard(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Digital Card
            _buildDigitalCard(),
            SizedBox(height: 24),

            // Card Details
            _buildCardDetails(),
            SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalCard() {
    DateTime validUntil = DateTime.now().add(Duration(days: 365));
    String qrData = "CONCESSION_CARD:$cardId:${studentData['studentId']}:${routeData['from']}:${routeData['to']}";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[500]!],
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
                Text(
                  'BUS CONCESSION CARD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Student Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Student Info
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardInfoRow('Name', studentData['name'] ?? 'N/A'),
                      SizedBox(height: 8),
                      _buildCardInfoRow('Student ID', studentData['studentId'] ?? 'N/A'),
                      SizedBox(height: 8),
                      _buildCardInfoRow('Course', studentData['course'] ?? 'N/A'),
                      SizedBox(height: 8),
                      _buildCardInfoRow('Route', '${routeData['from']} → ${routeData['to']}'),
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
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 120.0,
                      foregroundColor: Colors.black,
                    ),
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
                'Card ID: $cardId',
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

  Widget _buildCardDetails() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            _buildDetailRow('Card Holder', studentData['name'] ?? 'N/A'),
            _buildDetailRow('Student ID', studentData['studentId'] ?? 'N/A'),
            _buildDetailRow('Course', studentData['course'] ?? 'N/A'),
            _buildDetailRow('Email', studentData['email'] ?? 'N/A'),
            Divider(),
            _buildDetailRow('Route From', routeData['from'] ?? 'N/A'),
            _buildDetailRow('Route To', routeData['to'] ?? 'N/A'),
            Divider(),
            _buildDetailRow('Card ID', cardId),
            _buildDetailRow('Issue Date', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
            _buildDetailRow('Valid Until', '${DateTime.now().add(Duration(days: 365)).day}/${DateTime.now().add(Duration(days: 365)).month}/${DateTime.now().add(Duration(days: 365)).year}'),
            _buildDetailRow('Card Type', 'Bus Concession Card'),
            _buildDetailRow('Status', 'Active'),
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

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary Actions
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.download),
                label: Text('Download Card'),
                onPressed: () => _downloadCard(context),
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
                label: Text('Share Card'),
                onPressed: () => _shareCard(context),
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
                onPressed: () => _copyCardId(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(Icons.qr_code),
                label: Text('Show QR'),
                onPressed: () => _showQRCode(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Instructions
        Container(
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
                    'How to Use This Card',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '• Show this digital card to bus conductors\n'
                    '• QR code can be scanned for verification\n'
                    '• Keep a screenshot as backup\n'
                    '• Card is valid for one year from issue date\n'
                    '• Report lost cards immediately',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _copyCardId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: cardId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Card ID copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareCard(BuildContext context) {
    // In a real app, you would use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality would be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _downloadCard(BuildContext context) {
    // In a real app, you would generate PDF and save/download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download functionality would be implemented here'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showQRCode(BuildContext context) {
    String qrData = "CONCESSION_CARD:$cardId:${studentData['studentId']}:${routeData['from']}:${routeData['to']}";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code'),
        content: Container(
          width: 250,
          height: 250,
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 250.0,
            foregroundColor: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: qrData));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('QR data copied to clipboard')),
              );
            },
            child: Text('Copy Data'),
          ),
        ],
      ),
    );
  }
}