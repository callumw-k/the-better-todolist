import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:the_better_todolist/entities/todo.dart';
import 'package:the_better_todolist/repository/base_repository.dart';
import 'package:the_better_todolist/services/isar.dart';

abstract class TodoRepository extends IBaseRepository<Todo> {
  Future<List<Todo>> filterByDateAsc();
}

@Injectable(as: TodoRepository)
class TodoRepositoryImpl extends BaseRepositoryImpl<Todo>
    implements TodoRepository {
  final IIsarService _isarService;

  TodoRepositoryImpl(this._isarService)
      : super(_isarService.db.todos, _isarService);

  @override
  Future<List<Todo>> filterByDateAsc() async {
    return await _isarService.db.todos.where().sortByUpdatedAtDesc().findAll();
  }
}
