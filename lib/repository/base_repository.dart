import 'package:isar/isar.dart';
import 'package:the_better_todolist/entities/todo.dart';
import 'package:the_better_todolist/services/isar.dart';

abstract class IBaseRepository<T> {
  Future<T?> getById(String id);

  Stream<void> watch();

  Future<List<T>> getAll();

  Future<void> putAll(List<T> items);

  Future<void> deleteAll(List<String> ids);
}

abstract class BaseRepositoryImpl<T> implements IBaseRepository<T> {
  final IIsarService _isarService;
  final IsarCollection<T> _collection;

  BaseRepositoryImpl(this._collection, this._isarService);

  @override
  Future<T?> getById(String id) async {
    return await _collection.get(fastHash(id));
  }

  @override
  Stream<void> watch() {
    return _collection.watchLazy();
  }

  @override
  Future<List<T>> getAll() async {
    return await _collection.where().findAll();
  }

  @override
  Future<void> putAll(List<T> items) async {
    await _isarService.db.writeTxn(() async {
      await _collection.putAll(items);
    });
  }

  @override
  Future<void> deleteAll(List<String> ids) async {
    await _isarService.db.writeTxn(() async {
      await _collection.deleteAll(ids.map((e) => fastHash(e)).toList());
    });
  }
}
