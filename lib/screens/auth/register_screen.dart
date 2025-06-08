import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Daftar Akun', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const TextField(decoration: InputDecoration(labelText: 'Email/Username')),
            const TextField(decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            const TextField(decoration: InputDecoration(labelText: 'Konfirmasi Password'), obscureText: true),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/'), child: const Text('Daftar Akun')),
          ],
        ),
      ),
    );
  }
}