import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/server_version.dart';
import '../screens/version_selector/version_selector_screen.dart';
import '../blocs/version_selector/version_selector_bloc.dart';
import '../../domain/usecases/download_server.dart';
import 'package:get_it/get_it.dart';

class ServerVersionField extends StatefulWidget {
  final ServerVersion? initialValue;
  final ValueChanged<ServerVersion>? onChanged;
  final String label;
  final String hint;
  final bool isRequired;

  const ServerVersionField({
    Key? key,
    this.initialValue,
    this.onChanged,
    this.label = 'Versione Server',
    this.hint = 'Seleziona una versione',
    this.isRequired = true,
  }) : super(key: key);

  @override
  State<ServerVersionField> createState() => _ServerVersionFieldState();
}

class _ServerVersionFieldState extends State<ServerVersionField> {
  ServerVersion? _selectedVersion;

  @override
  void initState() {
    super.initState();
    _selectedVersion = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label + (widget.isRequired ? ' *' : ''),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
        ],

        // Selection field
        InkWell(
          onTap: _openVersionSelector,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedVersion != null
                        ? _selectedVersion.toString()
                        : widget.hint,
                    style: TextStyle(
                      color: _selectedVersion != null
                          ? theme.textTheme.bodyLarge?.color
                          : theme.hintColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.iconTheme.color?.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openVersionSelector() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => GetIt.instance<VersionSelectorBloc>(),
          child: VersionSelectorScreen(
            showDownloadOption: false,
          ),
        ),
      ),
    );

    if (result != null && result is ServerVersion) {
      setState(() {
        _selectedVersion = result;
      });

      if (widget.onChanged != null) {
        widget.onChanged!(_selectedVersion!);
      }
    }
  }
}