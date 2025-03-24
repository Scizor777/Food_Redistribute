import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart'; // Import HomePage

void main() {
  runApp(const MyApp());
}

const String backendUrl = 'http://10.0.2.2:5000/api/auth';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _role;
  bool _isLogin = false;
  bool _showFields = false;

  Future<void> _authenticate() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String endpoint = _isLogin ? 'login' : 'signup';

    final response = await http.post(
      Uri.parse('$backendUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        if (!_isLogin) 'name': name,
        if (!_isLogin) 'phone': phone,
        if (!_isLogin) 'type': _role,
      }),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final userData = responseData['user']; // Extract user data

      // Navigate to HomePage with user details
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(userData: userData)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['msg'] ?? 'An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showFields)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _isLogin = false;
                      _showFields = true;
                    }),
                    child: const Text('Sign Up'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _isLogin = true;
                      _showFields = true;
                    }),
                    child: const Text('Log In'),
                  ),
                ],
              ),
            if (_showFields) ...[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              if (!_isLogin) ...[
                const SizedBox(height: 15),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField(
                  items: const [
                    DropdownMenuItem(value: 'Supplier', child: Text('Supplier')),
                    DropdownMenuItem(value: 'Consumer', child: Text('Consumer')),
                  ],
                  onChanged: (value) => setState(() => _role = value as String?),
                  decoration: InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                ),
              ],
              const SizedBox(height: 25),
              Center(
                child: ElevatedButton(
                  onPressed: _authenticate,
                  child: Text(_isLogin ? 'Log In' : 'Sign Up'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
