import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constants/server_version.dart';
import '../../blocs/version_selector/version_selector_bloc.dart';
import '../../common_widgets/server_version_field.dart';
import '../../../core/constants/server_version.dart';
import '../../../domain/entities/server.dart';
import '../../themes/app_theme.dart';
import '../../blocs/server_list/server_list_bloc.dart';
import '../../blocs/version_selector/version_selector_bloc.dart';
import '../../common_widgets/server_version_field.dart';
import '../server_download/server_download_screen.dart';
import '../../themes/app_theme.dart';
import '../../screens/server_download/server_download_screen.dart';

class ServerCreationDialog extends StatefulWidget {
  const ServerCreationDialog({Key? key}) : super(key: key);

  @override
  State<ServerCreationDialog> createState() => _ServerCreationDialogState();
}

class _ServerCreationDialogState extends State<ServerCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pathController = TextEditingController();
  final _portController = TextEditingController(text: '25565');
  double _ramAllocation = 2048; // Default RAM: 2GB
  ServerVersion? _selectedVersion;
  bool _isDownloadNeeded = true;

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(32.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: 800, // Larghezza fissa del dialog
        constraints: const BoxConstraints(maxHeight: 600), // Altezza massima
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con titolo e pulsante di chiusura
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.dns, size: 24),
                  const SizedBox(width: 12.0),
                  const Text(
                    'Crea Nuovo Server',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form contenuto
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome server
                        _buildTextField(
                          controller: _nameController,
                          labelText: 'Nome Server *',
                          hintText: 'Es. Minecraft Survival',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Per favore inserisci un nome';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),

                        // Percorso server
                        _buildDirectoryField(),
                        const SizedBox(height: 24.0),

                        // Porta
                        _buildTextField(
                          controller: _portController,
                          labelText: 'Porta Server *',
                          hintText: '25565',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Per favore inserisci una porta';
                            }
                            final port = int.tryParse(value);
                            if (port == null || port < 1024 || port > 65535) {
                              return 'Porta non valida (1024-65535)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),

                        // Allocazione RAM
                        _buildRamAllocationField(),
                        const SizedBox(height: 24.0),

                        // Versione del server
                        ServerVersionField(
                          initialValue: _selectedVersion,
                          onChanged: (version) {
                            setState(() {
                              _selectedVersion = version;
                            });
                          },
                        ),
                        const SizedBox(height: 24.0),

                        // Download checkbox
                        CheckboxListTile(
                          title: const Text('Scarica il server alla creazione'),
                          subtitle: const Text('Altrimenti usare un JAR esistente nella directory'),
                          value: _isDownloadNeeded,
                          activeColor: AppTheme.primaryColor,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            setState(() {
                              _isDownloadNeeded = value ?? true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Pulsanti di azione
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annulla'),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: _createServer,
                    child: const Text('Crea Server'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDirectoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Directory del Server *',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _pathController,
                decoration: const InputDecoration(
                  hintText: 'Seleziona una directory',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore seleziona una directory';
                  }
                  return null;
                },
                readOnly: true,
              ),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: _pickDirectory,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRamAllocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Allocazione RAM',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
            Text(
              '${(_ramAllocation / 1024).toStringAsFixed(1)} GB',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Slider(
          value: _ramAllocation,
          min: 512,
          max: 8192,
          divisions: 16,
          activeColor: AppTheme.primaryColor,
          label: '${(_ramAllocation / 1024).toStringAsFixed(1)} GB',
          onChanged: (value) {
            setState(() {
              _ramAllocation = value;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('512 MB'),
            Text('8 GB'),
          ],
        ),
      ],
    );
  }

  void _pickDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        _pathController.text = selectedDirectory;
      });
    }
  }

  void _createServer() async {
    if (_formKey.currentState!.validate() && _selectedVersion != null) {
      final serverId = const Uuid().v4();
      final server = Server(
        id: serverId,
        name: _nameController.text,
        path: _pathController.text,
        ramAllocation: _ramAllocation.toInt(),
        isRunning: false,
        port: int.parse(_portController.text),
        version: _selectedVersion.toString(),
      );

      // Add server to the repository
      context.read<ServerListBloc>().add(AddServer(server));

      // Chiudi il dialog
      Navigator.of(context).pop();

      // If download is needed, navigate to download screen
      if (_isDownloadNeeded) {
        // Apri la schermata di download
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => GetIt.instance<VersionSelectorBloc>(),
              child: ServerDownloadScreen(
                server: server,
                version: _selectedVersion!,
              ),
            ),
          ),
        );
      }
    }
  }
}