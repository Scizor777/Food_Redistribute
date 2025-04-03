import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/food_service.dart';
import '../../models/user_model.dart';

class AddFoodForm extends StatefulWidget {
  final User user;

  const AddFoodForm({super.key, required this.user});

  @override
  State<AddFoodForm> createState() => _AddFoodFormState();
}

class _AddFoodFormState extends State<AddFoodForm> {
  String? _timeUnit = 'hours';
  final _timeController = TextEditingController();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minOrderController = TextEditingController();
  String? _selectedAddressType;
  final _newAddressController = TextEditingController();
  Position? _currentPosition;

  @override
  void dispose() {
    _timeController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _minOrderController.dispose();
    _newAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Food Donation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Total Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _minOrderController,
              decoration: const InputDecoration(
                labelText: 'Minimum Order Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Expiry Time',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _timeUnit,
              items: const [
                DropdownMenuItem(value: 'hours', child: Text('Hours')),
                DropdownMenuItem(value: 'days', child: Text('Days')),
              ],
              onChanged: (value) {
                setState(() {
                  _timeUnit = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Time Unit',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedAddressType,
              items: [
                'Select company address',
                'New address'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAddressType = value;
                  if (value == 'Select company address') {
                    _newAddressController.clear();
                  }
                });
              },
              decoration: const InputDecoration(
                labelText: 'Pickup Location',
                border: OutlineInputBorder(),
              ),
            ),
            if (_selectedAddressType == 'New address') ...[
              const SizedBox(height: 15),
              TextFormField(
                controller: _newAddressController,
                decoration: const InputDecoration(
                  labelText: 'Enter New Address',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _submitFoodDonation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Submit Donation'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFoodDonation() async {
    if (_nameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _minOrderController.text.isEmpty ||
        _selectedAddressType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final status = await Permission.location.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required')),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      _currentPosition = await Geolocator.getCurrentPosition();

      final address = _selectedAddressType == 'Select company address'
          ? (widget.user.supplierDetails?['address'] ?? 'Unknown Address')
          : _newAddressController.text;

      final foodData = {
        'name': _nameController.text,
        'totalQuantity': int.parse(_quantityController.text),
        'minOrderQuantity': int.parse(_minOrderController.text),
        'time': _timeController.text,
        'timeUnit': _timeUnit,
        'pickupLocation': address,
        'exactLocation': {
          'type': 'Point',
          'coordinates': [
            _currentPosition!.longitude,
            _currentPosition!.latitude
          ],
        },
        'companyName': widget.user.supplierDetails?['companyName'],
      };

      await FoodService.addFoodDonation(foodData);

      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food added successfully!')),
      );

      // Clear form
      _nameController.clear();
      _quantityController.clear();
      _minOrderController.clear();
      _newAddressController.clear();
      setState(() => _selectedAddressType = null);

      // Close the form
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}