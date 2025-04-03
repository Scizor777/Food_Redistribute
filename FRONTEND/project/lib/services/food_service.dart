import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'masterUrl.dart';

class FoodService {
  static Future<List<dynamic>> getFoodsInRadius(
      Position position, double radius) async {
    final response = await http.get(Uri.parse(
      '${masterUrl}/api/food/within-radius?'
      'latitude=${position.latitude}&'
      'longitude=${position.longitude}&'
      'radius=${radius * 1000}',
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['foods'] ?? [];
    }
    throw Exception('Failed to load foods: ${response.statusCode}');
  }

  static Future<void> addFoodDonation(Map<String, dynamic> foodData) async {
    final response = await http.post(
      Uri.parse('${masterUrl}/api/food/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(foodData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['msg'] ?? 'Failed to add food');
    }
  }
}