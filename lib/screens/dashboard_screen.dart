import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/property.dart';
import 'add_property_screen.dart';
import 'property_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Harman Pest Pro – Properties')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('properties').listenable(),
        builder: (_, box, __) {
          final properties = box.values.map((m) => Property.fromMap(m['id'], m)).toList();

          if (properties.isEmpty) {
            return const Center(child: Text('No properties yet – tap + to add one', style: TextStyle(fontSize: 18)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: properties.length,
            itemBuilder: (ctx, i) {
              final p = properties[i];
              return Card(
                child: ListTile(
                  title: Text(p.ownerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(p.address),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p))),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyScreen())),
      ),
    );
  }
}
