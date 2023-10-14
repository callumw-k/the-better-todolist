import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'todo.g.dart';

int fastHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}

@collection
class Todo {
  String id = const Uuid().v4();

  Id get isarId => fastHash(id);
  String name;
  bool completed;
  DateTime updatedAt;
  DateTime createdAt;

  @ignore
  DateTime? deletedAt;

  Todo({
    required this.name,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> generateSupabaseTodo() => {
        'id': id,
        'name': name,
        'completed': completed,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
      };

  static Todo empty() {
    return Todo(
        name: '',
        completed: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now())
      ..id = '';
  }

  Todo.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        completed = map['completed'],
        deletedAt = map['deleted_at'] != null
            ? DateTime.parse(map['deleted_at'])
            : null,
        createdAt = DateTime.parse(map['created_at']),
        updatedAt = DateTime.parse(map['updated_at']);
}
