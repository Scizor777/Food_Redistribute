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
              backgroundImage: AssetImage('assets/profilepic.jpg'), // Profile picture
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows full-screen height
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6, // Larger size
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profilepic.jpg'), // Profile Image
              ),
              const SizedBox(height: 15),
              Text(
                userData['name'],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                userData['email'],
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Divider(thickness: 1, height: 30),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: Text('Role: ${userData['type']}'),
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: Text('Phone: ${userData['phone']}'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Future update functionality
                },
                child: const Text('Edit Profile'),
              ),
              const Spacer(), // Pushes logout button to bottom
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false, // Removes all previous pages from stack
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red logout button
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text('Logout', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),

            ],
          ),
        );
      },
    );
  }
}
