import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_better_todolist/entities/todo.dart';
import 'package:the_better_todolist/services/dependancy_injection/injectable_init.dart';
import 'package:the_better_todolist/services/todo_service.dart';
import 'package:the_better_todolist/widgets/TaskBottomSheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TodoService todoService = getIt<TodoService>();

  @override
  void initState() {
    super.initState();
  }

  _handleClick(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (BuildContext context) {
          return const TaskBottomSheet();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[_buildTodoStream()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleClick(context),
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
