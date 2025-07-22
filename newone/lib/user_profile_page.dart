import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newone/login.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  Future<DocumentSnapshot> getUserData() async {
    return await FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  Future<void> updateUsername(String newName) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'username': newName,
    });
    setState(() {}); // refresh UI
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void showEditDialog(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Username"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter new username"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel",style: TextStyle(color:Colors.teal),)),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                updateUsername(newName);
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("👤 User Profile"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final username = data['username'] ?? 'N/A';
          final email = data['email'] ?? 'N/A';
          final joined = (data['createdAt'] as Timestamp).toDate();
          final formattedDate = DateFormat.yMMMMd().format(joined);

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Icon(Icons.person, size: 80, color: Colors.teal),
                const SizedBox(height: 20),
                ListTile(
                  title: const Text("Username"),
                  subtitle: Text(username),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => showEditDialog(username),
                  ),
                ),
                ListTile(
                  title: const Text("Email"),
                  subtitle: Text(email),
                ),
                ListTile(
                  title: const Text("Joined On"),
                  subtitle: Text(formattedDate),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: logout,
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
