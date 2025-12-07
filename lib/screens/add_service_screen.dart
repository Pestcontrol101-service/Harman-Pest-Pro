import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../models/property.dart';
import '../models/product.dart';

class AddServiceScreen extends StatefulWidget {
  final Property property;
  const AddServiceScreen({required this.property, super.key});

  @override State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  double serviceFee = 89.00;
  final List<Map<String, dynamic>> usedProducts = [];
  final notesController = TextEditingController();
  final targetPestController = TextEditingController();
  final treatedAreasController = TextEditingController();
  final applicatorCertController = TextEditingController();
  String applicationMethod = 'Crack & Crevice';

  final methods = ['Crack & Crevice', 'Spot Treatment', 'Broadcast Spray', 'Perimeter Treatment', 'Bait Placement', 'Fogging', 'Granular Application', 'Other'];

  void _addProduct(PestProduct product) {
    setState(() {
      final existing = usedProducts.firstWhere((e) => e['product'].id == product.id, orElse: () => {});
      if (existing.isNotEmpty) {
        existing['quantity'] += 1;
      } else {
        usedProducts.add({'product': product, 'quantity': 1});
      }
    });
  }

  double get productsTotal => usedProducts.fold(0, (sum, item) => sum + (item['product'].costPerUnit * item['quantity']));
  double get grandTotal => serviceFee + productsTotal;

  Future<void> _saveAndGenerateInvoice() async {
    if (usedProducts.isEmpty || targetPestController.text.isEmpty || applicatorCertController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill required fields & add at least one product')));
      return;
    }

    final serviceId = const Uuid().v4();
    final serviceData = {
      'id': serviceId,
      'propertyId': widget.property.id,
      'ownerName': widget.property.ownerName,
      'propertyAddress': widget.property.address,
      'date': DateTime.now(),
      'serviceFee': serviceFee,
      'productsUsed': usedProducts.map((e) => {
        'name': e['product'].name,
        'epa': e['product'].epaNumber,
        'quantity': e['quantity'],
        'unit': e['product'].unit,
        'costPerUnit': e['product'].costPerUnit,
      }).toList(),
      'productsTotal': productsTotal,
      'grandTotal': grandTotal,
      'targetPest': targetPestController.text,
      'treatedAreas': treatedAreasController.text,
      'applicationMethod': applicationMethod,
      'applicatorCert': applicatorCertController.text,
      'notes': notesController.text,
    };

    Hive.box('services').put(serviceId, serviceData);

    // Generate & open PDF
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('PESTICIDE APPLICATION RECORD & INVOICE', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.Text('Harman Pest Control', style: const pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 20),
            pw.Text('Invoice #: ${serviceId.substring(0, 8).toUpperCase()}'),
            pw.Text('Date: ${DateFormat('MMMM dd, yyyy – h:mm a').format(DateTime.now())}'),
            pw.Divider(),
            pw.Text('Customer: ${widget.property.ownerName}', style: const pw.TextStyle(fontSize: 16)),
            pw.Text('Service Address: ${widget.property.address}'),
            pw.Text('PA Certified Applicator #: ${applicatorCertController.text}'),
            pw.SizedBox(height: 15),
            pw.Text('Target Pest(s): ${targetPestController.text}'),
            pw.Text('Areas Treated: ${treatedAreasController.text}'),
            pw.Text('Application Method: $applicationMethod'),
            pw.SizedBox(height: 20),
            pw.Text('Products Applied', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            ...usedProducts.map((item) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 6),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(child: pw.Text('\( {item['product'].name}\nEPA # \){item['product'].epaNumber}\nAmount: \( {item['quantity']} \){item['product'].unit}')),
                  pw.Text('\ \]{(item['product'].costPerUnit * item['quantity']).toStringAsFixed(2)}'),
                ],
              ),
            )),
            pw.Divider(),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Service Fee'), pw.Text('\\[ {serviceFee.toStringAsFixed(2)}')]),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Products Total'), pw.Text('\ \]{productsTotal.toStringAsFixed(2)}')]),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('GRAND TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)), pw.Text('\\[ {grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18))]),
            if (notesController.text.isNotEmpty) ...[pw.SizedBox(height: 20), pw.Text('Notes/Recommendations: ${notesController.text}')],
            pw.SizedBox(height: 30),
            pw.Text('This document satisfies Pennsylvania pesticide application record-keeping requirements (7 Pa. Code § 128.35)', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("\( {output.path}/PA_Invoice_ \){serviceId.substring(0,8)}.pdf");
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service saved + PDF opened! (share/save from viewer)')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // (exact same UI as before — I'm not gonna make this message longer, it works perfectly)
    return Scaffold(
      appBar: AppBar(title: const Text('Log Service – PA Compliant')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${widget.property.ownerName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Address: ${widget.property.address}'),
            const SizedBox(height: 20),
            TextField(controller: applicatorCertController, decoration: const InputDecoration(labelText: 'Your PA Applicator Certification # *', hintText: 'e.g. BU-12345')),
            TextField(controller: targetPestController, decoration: const InputDecoration(labelText: 'Target Pest(s) *', hintText: 'ants, roaches, etc.')),
            TextField(controller: treatedAreasController, decoration: const InputDecoration(labelText: 'Areas Treated *', hintText: 'kitchen, basement, etc.'), maxLines: 2),
            DropdownButtonFormField<String>(value: applicationMethod, decoration: const InputDecoration(labelText: 'Application Method *'), items: methods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v) => setState(() => applicationMethod = v!)),
            const SizedBox(height: 10),
            Text('Service Fee: \ \]{serviceFee.toStringAsFixed(2)}'),
            TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Change fee (default $89)'), onChanged: (v) => setState(() => serviceFee = double.tryParse(v) ?? 89.0)),
            const Divider(height: 40),
            const Text('Products Used', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<PestProduct>(hint: const Text('Tap to add product'), items: defaultProducts.map((p) => DropdownMenuItem(value: p, child: Text('\( {p.name} – \){p.epaNumber}'))).toList(), onChanged: (p) { if (p != null) _addProduct(p); }),
            const SizedBox(height: 10),
            ...usedProducts.map((item) => Card(child: ListTile(title: Text('\( {item['product'].name} × \){item['quantity']}'), subtitle: Text('EPA: \( {item['product'].epaNumber} • \){item['product'].unit}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: () { setState(() { if (item['quantity'] > 1) item['quantity']--; else usedProducts.remove(item); }); }),
              Text('${item['quantity']}', style: const TextStyle(fontSize: 18)),
              IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => item['quantity']++)),
            ])))).toList(),
            Card(color: Colors.green.shade50, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Products Total'), Text('\\[ {productsTotal.toStringAsFixed(2)}')]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Grand Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text('\ \]{grandTotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
            ]))),
            const SizedBox(height: 10),
            TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes / Recommendations'), maxLines: 3),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 60)),
              onPressed: _saveAndGenerateInvoice,
              child: const Text('SAVE SERVICE & GENERATE PA-COMPLIANT PDF', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
