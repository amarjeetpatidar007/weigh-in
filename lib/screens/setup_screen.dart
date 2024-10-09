import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  TimeOfDay _notificationTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Enter your name'),
                onSaved: (value) {
                  _name = value ?? '';
                },
                validator: (value) {
                  return value == null || value.isEmpty ? 'Please enter your name' : null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Pick Notification Time'),
                onPressed: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _notificationTime,
                  );
                  if (picked != null) {
                    setState(() {
                      _notificationTime = picked;
                    });
                  }
                },
              ),
              Text('Notification Time: ${_notificationTime.format(context)}'),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Save & Continue'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Provider.of<UserProvider>(context, listen: false).saveUserData(_name, _notificationTime);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
