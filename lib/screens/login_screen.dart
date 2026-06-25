import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/local_chat_store.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _store = LocalChatStore();
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);
    final user = await _store.login(
      _phoneController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() => _loading = false);
    if (user == null) {
      _showMessage('رقم الهاتف أو كلمة المرور غير صحيحة');
      return;
    }

    _openHome(user);
  }

  void _openHome(AppUser user) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomeScreen(currentUser: user)),
      (route) => false,
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CircleAvatar(
                        radius: 44,
                        backgroundColor: Color(0xFF00A884),
                        child: Icon(Icons.chat, color: Colors.white, size: 46),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'واتساب مصغر',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'سجل الدخول واختر أي مستخدم لبدء المحادثة',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'رقم الهاتف',
                          prefixIcon: Icon(Icons.phone),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'أدخل رقم الهاتف';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: Icon(Icons.lock),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'أدخل كلمة المرور';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed: _loading ? null : _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF00A884),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('تسجيل الدخول'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final createdUser = await Navigator.of(context).push(
                            MaterialPageRoute<AppUser>(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );

                          if (createdUser != null) {
                            _phoneController.text = createdUser.phone;
                            _showMessage('تم إنشاء الحساب بنجاح');
                          }
                        },
                        child: const Text('إنشاء حساب جديد'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
