import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/server_version.dart';
import '../../blocs/version_selector/version_selector_bloc.dart';
import 'widgets/version_dropdown.dart';
import 'widgets/build_dropdown.dart';
import 'widgets/download_progress.dart';

class VersionSelectorScreen extends StatefulWidget {
  final Function(ServerVersion)? onVersionSelected;
  final String? initialPath;
  final bool showDownloadOption;

  const VersionSelectorScreen({
    Key? key,
    this.onVersionSelected,
    this.initialPath,
    this.showDownloadOption = true,
  }) : super(key: key);

  @override
  State<VersionSelectorScreen> createState() => _VersionSelectorScreenState();
}

class _VersionSelectorScreenState extends State<VersionSelectorScreen> {
  String? selectedVersion;
  int? selectedBuild;
  String serverType = 'paper';
  final TextEditingController _pathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPath != null) {
      _pathController.text = widget.initialPath!;
    }
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
        title: const Text('Seleziona Versione Server'),
      ),
      body: Padding(
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
            const SizedBox(height: 16.0),

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
            const SizedBox(height: 16.0),

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
              const SizedBox(height: 16.0),
            ],

            // Percorso di installazione
            if (widget.showDownloadOption) ...[
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
                        hintText: 'Percorso dove installare il server',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () async {
                      // Si potrebbe aggiungere un file picker qui
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ],

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
                  return const Text(
                    'Download completato con successo!',
                    style: TextStyle(color: Colors.green),
                  );
                } else if (state is DownloadFailed) {
                  return Text(
                    'Errore: ${state.message}',
                    style: TextStyle(color: Colors.red),
                  );
                }
                return const SizedBox();
              },
            ),

            const Spacer(),

            // Pulsanti di azione
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.showDownloadOption) ...[
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annulla'),
                  ),
                  const SizedBox(width: 16.0),
                  BlocBuilder<VersionSelectorBloc, VersionSelectorState>(
                    builder: (context, state) {
                      final bool isDownloading = state is DownloadInProgress || state is DownloadStarted;

                      return ElevatedButton(
                        onPressed: (selectedVersion != null && _pathController.text.isNotEmpty && !isDownloading)
                            ? () {
                          final version = _createServerVersion();
                          context.read<VersionSelectorBloc>().add(
                            DownloadServerVersion(version, _pathController.text),
                          );
                        }
                            : null,
                        child: const Text('Download Server'),
                      );
                    },
                  ),
                ] else ...[
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annulla'),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: selectedVersion != null
                        ? () {
                      final version = _createServerVersion();
                      if (widget.onVersionSelected != null) {
                        widget.onVersionSelected!(version);
                      }
                      Navigator.of(context).pop(version);
                    }
                        : null,
                    child: const Text('Seleziona'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
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