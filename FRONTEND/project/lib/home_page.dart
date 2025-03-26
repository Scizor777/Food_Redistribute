import 'package:flutter/material.dart';
import 'main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomePage({super.key, required this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Form controllers
  String? _timeUnit = 'hours'; // Default to hours
  final _timeController = TextEditingController();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minOrderController = TextEditingController();
  String? _selectedAddressType;
  final _newAddressController = TextEditingController();
  Position? _currentPosition;

  // Address options
  late final List<String> _addressOptions = [
    'Select company address',
    'New address'
  ];

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () => _showUserProfile(context),
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/profilepic.jpg'),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Home Page!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            if (widget.userData['type'] == 'Supplier')
              ElevatedButton(
                onPressed: () => _showAddFoodForm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Add Food Donation',
                  style: TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

void _showAddFoodForm(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
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
                items: _addressOptions.map((String value) {
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
                onPressed: () => _submitFoodDonation(context),
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
    },
  );
}

Future<void> _submitFoodDonation(BuildContext context) async {
  // Validate form
  if (_nameController.text.isEmpty ||
      _quantityController.text.isEmpty ||
      _minOrderController.text.isEmpty ||
      _selectedAddressType == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all required fields')),
    );
    return;
  }

  // Check GPS permission
  final status = await Permission.location.request();
  if (!status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location permission is required')),
    );
    return;
  }

  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Get current position
    _currentPosition = await Geolocator.getCurrentPosition();
    
    // Determine address
    final address = _selectedAddressType == 'Select company address'
        ? widget.userData['supplierDetails']['address']
        : _newAddressController.text;

    // Prepare food data
    final foodData = {
      'name': _nameController.text,
      'totalQuantity': int.parse(_quantityController.text),
      'minOrderQuantity': int.parse(_minOrderController.text),
      'time': _timeController.text,
      'timeUnit': _timeUnit,
      'pickupLocation': address,
      'exactLocation': {
        'type': 'Point',
        'coordinates': [_currentPosition!.longitude, _currentPosition!.latitude],
      },
      'companyName': widget.userData['supplierDetails']['companyName'],
    };

    // Make API call
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/food/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(foodData),
    );

    // Hide loading indicator
    Navigator.pop(context);

    // Handle response
    if (response.statusCode == 200 || response.statusCode == 201) {
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
    } else {
      final responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${responseData['msg'] ?? 'Failed to add food'}')),
      );
    }
  } catch (e) {
    // Hide loading indicator if still showing
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}

  void _showUserProfile(BuildContext context) {
    final bool isSupplier = widget.userData['type'] == 'Supplier';
    final supplierDetails = isSupplier ? widget.userData['supplierDetails'] as Map<String, dynamic>? : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {  // Explicitly added builder parameter
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/profilepic.jpg'),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      widget.userData['name']?.toString() ?? 'No name',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.userData['email']?.toString() ?? 'No email',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const Divider(thickness: 1, height: 30),
                    
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: Text('Role: ${widget.userData['type']?.toString() ?? 'Not specified'}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: Text('Phone: ${widget.userData['phone']?.toString() ?? 'Not provided'}'),
                    ),
                    
                    if (isSupplier && supplierDetails != null) ...[
                      ListTile(
                        leading: const Icon(Icons.business, color: Colors.orange),
                        title: Text(
                            'Company: ${supplierDetails['companyName']?.toString() ?? 'Not provided'}'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.red),
                        title: Text(
                            'Address: ${supplierDetails['address']?.toString() ?? 'Not provided'}'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.map, color: Colors.purple),
                        title: Text(
                            'State: ${supplierDetails['state']?.toString() ?? 'Not provided'}'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_city, color: Colors.teal),
                        title: Text(
                            'City: ${supplierDetails['city']?.toString() ?? 'Not provided'}'),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Edit Profile'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => const AuthScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: const Text('Logout',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}