import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../services/location_service.dart';
import 'home/home_screen.dart';
import '../services/masterUrl.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();

  String? _role;
  bool _isLogin = true;
  bool _showFields = false;
  bool _isLoading = false;
  String _errorMessage = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final endpoint = _isLogin ? 'login' : 'signup';
      final response = await http.post(
        Uri.parse('${masterUrl}/api/auth/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          if (!_isLogin) 'name': _nameController.text.trim(),
          if (!_isLogin) 'phone': _phoneController.text.trim(),
          if (!_isLogin) 'type': _role,
          if (!_isLogin && _role == 'Supplier') ...{
            'companyName': _companyNameController.text.trim(),
            'address': _addressController.text.trim(),
            'state': _stateController.text.trim(),
            'city': _cityController.text.trim(),
          }
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await LocationService.getCurrentLocation();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              user: User.fromMap(responseData['user']),
            ),
          ),
        );
      } else {
        setState(() => _errorMessage = responseData['msg'] ?? 'Authentication failed');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to connect to server');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            children: [
              if (!_showFields) ...[
                _buildAuthOptionButton('Sign Up', false),
                const SizedBox(height: 10),
                _buildAuthOptionButton('Log In', true),
              ],
              if (_showFields) ...[
                _buildTextField('Email', _emailController, Icons.email, false, 
                  (value) => value!.contains('@') ? null : 'Invalid email'),
                const SizedBox(height: 15),
                _buildTextField('Password', _passwordController, Icons.lock, true,
                  (value) => value!.length >= 4 ? null : 'Minimum 4 characters'),
                if (!_isLogin) _buildRegistrationFields(),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                _buildAuthButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthOptionButton(String text, bool isLogin) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () => setState(() {
          _isLogin = isLogin;
          _showFields = true;
        }),
        child: Text(text),
      ),
    );
  }

  Widget _buildRegistrationFields() {
    return Column(
      children: [
        const SizedBox(height: 15),
        _buildTextField('Name', _nameController, Icons.person, false,
          (value) => value!.isEmpty ? 'Required' : null),
        const SizedBox(height: 15),
        _buildTextField('Phone', _phoneController, Icons.phone, false,
          (value) => value!.isEmpty ? 'Required' : null, TextInputType.phone),
        const SizedBox(height: 15),
        DropdownButtonFormField<String>(
          value: _role,
          items: const [
            DropdownMenuItem(value: 'Supplier', child: Text('Supplier')),
            DropdownMenuItem(value: 'Consumer', child: Text('Consumer')),
          ],
          onChanged: (value) => setState(() => _role = value),
          decoration: const InputDecoration(labelText: 'Type'),
          validator: (value) => value == null ? 'Please select a type' : null,
        ),
        if (_role == 'Supplier') ...[
          const SizedBox(height: 15),
          _buildTextField('Company', _companyNameController, Icons.business, false,
            (value) => value!.isEmpty ? 'Required' : null),
          const SizedBox(height: 15),
          _buildTextField('Address', _addressController, Icons.location_on, false,
            (value) => value!.isEmpty ? 'Required' : null),
          const SizedBox(height: 15),
          _buildTextField('State', _stateController, Icons.map, false,
            (value) => value!.isEmpty ? 'Required' : null),
          const SizedBox(height: 15),
          _buildTextField('City', _cityController, Icons.location_city, false,
            (value) => value!.isEmpty ? 'Required' : null),
        ],
      ],
    );
  }

  Widget _buildAuthButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: _isLoading ? null : _authenticate,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(_isLogin ? 'Log In' : 'Sign Up'),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool obscure,
    FormFieldValidator<String> validator, [
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
}