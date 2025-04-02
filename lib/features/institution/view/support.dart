import 'package:flutter/material.dart';

class InstitutionSupport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Support")),
      body: Center(
        child: Text(
          "Support and Help Center",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
