import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'create_task_screen.dart';

class TaskScreen extends StatefulWidget {
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String searchQuery = '';
  TaskStatus? selectedStatus;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    List<Task> tasks = provider.tasks;

    if (searchQuery.isNotEmpty) {
      tasks = tasks.where((task) =>
          task.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    if (selectedStatus != null) {
      tasks = tasks.where((task) => task.status == selectedStatus).toList();
    }

    return Scaffold(
      appBar: AppBar(title: Text("Task Manager"), elevation: 0),
      body: Column(
        children: [

          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search tasks...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
          ),

          DropdownButton<TaskStatus?>(
            value: selectedStatus,
            hint: Text("Filter"),
            items: [
              DropdownMenuItem(value: null, child: Text("All")),
              ...TaskStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.name),
                );
              }).toList()
            ],
            onChanged: (value) {
              setState(() => selectedStatus = value);
            },
          ),

          Expanded(
            child: tasks.isEmpty
                ? Center(child: Text("No Tasks"))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      bool isBlocked = false;

                      if (task.blockedByTaskId != null) {
                        final blockingTask = provider.tasks.firstWhere(
                          (t) => t.id == task.blockedByTaskId,
                          orElse: () => task,
                        );

                        isBlocked =
                            blockingTask.status != TaskStatus.done;
                      }

                      return Card(
                        margin: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: isBlocked
                            ? Colors.grey.shade400
                            : Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(task.title,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight.bold)),
                                    SizedBox(height: 4),
                                    Text(task.description),
                                    if (isBlocked)
                                      Text("Blocked",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(task.status.name),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      provider.deleteTask(task.id);
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateTaskScreen()),
          );
        },
      ),
    );
  }
}