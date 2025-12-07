import 'package:uuid/uuid.dart';

class PestProduct {
  final String id;
  final String name;
  final String epaNumber;
  final double costPerUnit;
  final String unit;

  PestProduct({required this.id, required this.name, required this.epaNumber, required this.costPerUnit, required this.unit});
}

final uuid = Uuid();

final List<PestProduct> defaultProducts = [
  PestProduct(id: uuid.v4(), name: 'D-Fense NXT Aerosol', epaNumber: '53883-415', costPerUnit: 24.99, unit: 'can'),
  PestProduct(id: uuid.v4(), name: 'Doxem Precise', epaNumber: '53883-438', costPerUnit: 32.00, unit: 'tube'),
  PestProduct(id: uuid.v4(), name: 'SureKill SK100', epaNumber: '47000-179', costPerUnit: 28.50, unit: 'bottle'),
  PestProduct(id: uuid.v4(), name: 'Alpine WSG', epaNumber: '499-561', costPerUnit: 45.00, unit: 'jar'),
  PestProduct(id: uuid.v4(), name: 'Talon G Rodenticide', epaNumber: '12455-143', costPerUnit: 68.00, unit: '8 lb'),
  PestProduct(id: uuid.v4(), name: 'Advion Cockroach Gel', epaNumber: '100-1498', costPerUnit: 34.99, unit: 'box (4 tubes)'),
  // Add your real products here anytime
];
