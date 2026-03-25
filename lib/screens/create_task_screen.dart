import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class CreateTaskScreen extends StatefulWidget {
  @override
  State<CreateTaskScreen> createState() =>
      _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {

  late TextEditingController titleController;
  late TextEditingController descController;

  TaskStatus selectedStatus = TaskStatus.todo;
  String? selectedBlockedTaskId;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final provider =
        Provider.of<TaskProvider>(context, listen: false);

    titleController =
        TextEditingController(text: provider.draftTitle);

    descController =
        TextEditingController(text: provider.draftDescription);
  }

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<TaskProvider>(context); // ⭐ listen true

    return Scaffold(
      appBar: AppBar(title: Text("Create Task")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Title"),
              onChanged: (value) {
                provider.saveDraft(value, descController.text);
              },
            ),

            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: "Description"),
              onChanged: (value) {
                provider.saveDraft(titleController.text, value);
              },
            ),

            SizedBox(height: 10),

            DropdownButtonFormField<TaskStatus>(
              value: selectedStatus,
              items: TaskStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),

            SizedBox(height: 10),

            // ✅ FINAL BLOCKED DROPDOWN (WORKS ALWAYS)
            DropdownButtonFormField<String?>(
              value: selectedBlockedTaskId,
              decoration: InputDecoration(labelText: "Blocked By"),
              items: [
                DropdownMenuItem(value: null, child: Text("None")),

                ...provider.tasks.map((task) {
                  return DropdownMenuItem(
                    value: task.id,
                    child: Text(task.title),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  selectedBlockedTaskId = value;
                });
              },
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : () async {

                setState(() => isLoading = true);

                final task = Task(
                  id: DateTime.now().toString(),
                  title: titleController.text,
                  description: descController.text,
                  dueDate: DateTime.now(),
                  status: selectedStatus,
                  blockedByTaskId: selectedBlockedTaskId,
                );

                await provider.addTask(task);

                provider.clearDraft();

                setState(() => isLoading = false);

                Navigator.pop(context);
              },
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}