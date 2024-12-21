import 'package:flutter/material.dart';
import 'package:village_officer_app/license_manager.dart';
import '../utils/license_manager.dart';

class LicenseActivationPage extends StatefulWidget {
  const LicenseActivationPage({super.key});

  @override
  _LicenseActivationPageState createState() => _LicenseActivationPageState();
}

class _LicenseActivationPageState extends State<LicenseActivationPage> {
  final _keyController = TextEditingController();
  String? _errorMessage;

  Future<void> _activateLicense() async {
    final userKey = _keyController.text.trim();
    final isValid = await LicenseManager.validateAndStoreKey(userKey);

    if (isValid) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('License Activated Successfully!')),
      );
      Navigator.pushReplacementNamed(context, '/Home'); // Navigate to home
    } else {
      // Show error message
      setState(() {
        _errorMessage = "Invalid License Key. Please try again.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid License Key. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("License Activation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter Your License Key",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _keyController,
              decoration: InputDecoration(
                labelText: "License Key",
                errorText: _errorMessage,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _activateLicense,
              child: const Text("Activate"),
            ),
          ],
        ),
      ),
    );
  }
}
