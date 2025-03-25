import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/server_version.dart';
import '../../../domain/entities/server.dart';
import '../../blocs/version_selector/version_selector_bloc.dart';
import '../../themes/app_theme.dart';

class ServerDownloadScreen extends StatefulWidget {
  final Server server;
  final ServerVersion version;

  const ServerDownloadScreen({
    Key? key,
    required this.server,
    required this.version,
  }) : super(key: key);

  @override
  State<ServerDownloadScreen> createState() => _ServerDownloadScreenState();
}

class _ServerDownloadScreenState extends State<ServerDownloadScreen> {
  bool _downloadStarted = false;

  @override
  void initState() {
    super.initState();
    // Inizia automaticamente il download
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDownload();
    });
  }

  void _startDownload() {
    setState(() {
      _downloadStarted = true;
    });

    // Avvia il download usando il BLoC
    context.read<VersionSelectorBloc>().add(
      DownloadServerVersion(widget.version, widget.server.path),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Server'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intestazione
            Text(
              'Scaricamento di ${widget.version}',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),

            // Informazioni sul server
            _buildInfoCard(),
            const SizedBox(height: 24.0),

            // Stato download
            BlocBuilder<VersionSelectorBloc, VersionSelectorState>(
              builder: (context, state) {
                if (state is DownloadInProgress) {
                  return _buildProgressCard(state.progress);
                } else if (state is DownloadStarted) {
                  return _buildProgressCard(0.0);
                } else if (state is DownloadCompleted) {
                  return _buildSuccessCard();
                } else if (state is DownloadFailed) {
                  return _buildErrorCard(state.message);
                } else if (state is DownloadCancelled) {
                  return _buildCancelledCard();
                }

                // Non è stato avviato il download
                return _downloadStarted
                    ? _buildProgressCard(0.0)
                    : _buildReadyCard();
              },
            ),

            const Spacer(),

            // Pulsanti di azione
            BlocBuilder<VersionSelectorBloc, VersionSelectorState>(
              builder: (context, state) {
                final isInProgress = state is DownloadInProgress || state is DownloadStarted;
                final isCompleted = state is DownloadCompleted;
                final isFailed = state is DownloadFailed || state is DownloadCancelled;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isInProgress) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          context.read<VersionSelectorBloc>().add(CancelDownload());
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Annulla Download'),
                      ),
                    ] else if (isFailed) ...[
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Indietro'),
                      ),
                      const SizedBox(width: 16.0),
                      ElevatedButton.icon(
                        onPressed: _startDownload,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Riprova'),
                      ),
                    ] else if (isCompleted) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Fine'),
                      ),
                    ] else ...[
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Annulla'),
                      ),
                      const SizedBox(width: 16.0),
                      ElevatedButton.icon(
                        onPressed: _startDownload,
                        icon: const Icon(Icons.download),
                        label: const Text('Avvia Download'),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dns, size: 20),
                const SizedBox(width: 8.0),
                Text(
                  widget.server.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Versione', widget.version.toString()),
            _buildInfoRow('RAM', '${widget.server.ramAllocation} MB'),
            _buildInfoRow('Percorso', widget.server.path),
            _buildInfoRow('Porta', widget.server.port.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double progress) {
    final percentage = (progress * 100).toInt();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Download in corso...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Per favore non chiudere l\'applicazione fino al completamento del download.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Card(
      elevation: 2,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 8.0),
                Text(
                  'Download completato con successo!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Il tuo server è pronto per essere avviato. Vai alla console del server per iniziare.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red.shade700),
                const SizedBox(width: 8.0),
                Text(
                  'Errore durante il download',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(message),
            const SizedBox(height: 8.0),
            const Text(
              'Puoi riprovare il download o usare un file JAR esistente.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelledCard() {
    return Card(
      elevation: 2,
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cancel, color: Colors.orange.shade700),
                const SizedBox(width: 8.0),
                Text(
                  'Download annullato',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Il download è stato annullato. Puoi riprovare il download o usare un file JAR esistente.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pronto per il download',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Clicca sul pulsante "Avvia Download" per iniziare a scaricare il file del server.',
            ),
          ],
        ),
      ),
    );
  }
}