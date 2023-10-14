import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_better_todolist/entities/todo.dart';
import 'package:the_better_todolist/repository/todo_repository.dart';

@injectable
class TodoService {
  final TodoRepository _todoRepository;

  final supabase = Supabase.instance.client;

  TodoService(this._todoRepository);

  Future<List<Todo>> fetchTodos() async {
    final List<Map<String, dynamic>> data =
        await supabase.from('todos').select();
    return data.map((e) => Todo.fromMap(e)).toList();
  }

  // TODO: this code sucks and needs a rewrite
  Future<void> syncTodos() async {
    var cloudTodos = await fetchTodos();
    final localTodos = await _todoRepository.getAll();

    for (var localTodo in localTodos) {
      final cloudTodo = cloudTodos.firstWhere(
        (cloudTodo) {
          if (cloudTodo.id == localTodo.id) {
            cloudTodos.remove(cloudTodo);
            return true;
          }
          return false;
        },
        orElse: () => Todo.empty(),
      );

      if (cloudTodo.id.isEmpty) {
        await createTodoInSupabase(localTodo);
      } else if (cloudTodo.deletedAt != null) {
        await _todoRepository.deleteAll([localTodo.id]);
      } else if (cloudTodo.updatedAt.isAfter(localTodo.updatedAt)) {
        await _todoRepository.putAll([cloudTodo]);
      } else if (cloudTodo.updatedAt.isBefore(localTodo.updatedAt)) {
        await supabase.from('todos').upsert(localTodo.generateSupabaseTodo());
      }
    }

    final cloudTodosWithoutDeleted =
        cloudTodos.where((e) => e.deletedAt == null).toList();

    await _todoRepository.putAll(cloudTodosWithoutDeleted);
  }

  Future<void> createTodo(String name) async {
    var currentIsoString = DateTime.now();

    var todo = Todo(
      name: name,
      completed: false,
      createdAt: currentIsoString,
      updatedAt: currentIsoString,
    );

    final data = await createTodoInSupabase(todo);

    await _todoRepository.putAll(data.map((e) => Todo.fromMap(e)).toList());
  }

  Future<List<Map<String, dynamic>>> createTodoInSupabase(Todo todo) async {
    return await supabase
        .from('todos')
        .insert(todo.generateSupabaseTodo())
        .select();
  }

  Future<Todo?> getTodo(String id) async {
    return await _todoRepository.getById(id);
  }

  Future<List<Todo>> getTodos() async {
    return await _todoRepository.getAll();
  }

  Future<List<Todo>> sortTodosByDateAsc() async {
    return await _todoRepository.filterByDateAsc();
  }

  Stream<List<Todo>> watchTodosCollection() => _todoRepository
      .watch()
      .asyncMap((event) async => await sortTodosByDateAsc());
}
