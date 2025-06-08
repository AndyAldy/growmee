import 'package:flutter/material.dart';
import 'package:growmee/screens/auth/register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to GrowME', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const TextField(decoration: InputDecoration(labelText: 'Email/Username')),
            const TextField(decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/home'), child: const Text('Login')),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('Daftar Akun')),
          ],
        ),
      ),
    );
  }
}