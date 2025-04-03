import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../screens/auth_screen.dart';

class UserProfile extends StatelessWidget {
  final User user;

  const UserProfile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final bool isSupplier = user.type == 'Supplier';

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
                  user.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Divider(thickness: 1, height: 30),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text('Role: ${user.type}'),
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.green),
                  title: Text('Phone: ${user.phone}'),
                ),
                if (isSupplier && user.supplierDetails != null) ...[
                  ListTile(
                    leading: const Icon(Icons.business, color: Colors.orange),
                    title: Text(
                        'Company: ${user.supplierDetails!['companyName']}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: Text('Address: ${user.supplierDetails!['address']}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.map, color: Colors.purple),
                    title: Text('State: ${user.supplierDetails!['state']}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_city, color: Colors.teal),
                    title: Text('City: ${user.supplierDetails!['city']}'),
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
                          builder: (BuildContext context) =>
                              const AuthScreen()),
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
  }
}