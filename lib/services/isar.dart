import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:the_better_todolist/entities/todo.dart';

abstract class IIsarService {
  Isar get db;
}

@Singleton(as: IIsarService)
class IsarService implements IIsarService {

  @override
  late final Isar db;

  IsarService._(this.db);

  @FactoryMethod(preResolve: true)
  static Future<IsarService> create() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final db = await Isar.open([TodoSchema], directory: dir.path);
      return IsarService._(db);
    } catch (e) {
      // Handle errors, maybe throw a custom exception
      throw Exception("Failed to initialize Isar database: $e");
    }
  }
}
