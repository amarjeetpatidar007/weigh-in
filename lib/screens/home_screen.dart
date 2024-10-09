import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weigh_in/screens/update_time_form.dart';
import 'package:weigh_in/screens/weight_form.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../services/user_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    initializeNotificationResponseHandler(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditNotificationTimeForm()),
              );
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.weightRecords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.scale, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "No Weight Records Yet",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap the + button to add your first record",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userProvider.weightRecords.length,
            itemBuilder: (context, index) {
              final record = userProvider.weightRecords[index];
              final isMissed = record.weight == null || record.weight == 0;
              final formattedDate = DateFormat('MMMM d, yyyy').format(
                DateTime.parse(record.date),
              );

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isMissed ? Colors.red[100] : Colors.green[100],
                        ),
                        child: Icon(
                          isMissed ? Icons.close : Icons.check,
                          color: isMissed ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDate,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isMissed ? 'Missed' : '${record.weight} kg',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isMissed ? Colors.red : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WeightRecordForm()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}