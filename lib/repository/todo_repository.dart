import 'package:injectable/injectable.dart';
import 'package:the_better_todolist/entities/todo.dart';
import 'package:the_better_todolist/repository/base_repository.dart';
import 'package:the_better_todolist/services/isar.dart';

@Injectable(as: IBaseRepository<Todo>)
class TodoRepository extends BaseRepositoryImpl<Todo> {
  TodoRepository(IIsarService isarService)
      : super(isarService.db.todos, isarService);
}
