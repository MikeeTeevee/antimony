import 'package:flutter/material.dart';
import 'compliance_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOX Readiness'),
        centerTitle: true,
      ),
      body: const ComplianceTab(),
    );
  }
}
