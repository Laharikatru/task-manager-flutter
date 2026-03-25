import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final Box box = Hive.box('taskBox');

  List<Task> _tasks = [];

  // Draft
  String draftTitle = '';
  String draftDescription = '';

  List<Task> get tasks => _tasks;

  TaskProvider() {
    loadTasks();
  }

  void loadTasks() {
    final data = box.get('tasks', defaultValue: []);

    _tasks = List<Map>.from(data).map((taskMap) {
      return Task(
        id: taskMap['id'],
        title: taskMap['title'],
        description: taskMap['description'],
        dueDate: DateTime.parse(taskMap['dueDate']),
        status: TaskStatus.values[taskMap['status']],
        blockedByTaskId: taskMap['blockedBy'],
      );
    }).toList();

    notifyListeners();
  }

  void saveTasks() {
    final data = _tasks.map((task) {
      return {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate.toIso8601String(),
        'status': task.status.index,
        'blockedBy': task.blockedByTaskId,
      };
    }).toList();

    box.put('tasks', data);
  }

  Future<void> addTask(Task task) async {
    await Future.delayed(Duration(seconds: 2));
    _tasks.add(task);
    saveTasks();
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    saveTasks();
    notifyListeners();
  }

  // Draft
  void saveDraft(String title, String desc) {
    draftTitle = title;
    draftDescription = desc;
  }

  void clearDraft() {
    draftTitle = '';
    draftDescription = '';
  }
}