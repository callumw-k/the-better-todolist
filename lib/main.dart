import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:the_better_todolist/entities/todo.dart';
import 'package:the_better_todolist/services/dependancy_injection/injectable_init.dart';
import 'package:the_better_todolist/services/isar.dart';
import 'package:the_better_todolist/services/todo_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
   MyHomePage({super.key, required this.title});


  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TodoService todoService  = getIt<TodoService>();

  List<Todo> initialTodos = [];

  @override
  void initState() {
    _loadInitialData();
    super.initState();
  }

  Future<void> _loadInitialData() async {
    var todos = await todoService.getTodos();
    setState(() {
      initialTodos = todos;
    });
  }

  void _incrementCounter() async {
    await todoService.createTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildTodoStream()

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
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
            title: Text(todos[index].name),
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
