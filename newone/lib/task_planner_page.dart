import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newone/notification_service.dart';
import 'package:newone/notifications_page.dart';

class TaskPlannerPage extends StatefulWidget {
  const TaskPlannerPage({super.key});

  @override
  State<TaskPlannerPage> createState() => _TaskPlannerPageState();
}

class _TaskPlannerPageState extends State<TaskPlannerPage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final ScrollController _scrollController = ScrollController();

  Future<void> addOrEditTask({DocumentSnapshot? doc}) async {
    final controller = TextEditingController(text: doc?.get('title') ?? '');
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(doc == null ? "➕ Add Task" : "✏️ Edit Task"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter task title"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final title = controller.text.trim();
              if (title.isEmpty) return;

              final tasks = FirebaseFirestore.instance.collection('tasks');
              if (doc == null) {
                final DateTime notificationTime =
                    DateTime.now().add(Duration(days: 1));
                await tasks.add({
                  'uid': uid,
                  'title': title,
                  'completed': false,
                  'timestamp': Timestamp.now(),
                  'notificationTime': Timestamp.fromDate(notificationTime),
                });

                await NotificationService.scheduleTaskReminderNotification(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: title,
                  createdAt: DateTime.now(),
                );

                await Future.delayed(const Duration(milliseconds: 300));
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              } else {
                await tasks.doc(doc.id).update({'title': title});
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        doc == null ? "✅ Task Added!" : "✅ Task Updated!")),
              );
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  Future<void> deleteTask(String id) async {
    await FirebaseFirestore.instance.collection('tasks').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🗑️ Task deleted")),
    );
  }

  Future<void> toggleComplete(DocumentSnapshot doc) async {
    await FirebaseFirestore.instance.collection('tasks').doc(doc.id).update({
      'completed': !(doc['completed'] as bool),
    });
  }

  Future<void> markAllComplete(List<DocumentSnapshot> tasks) async {
    for (var task in tasks) {
      if (!(task['completed'] as bool)) {
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(task.id)
            .update({'completed': true});
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🎯 All tasks marked as complete")),
    );
  }

  Future<void> clearCompletedTasks(List<DocumentSnapshot> tasks) async {
    for (var task in tasks) {
      if (task['completed'] as bool) {
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(task.id)
            .delete();
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🧹 Completed tasks cleared")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📋 Task Planner"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            tooltip: "View Notifications",
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaskNotificationsPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('uid', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final tasks = snapshot.data!.docs;

          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                "📝 No tasks yet. Tap '+' to add one!",
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: tasks.length,
                  itemBuilder: (_, index) {
                    final task = tasks[index];
                    final completed = task['completed'] as bool;

                    return Dismissible(
                      key: Key(task.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => deleteTask(task.id),
                      background: Container(
                        padding: const EdgeInsets.only(right: 24),
                        alignment: Alignment.centerRight,
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: IconButton(
                            icon: Icon(
                              completed
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: completed ? Colors.green : Colors.grey,
                            ),
                            onPressed: () => toggleComplete(task),
                          ),
                          title: Text(
                            task['title'],
                            style: TextStyle(
                              fontSize: 16,
                              decoration:
                                  completed ? TextDecoration.lineThrough : null,
                              color: completed ? Colors.grey : Colors.black,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => addOrEditTask(doc: task),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteTask(task.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.grey.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => markAllComplete(tasks),
                      icon: const Icon(Icons.done_all),
                      label: const Text("Mark All Done"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => clearCompletedTasks(tasks),
                      icon: const Icon(Icons.cleaning_services),
                      label: const Text("Clear Completed"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 54.0),
        child: FloatingActionButton(
          backgroundColor: Colors.teal,
          onPressed: () => addOrEditTask(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
