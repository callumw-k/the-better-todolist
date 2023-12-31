import 'package:flutter/material.dart';
import 'package:the_better_todolist/services/dependancy_injection/injectable_init.dart';
import 'package:the_better_todolist/services/todo_service.dart';

showTaskBottomSheet(BuildContext context) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (BuildContext context) {
        return const TaskBottomSheet();
      });
}

class TaskBottomSheet extends StatefulWidget {
  const TaskBottomSheet({super.key});

  @override
  State<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends State<TaskBottomSheet> {
  late FocusNode taskInputNode;
  final _inputKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  final TodoService todoService = getIt<TodoService>();

  @override
  void initState() {
    taskInputNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    taskInputNode.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
            left: 16,
            top: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: double.infinity, child: _buildInputField()),
          ],
        ));
  }

  _buildInputField() {
    return Form(
        key: _inputKey,
        child: TextFormField(
          controller: _taskController,
          autofocus: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a task';
            }
            return null;
          },
          onTapOutside: (event) {
            if (_taskController.text.isEmpty) {
              Navigator.pop(context);
            }
          },
          onEditingComplete: () {},
          onFieldSubmitted: (value) async {
            if (_inputKey.currentState!.validate()) {
              await todoService.createTodo(value);

              if (!context.mounted) return;

              Navigator.pop(context, value);
            } else {
              taskInputNode.requestFocus();
            }
          },
          focusNode: taskInputNode,
          decoration: const InputDecoration(
              labelText: 'Add task',
              floatingLabelBehavior: FloatingLabelBehavior.never),
        ));
  }
}
