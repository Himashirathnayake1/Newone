import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskNotificationsPage extends StatelessWidget {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  TaskNotificationsPage({super.key});

  Future<void> markAsDone(String taskId) async {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'completed': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔔 Task Notifications"),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('uid', isEqualTo: uid)
            .where('completed', isEqualTo: false)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final tasks = snapshot.data!.docs;

          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                "✅ No pending tasks!",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (_, index) {
              final task = tasks[index];
              final taskId = task.id;
              final title = task['title'] ?? 'Untitled Task';

              return Dismissible(
                key: Key(taskId),
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 24),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.green,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                onDismissed: (_) => markAsDone(taskId),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active, color: Colors.orange),
                    title: Text("🔔 $title"),
                    subtitle: Text("Added on ${task['timestamp'].toDate()}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => markAsDone(taskId),
                      tooltip: "Mark as Done",
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
