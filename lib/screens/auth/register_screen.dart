import 'package:flutter/material.dart';
import 'package:shoply/services/firebase_service.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validar campos vacíos
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showDialog(context, 'Error', 'Please fill all the fields');
      return;
    }

    // Validar email
    final emailRegExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegExp.hasMatch(email)) {
      _showDialog(context, 'Error', 'Invalid email format');
      return;
    }

    // registrar el usuario
    final result = await registerUser(username: username, email: email, password: password);
    if (result == 'success') {
      // ignore: use_build_context_synchronously
      _showDialog(context, 'Success', 'Account created successfully!', success: true);
    } else {
      // ignore: use_build_context_synchronously
      _showDialog(context, 'Error', result);
    }
  }

  void _showDialog(BuildContext context, String title, String message, {bool success = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (success) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bolsaCompra2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Efecto de desenfoque
          Container(
            color: Colors.black.withOpacity(0.8),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título
                  const Text(
                    'Create a New Account',
                    style: TextStyle(
                      fontSize: 28.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Campos 
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white), 
                    decoration: _inputDecoration('Username'),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white), 
                    decoration: _inputDecoration('Email'),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white), 
                    decoration: _inputDecoration('Password'),
                  ),
                  const SizedBox(height: 24.0),

                  // Botón para registrar
                  ElevatedButton(
                    onPressed: () => _register(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: const Text(
                      'Create an account',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Enlace para iniciar sesión
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already a member?',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                          'Sign in',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: const Color.fromARGB(255, 104, 104, 104).withOpacity(0.9),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
    );
  }
}
