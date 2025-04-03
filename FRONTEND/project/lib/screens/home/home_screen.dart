import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/user_model.dart';
import '../../services/location_service.dart';
import '../../services/food_service.dart';
import 'search_controls.dart';
import 'food_list.dart';
import 'add_food_form.dart';
import 'user_profile.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  List<dynamic> foods = [];
  bool isLoading = false;
  String errorMessage = '';
  double radius = 5;
  String sortBy = 'nearest';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => isLoading = true);
    try {
      _currentPosition = await LocationService.getCurrentLocation();
      if (_currentPosition != null) {
        await _fetchFoodsInRadius();
      } else {
        setState(() => errorMessage = 'Could not get current location');
      }
    } catch (e) {
      setState(() => errorMessage = 'Error getting location: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchFoodsInRadius() async {
    if (_currentPosition == null) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final fetchedFoods = await FoodService.getFoodsInRadius(
          _currentPosition!, radius);
      setState(() => foods = fetchedFoods);
    } catch (e) {
      setState(() => errorMessage = 'Error fetching foods: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showAddFoodForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddFoodForm(user: widget.user),
    ).then((_) => _fetchFoodsInRadius());
  }

  void _showUserProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => UserProfile(user: widget.user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: _showUserProfile,
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/profilepic.jpg'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SearchControls(
            radius: radius,
            sortBy: sortBy,
            onRadiusChanged: (value) => setState(() => radius = value),
            onSortChanged: (value) => setState(() => sortBy = value),
            onSearchPressed: _fetchFoodsInRadius,
          ),
          Expanded(
            child: FoodList(
              foods: foods,
              isLoading: isLoading,
              errorMessage: errorMessage,
            ),
          ),
          if (widget.user.type == 'Supplier')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _showAddFoodForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Add Food Donation',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}