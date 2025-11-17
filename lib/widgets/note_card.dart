import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:zenith/hive/boxes.dart';
import 'package:zenith/models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;

  const NoteCard({super.key, required this.note, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.cardStyle.decoration.color,
      child: InkWell(
        onTap: onTap,
        // onLongPressUp: () => controller.toggle(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: context.theme.cardStyle.decoration.copyWith(
            color: Colors.transparent,
          ),
          child: Dismissible(
            onDismissed: (_) => notesBox.delete(note.id),
            key: ValueKey(note.id),
            direction: DismissDirection.startToEnd,
            background: Container(
              alignment: Alignment.centerLeft,
              padding: .symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: context.theme.colors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                FIcons.trash,
                color: context.theme.colors.errorForeground,
              ),
            ),
            child: Padding(
              padding: context.theme.cardStyle.contentStyle.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (note.title != null) ...[
                    Text(
                      note.title!,
                      style:
                          context.theme.cardStyle.contentStyle.titleTextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                  ],
                  Text(
                    _formattedCreatedAt(note.createdAt),
                    style:
                        context.theme.cardStyle.contentStyle.subtitleTextStyle,
                  ),
                  SizedBox(height: 4),
                  Text(
                    Document.fromJson(jsonDecode(note.content)).toPlainText(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add this private helper inside the NoteCard class:
  String _formattedCreatedAt(DateTime createdAt) {
    final created = createdAt.toLocal();
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    if (created.year == now.year &&
        created.month == now.month &&
        created.day == now.day) {
      return 'Today, ${DateFormat('HH:mm').format(created)}';
    } else if (created.year == yesterday.year &&
        created.month == yesterday.month &&
        created.day == yesterday.day) {
      return 'Yesterday, ${DateFormat('HH:mm').format(created)}';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(created);
    }
  }
}
