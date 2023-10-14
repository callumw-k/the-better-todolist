import 'package:flutter/material.dart';
import 'package:the_better_todolist/entities/todo.dart';
import 'package:the_better_todolist/services/dependancy_injection/injectable_init.dart';
import 'package:the_better_todolist/services/todo_service.dart';
import 'package:the_better_todolist/widgets/TaskBottomSheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TodoService todoService = getIt<TodoService>();

  @override
  void initState() {
    todoService.syncTodos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[_buildTodoStream()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskBottomSheet(context),
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  FutureBuilder<List<Todo>> _buildTodoStream() {
    return FutureBuilder<List<Todo>>(
      future: todoService.getTodos(), // Initial fetch
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData) {
          return const Text('No data');
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        return StreamBuilder<List<Todo>>(
          initialData: snapshot.data, // Use data from Future as initial data
          stream: todoService.watchTodosCollection(),
          builder: (context, streamSnapshot) {
            if (!streamSnapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final todos = streamSnapshot.data!;
            return _buildListView(todos);
          },
        );
      },
    );
  }

  Widget _buildListView(List<Todo> todos) {
    return Expanded(
      child: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Column(
              children: [
                Text(todos[index].name),
                Text("${todos[index].updatedAt}")
              ],
            ),
            trailing: Checkbox(
              value: todos[index].completed,
              onChanged: (bool? newValue) {
                // Update Todo
              },
            ),
          );
        },
      ),
    );
  }
}
