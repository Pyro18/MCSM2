import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

import '/../../core/constants/server_version.dart';
import '../../../blocs/version_selector/version_selector_bloc.dart';
import '../../version_selector/widgets/version_dropdown.dart';
import '../../version_selector/widgets/build_dropdown.dart';
import '../../version_selector/widgets/download_progress.dart';
import '../../../themes/app_theme.dart';

class ServerDownloadUtilityScreen extends StatefulWidget {
  const ServerDownloadUtilityScreen({Key? key}) : super(key: key);

  @override
  State<ServerDownloadUtilityScreen> createState() => _ServerDownloadUtilityScreenState();
}

class _ServerDownloadUtilityScreenState extends State<ServerDownloadUtilityScreen> {
  String? selectedVersion;
  int? selectedBuild;
  String serverType = 'paper';
  final TextEditingController _pathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<VersionSelectorBloc>().add(const LoadPaperVersions());
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Server'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo di server
            const Text(
              'Tipo di Server',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'paper',
                  label: Text('Paper'),
                  icon: Icon(Icons.description),
                ),
                ButtonSegment(
                  value: 'spigot',
                  label: Text('Spigot'),
                  icon: Icon(Icons.extension),
                ),
              ],
              selected: {serverType},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  serverType = selection.first;
                  selectedVersion = null;
                  selectedBuild = null;
                });
                if (serverType == 'paper') {
                  context.read<VersionSelectorBloc>().add(const LoadPaperVersions());
                }
              },
            ),
            const SizedBox(height: 24.0),

            // Versione del server
            const Text(
              'Versione',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            BlocBuilder<VersionSelectorBloc, VersionSelectorState>(
              builder: (context, state) {
                if (state is VersionsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is VersionsLoaded) {
                  return VersionDropdown(
                    versions: state.versions,
                    selectedVersion: selectedVersion,
                    onChanged: (value) {
                      setState(() {
                        selectedVersion = value;
                        selectedBuild = null;
                      });
                      if (value != null) {
                        context.read<VersionSelectorBloc>().add(LoadPaperBuilds(value));
                      }
                    },
                  );
                } else if (state is VersionsError) {
                  return Text(
                    'Errore: ${state.message}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  );
                }
                return const SizedBox();
              },
            ),
            const SizedBox(height: 24.0),

            // Build (solo per Paper)
            if (serverType == 'paper' && selectedVersion != null) ...[
              const Text(
                'Build',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8.0),
              BlocBuilder<VersionSelectorBloc, VersionSelectorState>(
                builder: (context, state) {
                  if (state is BuildsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BuildsLoaded && state.version == selectedVersion) {
                    return BuildDropdown(
                      builds: state.builds,
                      selectedBuild: selectedBuild,
                      onChanged: (value) {
                        setState(() {
                          selectedBuild = value;
                        });
                      },
                    );
                  } else if (state is BuildsError) {
                    return Text(
                      'Errore: ${state.message}',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 24.0),
            ],

            // Percorso di installazione
            const Text(
              'Percorso di Installazione',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pathController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Seleziona una directory',
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: _pickDirectory,
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Stato download
            BlocBuilder<VersionSelectorBloc, VersionSelectorState>(
              builder: (context, state) {
                if (state is DownloadInProgress) {
                  return DownloadProgress(
                    progress: state.progress,
                    onCancel: () {
                      context.read<VersionSelectorBloc>().add(CancelDownload());
                    },
                  );
                } else if (state is DownloadStarted) {
                  return const Text('Download avviato...');
                } else if (state is DownloadCompleted) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Download completato con successo!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is DownloadFailed) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Errore durante il download',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(state.message),
                      ],
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pronto per il download',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Seleziona una versione e un percorso per scaricare il server.',
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24.0),

            // Pulsante di download
            BlocBuilder<VersionSelectorBloc, VersionSelectorState>(
              builder: (context, state) {
                final bool isDownloading = state is DownloadInProgress || state is DownloadStarted;
                final bool isCompleted = state is DownloadCompleted;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(isCompleted ? Icons.check : Icons.download),
                    label: Text(isCompleted ? 'Download Completato' : 'Scarica Server'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted ? Colors.green : AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: (selectedVersion != null &&
                        _pathController.text.isNotEmpty &&
                        !isDownloading &&
                        !isCompleted)
                        ? _startDownload
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
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

  void _startDownload() {
    final version = _createServerVersion();
    context.read<VersionSelectorBloc>().add(
      DownloadServerVersion(version, _pathController.text),
    );
  }

  ServerVersion _createServerVersion() {
    switch (serverType) {
      case 'paper':
        return ServerVersion.paper(
          selectedVersion!,
          build: selectedBuild?.toString(),
        );
      case 'spigot':
        return ServerVersion.spigot(selectedVersion!);
      default:
        return ServerVersion.vanilla(selectedVersion!);
    }
  }
}