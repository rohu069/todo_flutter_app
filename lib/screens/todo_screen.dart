import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Task> tasks = [];

  static const iconColor = Color.fromARGB(221, 45, 43, 43);

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', taskList);
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = prefs.getStringList('tasks');

    if (taskList != null) {
      setState(() {
        tasks =
            taskList.map((task) => Task.fromJson(jsonDecode(task))).toList();
      });
    }
  }

  void addTask() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      tasks.add(Task(title: _controller.text.trim()));
      _controller.clear();
    });

    saveTasks();
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  void editTask(int index) {
    _controller.text = tasks[index].title;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit Task"),
            content: TextField(controller: _controller),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    tasks[index].title = _controller.text;
                    _controller.clear();
                  });
                  saveTasks();
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void clearCompleted() {
    setState(() {
      tasks.removeWhere((t) => t.isCompleted);
    });
    saveTasks();
  }

  void deleteAll() {
    setState(() {
      tasks.clear();
    });
    saveTasks();
  }

  Widget buildCard(Task task, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: () => toggleTask(index),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: task.isCompleted ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: task.isCompleted ? null : BorderRadius.circular(4),
              border: Border.all(color: Colors.black87),
              color: task.isCompleted ? Colors.blue : Colors.transparent,
            ),
            child:
                task.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color:
                task.isCompleted
                    ? const Color.fromARGB(255, 106, 103, 103)
                    : Colors.black87,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),

        // ✅ FIXED TRAILING
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 24, color: iconColor),
              onPressed: () => editTask(index),
            ),

            IconButton(
              onPressed: () => deleteTask(index),
              icon: SizedBox(
                width: 24,
                height: 26,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // body
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: iconColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    // lines
                    Positioned(
                      bottom: 4,
                      left: 7,
                      child: Container(
                        width: 2,
                        height: 8,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 7,
                      child: Container(
                        width: 2,
                        height: 8,
                        color: Colors.white,
                      ),
                    ),

                    // lid
                    Positioned(
                      top: 5,
                      child: Container(
                        width: 18,
                        height: 3,
                        decoration: BoxDecoration(
                          color: iconColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // handle
                    Positioned(
                      top: 2,
                      child: Container(
                        width: 6,
                        height: 2,
                        decoration: BoxDecoration(
                          color: iconColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = tasks.where((t) => !t.isCompleted).toList();
    final completed = tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // ✅ RECTANGLE HEADER (FIXED)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue, // ❌ removed borderRadius
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 35,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    "To-Do List",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // INPUT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "Enter new task",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed:
                          _controller.text.trim().isEmpty ? null : addTask,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Divider(height: 1, thickness: 0.6, color: Colors.grey[300]),
            const SizedBox(height: 8),

            // LIST
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  if (pending.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "Pending Tasks",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...pending.map((task) {
                      int index = tasks.indexOf(task);
                      return Column(
                        children: [
                          buildCard(task, index),
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Colors.grey[300],
                          ),
                        ],
                      );
                    }),
                  ],
                  if (completed.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "Completed",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...completed.map((task) {
                      int index = tasks.indexOf(task);
                      return Column(
                        children: [
                          buildCard(task, index),
                          Divider(
                            height: 0,
                            thickness: 0.5,
                            color: Colors.grey[300],
                          ),
                        ],
                      );
                    }),
                  ],
                ],
              ),
            ),

            Divider(height: 1, thickness: 0.6, color: Colors.grey[300]),
            // BUTTONS
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: clearCompleted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text("Clear Completed"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: deleteAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text("Delete All"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
