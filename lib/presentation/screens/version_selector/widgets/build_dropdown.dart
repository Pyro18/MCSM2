import 'package:flutter/material.dart';

class BuildDropdown extends StatelessWidget {
  final List<int> builds;
  final int? selectedBuild;
  final ValueChanged<int?>? onChanged;

  const BuildDropdown({
    Key? key,
    required this.builds,
    this.selectedBuild,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ordina le build in ordine decrescente per mostrare prima le più recenti
    final sortedBuilds = List<int>.from(builds)..sort((a, b) => b.compareTo(a));

    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      isExpanded: true,
      value: selectedBuild,
      hint: const Text('Seleziona una build (opzionale)'),
      items: [
        // Opzione Latest Build
        DropdownMenuItem<int>(
          value: null,
          child: Row(
            children: [
              const Icon(Icons.autorenew, size: 16),
              const SizedBox(width: 8),
              Text(
                'Latest Build (${sortedBuilds.isNotEmpty ? sortedBuilds.first : "N/A"})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        // Divider
        const DropdownMenuItem<int>(
          enabled: false,
          child: Divider(),
        ),
        // Build specifiche
        ...sortedBuilds.map((build) {
          return DropdownMenuItem<int>(
            value: build,
            child: Text('Build $build'),
          );
        }).toList(),
      ],
      onChanged: onChanged,
    );
  }
}