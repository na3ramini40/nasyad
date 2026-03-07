import 'package:flutter/material.dart';

class DeviceLogPage extends StatefulWidget {
  const DeviceLogPage({super.key, required String deviceId});

  @override
  State<DeviceLogPage> createState() => _DeviceLogPageState();
}

class _DeviceLogPageState extends State<DeviceLogPage> {
  final _valueController = TextEditingController();

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _save() {
    final value = _valueController.text;
    Navigator.pop(context);
  }

  void _delete() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _delete,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text('New Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(labelText: 'New Value'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
