import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/property.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});
  @override State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _owner = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Property')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _owner, decoration: const InputDecoration(labelText: 'Customer/Owner Name *'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Service Address *'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final id = const Uuid().v4();
                    final property = Property(id: id, ownerName: _owner.text.trim(), address: _address.text.trim(), phone: _phone.text.trim());
                    Hive.box('properties').put(id, property.toMap());
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Property', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
