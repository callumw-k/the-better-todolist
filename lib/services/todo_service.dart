import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:the_better_todolist/entities/todo.dart';
import 'package:the_better_todolist/services/isar.dart';


@injectable
class TodoService {
  final IIsarService isarService;

  TodoService(this.isarService);

  Future<void> createTodo() async  {
    final db = isarService.db;
    await db.writeTxn(()async =>
        await db.todos.put(Todo("Hello", false))
    );
  }

  Future<List<Todo>> getTodos() async {
    return await isarService.db.todos.where().findAll();
  }

  Stream<List<Todo>> watchTodosCollection() {
    return isarService.db.todos.watchLazy().asyncMap((event)async => await getTodos());
  }
}
