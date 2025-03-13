import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/server/server_bloc.dart';
import '../../blocs/console/console_bloc.dart';
import 'widgets/console_history.dart';
import '../../common_widgets/command_input.dart';
import '../../common_widgets/server_status_indicator.dart';

class ConsoleScreen extends StatefulWidget {
  final String serverId;

  const ConsoleScreen({Key? key, required this.serverId}) : super(key: key);

  @override
  State<ConsoleScreen> createState() => _ConsoleScreenState();
}

class _ConsoleScreenState extends State<ConsoleScreen> {
  final TextEditingController _commandController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ServerBloc>().add(LoadServer(widget.serverId));
  }

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Console'),
        actions: [
          BlocBuilder<ServerBloc, ServerState>(
            builder: (context, state) {
              final isRunning = state is ServerLoaded && state.server.isRunning;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: ServerStatusIndicator(isRunning: isRunning),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Server controls
          BlocBuilder<ServerBloc, ServerState>(
            builder: (context, state) {
              final isRunning = state is ServerLoaded && state.server.isRunning;
              final isStarting = state is ServerStarting;
              final isStopping = state is ServerStopping;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isRunning || isStarting
                            ? null
                            : () {
                          context
                              .read<ServerBloc>()
                              .add(StartServer(widget.serverId));
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: Text(isStarting ? 'Avvio in corso...' : 'Avvia Server'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: !isRunning || isStopping
                            ? null
                            : () {
                          context
                              .read<ServerBloc>()
                              .add(StopServer(widget.serverId));
                        },
                        icon: const Icon(Icons.stop),
                        label: Text(isStopping ? 'Arresto in corso...' : 'Ferma Server'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Console output
          Expanded(
            child: ConsoleHistory(serverId: widget.serverId),
          ),

          // Command input
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: BlocBuilder<ServerBloc, ServerState>(
              builder: (context, state) {
                final isRunning = state is ServerLoaded && state.server.isRunning;

                return CommandInput(
                  controller: _commandController,
                  enabled: isRunning,
                  onSend: (command) {
                    if (command.isNotEmpty) {
                      context.read<ServerBloc>().add(
                        SendServerCommand(widget.serverId, command),
                      );
                      _commandController.clear();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}