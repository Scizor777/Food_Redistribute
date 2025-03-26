import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart'; // Import HomePage
import 'masterUrl.dart';

void main() {
  runApp(const MyApp());
}

const String backendUrl = '${masterUrl}/api/auth';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth UI',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.orange.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.orange),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
          ),
        ),
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
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  String? _role;
  bool _isLogin = false;
  bool _showFields = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String companyName = _companyNameController.text.trim();
    String address = _addressController.text.trim();
    String state = _stateController.text.trim();
    String city = _cityController.text.trim();

    String endpoint = _isLogin ? 'login' : 'signup';

    Map<String, dynamic> body = {
      'email': email,
      'password': password,
      if (!_isLogin) 'name': name,
      if (!_isLogin) 'phone': phone,
      if (!_isLogin) 'type': _role,
      if (!_isLogin && _role == 'Supplier') ...{
        'companyName': companyName,
        'address': address,
        'state': state,
        'city': city,
      }
    };

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final userData = responseData['user'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userData: userData)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['msg'] ?? 'An error occurred')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
        leading: _showFields
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _showFields = false),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!_showFields)
                Column(
                  children: [
                    _buildButton('Sign Up', () => setState(() {
                          _isLogin = false;
                          _showFields = true;
                        })),
                    const SizedBox(height: 10),
                    _buildButton('Log In', () => setState(() {
                          _isLogin = true;
                          _showFields = true;
                        })),
                  ],
                ),
              if (_showFields) ...[
                _buildTextField('Email', _emailController, Icons.email, false, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                }),
                const SizedBox(height: 15),
                _buildTextField('Password', _passwordController, Icons.lock, true, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 4) {
                    return 'Password must be at least 4 characters';
                  }
                  return null;
                }),
                if (!_isLogin) ...[
                  const SizedBox(height: 15),
                  _buildTextField('Name', _nameController, Icons.person, false, (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  }),
                  const SizedBox(height: 15),
                  _buildTextField('Phone Number', _phoneController, Icons.phone, false, (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  }, TextInputType.phone),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _role,
                    items: const [
                      DropdownMenuItem(value: 'Supplier', child: Text('Supplier')),
                      DropdownMenuItem(value: 'Consumer', child: Text('Consumer')),
                    ],
                    onChanged: (value) => setState(() => _role = value),
                    decoration: const InputDecoration(labelText: 'Type'),
                    validator: (value) {
                      if (!_isLogin && (value == null || value.isEmpty)) {
                        return 'Please select a type';
                      }
                      return null;
                    },
                  ),
                  if (_role == 'Supplier') ...[
                    const SizedBox(height: 15),
                    _buildTextField('Company Name', _companyNameController, Icons.business, false, (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter company name';
                      }
                      return null;
                    }),
                    const SizedBox(height: 15),
                    _buildTextField('Address', _addressController, Icons.location_on, false, (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    }),
                    const SizedBox(height: 15),
                    _buildTextField('State', _stateController, Icons.map, false, (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter state';
                      }
                      return null;
                    }),
                    const SizedBox(height: 15),
                    _buildTextField('City', _cityController, Icons.location_city, false, (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter city';
                      }
                      return null;
                    }),
                  ],
                ],
                const SizedBox(height: 25),
                _buildButton(_isLogin ? 'Log In' : 'Sign Up', _authenticate),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool obscure,
    FormFieldValidator<String>? validator, [
    TextInputType type = TextInputType.text,
  ]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange.shade700),
      ),
      obscureText: obscure,
      keyboardType: type,
      validator: validator,
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}