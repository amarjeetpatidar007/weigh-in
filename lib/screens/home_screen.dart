import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return ListView.builder(
            itemCount: userProvider.weightRecords.length,
            itemBuilder: (context, index) {
              final record = userProvider.weightRecords[index];
              return ListTile(
                title: Text(
                    'Date: ${record.date}, Weight: ${record.weight ?? 'Missed'}'),
                trailing: record.weight == null
                    ? const Icon(Icons.warning, color: Colors.red)
                    : null,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add logic for recording weight
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
