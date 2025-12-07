import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/property.dart';
import 'add_service_screen.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;
  const PropertyDetailScreen({required this.property, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(property.address)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.ownerName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                if (property.phone.isNotEmpty) Text('Phone: ${property.phone}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.pest_control),
              label: const Text('LOG NEW SERVICE VISIT', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55), backgroundColor: Colors.green),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddServiceScreen(property: property))),
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Service History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box('services').listenable(),
              builder: (_, box, __) {
                final allServices = box.values.cast<Map<String, dynamic>>().toList();
                final propertyServices = allServices.where((s) => s['propertyId'] == property.id).toList();
                propertyServices.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

                if (propertyServices.isEmpty) return const Center(child: Text('No services logged yet'));

                return ListView.builder(
                  itemCount: propertyServices.length,
                  itemBuilder: (ctx, i) {
                    final data = propertyServices[i];
                    final date = data['date'] as DateTime;
                    final total = data['grandTotal'] as double;
                    final products = (data['productsUsed'] as List).length;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        title: Text(DateFormat('EEEE, MMMM d, yyyy').format(date)),
                        subtitle: Text('$products products • Total: \\[ {total.toStringAsFixed(2)}'),
                        trailing: const Icon(Icons.picture_as_pdf, color: Colors.red),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
