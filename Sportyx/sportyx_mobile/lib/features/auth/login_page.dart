import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/server_settings_dialog.dart';
import 'register_page.dart';
import '../../core/api_config.dart';
import '../../core/session.dart';
import '../../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate() || _loading) {
      return;
    }
    setState(() => _loading = true);
    try {
      final managers = await ApiService.getManagers();
      final matches = managers.cast<Map<String, dynamic>>().where(
        (item) =>
            (item['email']?.toString().toLowerCase() ?? '') ==
                emailController.text.trim().toLowerCase() &&
            (item['passwordHash']?.toString() ?? '') == passwordController.text.trim() &&
            (item['isActive'] == null || item['isActive'] == true),
      ).toList();

      if (matches.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final manager = matches.first;
      Session.managerId = manager['id']?.toString();
      Session.managerName = manager['fullName']?.toString();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet),
            tooltip: "Server Settings",
            onPressed: () => showServerSettingsDialog(context, onUpdated: () => setState(() {})),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => showServerSettingsDialog(context, onUpdated: () => setState(() {})),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cloud_done, size: 16, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          Text(
                            "Server: ${ApiConfig.baseUrl}",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.deepPurple),
                          ),
                        ],
                      ),
                      const Text(
                        "Change",
                        style: TextStyle(fontSize: 12, color: Colors.deepPurple, decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: "Login",
                width: 110,
                padding: const EdgeInsets.symmetric(vertical: 4),
                fontSize: 16,
                borderRadius: 16,
                outlined: true,
                onPressed: () {
                  _handleLogin();
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}