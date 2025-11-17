import 'package:hive_ce/hive.dart';
import 'package:zenith/models/note.dart';

final notesBox = Hive.box<Note>('notes');
