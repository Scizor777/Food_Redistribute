import 'package:flutter/material.dart';
import 'main.dart'; // Import Main to navigate back

class HomePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const HomePage({super.key, required this.userData});

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
      body: const Center(
        child: Text(
          'Welcome to Home Page!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showUserProfile(BuildContext context) {
    final bool isSupplier = userData['type'] == 'Supplier';
    final supplierDetails = isSupplier ? userData['supplierDetails'] as Map<String, dynamic>? : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
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
                      userData['name']?.toString() ?? 'No name',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userData['email']?.toString() ?? 'No email',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const Divider(thickness: 1, height: 30),
                    
                    // Common fields for all users
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: Text('Role: ${userData['type']?.toString() ?? 'Not specified'}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: Text('Phone: ${userData['phone']?.toString() ?? 'Not provided'}'),
                    ),
                    
                    // Supplier-specific fields
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
                      onPressed: () {
                        // Edit profile functionality
                      },
                      child: const Text('Edit Profile'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthScreen()),
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