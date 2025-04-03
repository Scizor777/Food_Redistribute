import 'package:flutter/material.dart';

class SearchControls extends StatelessWidget {
  final double radius;
  final String sortBy;
  final ValueChanged<double> onRadiusChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onSearchPressed;

  const SearchControls({
    super.key,
    required this.radius,
    required this.sortBy,
    required this.onRadiusChanged,
    required this.onSortChanged,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Radius Slider
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Radius: ${radius.toStringAsFixed(1)} km'),
                Slider(
                  value: radius,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: radius.toStringAsFixed(1),
                  onChanged: onRadiusChanged,
                ),
              ],
            ),
          ),

          // Search Button
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text(''),
                onPressed: onSearchPressed,
              ),
            ),
          ),

          // Sort Dropdown
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: sortBy,
              items: const [
                DropdownMenuItem(
                  value: 'nearest',
                  child: Text('Nearest'),
                ),
                DropdownMenuItem(
                  value: 'fresh',
                  child: Text('Freshest'),
                ),
              ],
              onChanged: (value) {
                if (value != null) onSortChanged(value);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}