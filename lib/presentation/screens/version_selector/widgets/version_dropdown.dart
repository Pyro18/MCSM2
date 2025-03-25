import 'package:flutter/material.dart';

class VersionDropdown extends StatelessWidget {
  final List<String> versions;
  final String? selectedVersion;
  final ValueChanged<String?>? onChanged;

  const VersionDropdown({
    Key? key,
    required this.versions,
    this.selectedVersion,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inverti l'ordine delle versioni per mostrare prima le più recenti
    final sortedVersions = List<String>.from(versions)
      ..sort((a, b) => _compareVersions(b, a)); // Ordine decrescente

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      isExpanded: true,
      value: selectedVersion,
      hint: const Text('Seleziona una versione'),
      items: sortedVersions.map((version) {
        return DropdownMenuItem<String>(
          value: version,
          child: Text(version),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Compara due versioni semantiche
  int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Parts = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Aggiungi zeri per rendere le liste della stessa lunghezza
    while (v1Parts.length < v2Parts.length) {
      v1Parts.add(0);
    }
    while (v2Parts.length < v1Parts.length) {
      v2Parts.add(0);
    }

    // Confronta ogni componente della versione
    for (int i = 0; i < v1Parts.length; i++) {
      final comp = v1Parts[i].compareTo(v2Parts[i]);
      if (comp != 0) {
        return comp;
      }
    }

    return 0; // Versioni identiche
  }
}