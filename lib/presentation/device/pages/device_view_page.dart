import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DevicePage extends StatelessWidget {
  final String deviceId;

  const DevicePage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final logs = [
      {'date': '2024-01-12', 'note': 'Oil changed', 'hours': '100'},
      {'date': '2023-10-08', 'note': 'General check', 'hours': '200'},
      {'date': '2023-06-21', 'note': 'Filter replaced', 'hours': '300'},
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Maintenance for $deviceId"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView.separated(
              itemBuilder: (_, i) {
                final log = logs[i];
                return ListTile(
                  title: Text(log['date']!),
                  subtitle: Text(log['note']!),
                  trailing: Text('${log['hours']}h'),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: logs.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                spacing: 4,
                children: [
                  ElevatedButton(
                    onPressed: () => context.push("/device/:$deviceId/log"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4,
                      children: [Icon(Icons.add), Text("Add New Log")],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.push("/device/:$deviceId/edit"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4,
                      children: [Icon(Icons.edit), Text("Edit Device")],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
