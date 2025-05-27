import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/admin/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  static const _emailDecoration = InputDecoration(
    labelText: 'Email',
    border: OutlineInputBorder(),
  );

  static const _passwordDecoration = InputDecoration(
    labelText: 'Mật khẩu',
    border: OutlineInputBorder(),
  );

  static const _loginButtonText = Text('Đăng Nhập');
  static const _registerButtonText = Text('Chưa có tài khoản? Đăng ký ngay');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateBasedOnRole(UserRole role) {
    if (!mounted) return;
    switch (role) {
      case UserRole.admin:
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case UserRole.restaurantOwner:
        Navigator.pushReplacementNamed(context, '/restaurant');
        break;
      case UserRole.customer:
        Navigator.pushReplacementNamed(context, '/customer');
        break;
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = await _authService.signInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );

        if (user != null) {
          _navigateBasedOnRole(user.role);
        } else {
          _showErrorSnackBar('Đăng nhập thất bại. Vui lòng thử lại.');
        }
      } catch (e) {
        _showErrorSnackBar('Lỗi: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng Nhập'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: _emailDecoration,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: _passwordDecoration,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : _loginButtonText,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: _registerButtonText,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 