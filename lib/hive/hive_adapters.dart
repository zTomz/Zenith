import 'package:hive_ce/hive.dart';
import 'package:zenith/models/note.dart';


@GenerateAdapters([AdapterSpec<Note>()])
part 'hive_adapters.g.dart';
