// carddetailspage.dart
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class CardDetailsPage extends StatelessWidget {
  final String status;
  final Map<String, dynamic> cardData;
  CardDetailsPage({required this.status, required this.cardData});

  Future<void> _generatePDF(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Text("Concession Card", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text("Status: $status"),
            pw.Text("Student ID: ${cardData['studentId'] ?? 'N/A'}"),
            pw.Text("College: ${cardData['college'] ?? 'N/A'}"),
            pw.Text("Valid Until: ${cardData['validUntil'] ?? 'N/A'}"),
            pw.Text("Submitted At: ${cardData['submittedAt']?.toDate().toString() ?? 'N/A'}"),
          ],
        ),
      ),
    );

    final dir = await getExternalStorageDirectory();
    final file = File("${dir!.path}/ConcessionCard.pdf");

    if (await Permission.storage.request().isGranted) {
      await file.writeAsBytes(await pdf.save());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PDF downloaded to ${file.path}")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Storage permission denied")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Card Details")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Status: $status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Student ID: ${cardData['studentId'] ?? 'N/A'}"),
            Text("College: ${cardData['college'] ?? 'N/A'}"),
            Text("Valid Until: ${cardData['validUntil'] ?? 'N/A'}"),
            Text("Submitted At: ${cardData['submittedAt']?.toDate().toString() ?? 'N/A'}"),
            SizedBox(height: 20),
            if (status == "Approved")
              ElevatedButton.icon(
                onPressed: () => _generatePDF(context),
                icon: Icon(Icons.download),
                label: Text("Download as PDF"),
              ),
          ],
        ),
      ),
    );
  }
}
