import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:zenith/hive/boxes.dart';
import 'package:zenith/models/note.dart';
import 'package:zenith/widgets/note_card.dart';

enum SortOption { mostRecent, oldest, titleAsc, titleDesc }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  SortOption _sortOption = SortOption.mostRecent;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Note> _filterAndSortNotes(List<Note> notes) {
    // Filter by search query
    var filteredNotes = notes.where((note) {
      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      final title = (note.title ?? '').toLowerCase();
      final content = Document.fromJson(
        jsonDecode(note.content),
      ).toPlainText().toLowerCase();

      return title.contains(query) || content.contains(query);
    }).toList();

    // Sort notes
    switch (_sortOption) {
      case SortOption.mostRecent:
        filteredNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.oldest:
        filteredNotes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.titleAsc:
        filteredNotes.sort((a, b) {
          final aTitle = (a.title ?? '').toLowerCase();
          final bTitle = (b.title ?? '').toLowerCase();
          return aTitle.compareTo(bTitle);
        });
        break;
      case SortOption.titleDesc:
        filteredNotes.sort((a, b) {
          final aTitle = (a.title ?? '').toLowerCase();
          final bTitle = (b.title ?? '').toLowerCase();
          return bTitle.compareTo(aTitle);
        });
        break;
    }

    return filteredNotes;
  }

  String _getSortOptionLabel(SortOption option) {
    switch (option) {
      case SortOption.mostRecent:
        return 'Most Recent';
      case SortOption.oldest:
        return 'Oldest';
      case SortOption.titleAsc:
        return 'Title A-Z';
      case SortOption.titleDesc:
        return 'Title Z-A';
    }
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) => FDialog(
        title: const Text('Sort by'),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: SortOption.values.map((option) {
            final isSelected = _sortOption == option;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FButton(
                onPress: () {
                  setState(() {
                    _sortOption = option;
                  });
                  Navigator.pop(context);
                },
                style: isSelected
                    ? FButtonStyle.primary()
                    : FButtonStyle.outline(),
                prefix: isSelected ? Icon(FIcons.check) : null,
                child: Text(_getSortOptionLabel(option)),
              ),
            );
          }).toList(),
        ),
        actions: const [],
      ),
    );
  }

  Widget _buildEmptyState({bool isSearchResult = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearchResult ? FIcons.searchX : FIcons.fileText,
              size: 64,
              color: context.theme.colors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              isSearchResult ? 'No notes found' : 'No notes yet',
              style: context.theme.typography.xl2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearchResult
                  ? 'Try adjusting your search terms'
                  : 'Create your first note to get started',
              style: context.theme.typography.base.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isSearchResult) ...[
              const SizedBox(height: 24),
              FButton(
                onPress: () => context.pushNamed('note'),
                style: FButtonStyle.primary(),
                prefix: Icon(FIcons.plus),
                child: const Text('Create your first note'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      resizeToAvoidBottomInset: false,
      header: FHeader(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, -0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _isSearching
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: TextField(
                      key: const ValueKey('searchField'),
                      controller: _searchController,
                      autofocus: true,
                      style: context.theme.typography.lg,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Search notes...',
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: context.theme.typography.lg.copyWith(
                          color: context.theme.colors.mutedForeground,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                )
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your Notes',
                    key: const ValueKey('title'),
                    style: context.theme.typography.xl2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
        suffixes: [
          FButton.icon(
            onPress: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
            style: FButtonStyle.ghost(),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: child.key == const ValueKey('close')
                    ? Tween<double>(begin: 0.75, end: 1).animate(anim)
                    : Tween<double>(begin: 0.75, end: 1).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                _isSearching ? FIcons.x : FIcons.search,
                key: ValueKey(_isSearching ? 'close' : 'search'),
              ),
            ),
          ),
          if (!_isSearching)
            FButton.icon(
              onPress: _showSortOptions,
              style: FButtonStyle.ghost(),
              child: Icon(FIcons.listFilter),
            ),
        ],
      ),
      child: Column(
        children: [
          if (_sortOption != SortOption.mostRecent)
            Padding(
              padding: .only(bottom: 8),
              child: FAlert(
                title: Text('Sorted by: ${_getSortOptionLabel(_sortOption)}'),
                style: FAlertStyle.primary(),
              ),
            ),
          Expanded(
            child: StreamBuilder(
              initialData: notesBox.values.toList(),
              stream: notesBox.watch(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.hasError) {
                  log("Error loading notes: ${asyncSnapshot.error}");

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: FAlert(
                        title: const Text('Heads Up!'),
                        subtitle: const Text(
                          'There was an error loading your notes. Please try again by reopening the app.',
                        ),
                        style: FAlertStyle.destructive(),
                      ),
                    ),
                  );
                }

                final allNotes = notesBox.values.toList();
                final filteredNotes = _filterAndSortNotes(allNotes);

                if (allNotes.isEmpty) {
                  return _buildEmptyState();
                }

                if (filteredNotes.isEmpty) {
                  return _buildEmptyState(isSearchResult: true);
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: MasonryGridView.count(
                    key: ValueKey(_sortOption.toString() + _searchQuery),
                    // padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    padding: .only(top: 0),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return NoteCard(
                        note: note,
                        onTap: () => context.pushNamed('note', extra: note),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          FButton(
            onPress: () => context.pushNamed('note'),
            style: FButtonStyle.outline(),
            prefix: Icon(FIcons.plus),
            child: const Text("Add note"),
          ),
        ],
      ),
    );
  }
}
