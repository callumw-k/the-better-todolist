import 'package:injectable/injectable.dart';
import 'package:the_better_todolist/entities/todo.dart';
import 'package:the_better_todolist/repository/base_repository.dart';

abstract class ITodoService {
  Future<Todo?> getTodo(int id);
}

@injectable
class TodoService<T> implements ITodoService {
  final IBaseRepository<Todo> _todoRepository;

  TodoService(this._todoRepository);

  Future<void> createTodo(List<Todo> todos) async =>
      await _todoRepository.putAll(todos);

  @override
  Future<Todo?> getTodo(int id) async => await _todoRepository.getById(id);

  Future<List<Todo>> getTodos() async => await _todoRepository.getAll();

  Stream<List<Todo>> watchTodosCollection() =>
      _todoRepository.watch().asyncMap((event) async => await getTodos());
}
