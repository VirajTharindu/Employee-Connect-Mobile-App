import 'package:flutter/material.dart';
import 'ShareDB.dart';

class DatabaseTransferScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Database Transfer")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await exportDatabase();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Database exported successfully!")),
                );
              },
              child: const Text("Export Database"),
            ),
            ElevatedButton(
              onPressed: () async {
                await importDatabase();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Database imported successfully!")),
                );
              },
              child: const Text("Import Database"),
            ),
          ],
        ),
      ),
    );
  }
}
