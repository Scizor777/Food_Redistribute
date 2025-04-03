import 'package:flutter/material.dart';

class FoodList extends StatelessWidget {
  final List<dynamic> foods;
  final bool isLoading;
  final String errorMessage;

  const FoodList({
    super.key,
    required this.foods,
    required this.isLoading,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    if (foods.isEmpty) {
      return const Center(child: Text('No food found in this radius'));
    }

    return ListView.builder(
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.fastfood, color: Colors.orange),
            title: Text(food['name'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('UplodedBy: ${food['companyName']}'),
                Text('Quantity: ${food['totalQuantity']}'),
                Text('Expires in: ${food['expiryHours']} hours'),
                if (food['distance'] != null)
                  Text('Distance: ${food['distance'].toStringAsFixed(1)} km'),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Handle food item tap
            },
          ),
        );
      },
    );
  }
}