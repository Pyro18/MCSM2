import 'package:flutter/material.dart';

class CommandInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final bool enabled;

  const CommandInput({
    Key? key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              decoration: const InputDecoration(
                hintText: 'Digita un comando...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
              onSubmitted: enabled ? onSend : null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: enabled
                ? () {
              onSend(controller.text);
            }
                : null,
            color: enabled ? theme.colorScheme.primary : theme.disabledColor,
          ),
        ],
      ),
    );
  }
}