import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeviceEditPage extends StatefulWidget {
  final String? deviceId;

  const DeviceEditPage({super.key, this.deviceId});

  bool get isEdit => deviceId != null;

  @override
  State<DeviceEditPage> createState() => _DeviceEditPageState();
}

class _DeviceEditPageState extends State<DeviceEditPage> {
  final _nameController = TextEditingController();
  final _checkonController = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// fake data if editing
    if (widget.isEdit) {
      _nameController.text = "Device ${widget.deviceId}";
      _checkonController.text = "Model X";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _checkonController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text;
    final model = _checkonController.text;

    debugPrint("save device");
    debugPrint(name);
    debugPrint(model);

    Navigator.pop(context);
  }

  void _delete() {
    debugPrint("delete device ${widget.deviceId}");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(isEdit ? "Edit Device" : "New Device"),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _delete,
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Device name",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _checkonController,
              decoration: const InputDecoration(
                labelText: "Check on ? Unit",
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
