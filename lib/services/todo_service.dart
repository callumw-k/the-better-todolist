import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_better_todolist/entities/todo.dart';
import 'package:the_better_todolist/repository/todo_repository.dart';

@injectable
class TodoService {
  final TodoRepository _todoRepository;

  final supabase = Supabase.instance.client;

  TodoService(this._todoRepository);

  Future<void> createTodo(String name) async {
    var currentIsoString = DateTime.now();

    var todo = Todo(name, false, currentIsoString, currentIsoString);

    final List<Map<String, dynamic>> data = await supabase
        .from('todos')
        .insert(todo.generateSupabaseTodo())
        .select();
    await _todoRepository.putAll(data.map((e) => Todo.fromMap(e)).toList());
  }

  Future<Todo?> getTodo(int id) async {
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
