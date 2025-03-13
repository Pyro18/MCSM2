import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/console/console_bloc.dart';

class ConsoleHistory extends StatefulWidget {
  final String serverId;

  const ConsoleHistory({
    Key? key,
    required this.serverId,
  }) : super(key: key);

  @override
  State<ConsoleHistory> createState() => _ConsoleHistoryState();
}

class _ConsoleHistoryState extends State<ConsoleHistory> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    context.read<ConsoleBloc>().add(StartConsoleStreaming(widget.serverId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    context.read<ConsoleBloc>().add(StopConsoleStreaming());
    super.dispose();
  }

  void _scrollToBottom() {
    if (_autoScroll && _scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConsoleBloc, ConsoleState>(
      listener: (context, state) {
        if (state is ConsoleUpdated) {
          // Scorrimento automatico alla fine quando ci sono nuovi messaggi
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      },
      builder: (context, state) {
        final outputLines = state is ConsoleUpdated ? state.outputLines : <String>[];

        return Column(
          children: [
            // Console Output
            Expanded(
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: outputLines.length,
                  itemBuilder: (context, index) {
                    final line = outputLines[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                          children: _parseConsoleLine(line),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Auto-scroll control
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Auto-scroll:',
                    style: TextStyle(fontSize: 12),
                  ),
                  Switch(
                    value: _autoScroll,
                    onChanged: (value) {
                      setState(() {
                        _autoScroll = value;
                      });
                      if (_autoScroll) {
                        _scrollToBottom();
                      }
                    },
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.delete_sweep, size: 16),
                    label: const Text('Clear', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      context.read<ConsoleBloc>().add(ClearConsole());
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<TextSpan> _parseConsoleLine(String line) {
    List<TextSpan> spans = [];

    // Timestamp pattern [HH:MM:SS]
    final timestampRegex = RegExp(r'^\[(\d{2}:\d{2}:\d{2})\]');
    final timestampMatch = timestampRegex.firstMatch(line);

    if (timestampMatch != null) {
      spans.add(
        TextSpan(
          text: "[${timestampMatch.group(1)}] ",
          style: TextStyle(
            color: Colors.grey[500],
          ),
        ),
      );

      line = line.substring(timestampMatch.end);
    }

    // Log level pattern [INFO], [WARN], [ERROR]
    final levelRegex = RegExp(r'^\[([A-Z]+)\]');
    final levelMatch = levelRegex.firstMatch(line);

    if (levelMatch != null) {
      final level = levelMatch.group(1);
      Color levelColor;

      switch (level) {
        case "WARN":
          levelColor = Colors.orange;
          break;
        case "ERROR":
          levelColor = Colors.red;
          break;
        case "INFO":
        default:
          levelColor = Colors.lightBlue;
      }

      spans.add(
        TextSpan(
          text: "[$level] ",
          style: TextStyle(
            color: levelColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      line = line.substring(levelMatch.end);
    }

    // Player join/leave messages have special colors
    if (line.contains("joined the game")) {
      spans.add(
        TextSpan(
          text: line,
          style: const TextStyle(
            color: Colors.green,
          ),
        ),
      );
    } else if (line.contains("left the game") || line.contains("lost connection")) {
      spans.add(
        TextSpan(
          text: line,
          style: const TextStyle(
            color: Colors.yellow,
          ),
        ),
      );
    } else if (line.startsWith('>')) {
      spans.add(
        TextSpan(
          text: line,
          style: const TextStyle(
            color: Colors.cyan,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      spans.add(
        TextSpan(
          text: line,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      );
    }

    return spans;
  }
}