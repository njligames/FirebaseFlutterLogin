import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();
        setState(() {
          _errorMessage =
              'Verification email sent. Please check your inbox (including spam folder) and verify your email.';
        });
        await _auth.signOut();
        // Optionally pop back to login screen after a short delay to show the message
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context);
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'weak-password':
            _errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            _errorMessage = 'An account already exists for this email.';
            break;
          case 'invalid-email':
            _errorMessage = 'The email address is not valid.';
            break;
          default:
            _errorMessage = 'Registration failed: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
          ],
        ),
      ),
    );
  }
}