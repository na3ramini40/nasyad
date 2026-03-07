import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'id': '1', 'name': 'Air Conditioner'},
      {'id': '2', 'name': 'Car'},
      {'id': '3', 'name': 'Laptop'},
    ];
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () =>context.push("/device/new"),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(title: const Text("Devices")),
      body: ListView.separated(
        itemBuilder: (_, i) {
          final item = items[i];
          return ListTile(
            title: Text(item['name']!),
            onTap: () => context.push("/device/${item['id']}"),
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: items.length,
      ),
    );
  }
}
