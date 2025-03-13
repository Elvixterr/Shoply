// lib/screens/edit_task_screen.dartckage:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoply/models/task.dart';
import '../providers/task_providers.dart';

class EditTaskScreen extends StatelessWidget {
  final Task task; // Recibirá la tarea que se va a editar
  final TextEditingController _controller;

  EditTaskScreen({super.key, required this.task})
      : _controller = TextEditingController(text: task.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Task"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            CheckboxListTile(
              title: const Text('Completed'),
              value: task.isCompleted,
              onChanged: (value) {
                Provider.of<TaskProvider>(context, listen: false)
                    .toggleTaskCompletion(task as String);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Guarda el cambio
                task.title = _controller.text;
                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                Provider.of<TaskProvider>(context, listen: false)
                    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                    .notifyListeners();
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
