import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newone/dashboard.dart';
import 'package:newone/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool rememberMe = false;
  bool isLogin = true;
  bool isLoading = false;

  String email = '';
  String password = '';
  String username = '';
  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
  }

  void loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email') ?? '';
    final savedPassword = prefs.getString('password') ?? '';
    final savedRemember = prefs.getBool('rememberMe') ?? false;

    if (savedRemember) {
      setState(() {
        email = savedEmail;
        password = savedPassword;
        rememberMe = true;
      });
    }
  }

  Future<void> handleAuth() async {
    setState(() => isLoading = true);

    try {
      UserCredential userCred;

      if (isLogin) {
        print("[🔐] Logging in with email: $email");
        userCred = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        print("[✅] Login successful");
      } else {
        print(
            "[🆕] Registering user with email: $email and username: $username");
        userCred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        final uid = userCred.user!.uid;
        print("[📤] Saving new user data to Firestore (UID: $uid)");

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': email,
          'username': username,
          'progress': 0.0,
          'createdAt': Timestamp.now(),
        });

        print("[✅] Firestore user document created");
      }
      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString('email', email);
        await prefs.setString('password', password);
        await prefs.setBool('rememberMe', true);
      } else {
        await prefs.remove('email');
        await prefs.remove('password');
        await prefs.setBool('rememberMe', false);
      }

      // ✅ Navigate after successful login or registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeDashboard()),
      );
    } on FirebaseAuthException catch (e) {
      print("[❌] FirebaseAuth error: ${e.code}");

      String message = '';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'email-already-in-use':
          message = 'Email already in use.';
          break;
        case 'weak-password':
          message = 'Password must be at least 6 characters.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        default:
          message = 'Something went wrong. Try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      print("[❗] Unexpected error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unexpected error occurred.'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6F5),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    isLogin ? "Welcome Back 👋" : "Create Account ✨",
                    style: GoogleFonts.poppins(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isLogin
                        ? "Login to continue your journey."
                        : "Register to start learning English.",
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),
                  if (!isLogin)
                    Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Username",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          onChanged: (val) => username = val.trim(),
                          validator: (val) =>
                              val!.isEmpty ? "Enter username" : null,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    onChanged: (val) => email = val.trim(),
                    validator: (val) => val!.isEmpty ? "Enter email" : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    onChanged: (val) => password = val.trim(),
                    validator: (val) =>
                        val!.length < 6 ? "Min 6 characters" : null,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (val) {
                          setState(() {
                            rememberMe = val!;
                          });
                        },
                      ),
                      const Text("Remember Me")
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Enter email to reset password")),
                          );
                          return;
                        }
                        _auth.sendPasswordResetEmail(email: email).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("🔑 Reset email sent")),
                          );
                        }).catchError((e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("❌ Error sending reset email")),
                          );
                        });
                      },
                        child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.teal),
                        ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              await handleAuth();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isLogin ? "Login" : "Register", style: TextStyle(color: Colors.black),),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLogin = !isLogin;
                        email = '';
                        password = '';
                        username = '';
                      });
                    },
                    child: Text(
                      isLogin
                          ? "Don't have an account? Register"
                          : "Already have an account? Login",
                      style: GoogleFonts.poppins(color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
