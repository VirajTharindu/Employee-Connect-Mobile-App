import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:employee_connect/core/constants/app_routes.dart';
import 'package:employee_connect/data/services/license_service.dart';
import 'package:employee_connect/presentation/pages/family/family_member_form_page.dart';
import 'package:employee_connect/presentation/pages/auth/license_activation_page.dart';

import 'package:employee_connect/core/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  locator.setup();
  runApp(const EmployeeConnectApp());
}

class EmployeeConnectApp extends StatelessWidget {
  const EmployeeConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Connect',
      routes: AppRoutes.getRoutes(),
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      builder: (context, child) {
        if (!kIsWeb) return child!;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
      home: FutureBuilder<bool>(
        future: LicenseManager.isAppActivated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final isActivated = snapshot.data ?? false;
          return isActivated
              ? FamilyMemberForm()
              : const LicenseActivationPage();
        },
      ),
    );
  }
}
