import 'package:flutter/material.dart';
import 'package:masjida/features/home/screens/home_screen.dart';
import '../../../core/api/api_service.dart';
import 'signupscreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final success = await _apiService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              const Text('Sign in now', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Please sign in to continue our app', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 60),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(hint: 'Your email address'),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: _inputDecoration(hint: '**********').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forget Password?', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),

              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?", style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUpScreen())),
                    child: const Text('Sign up', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }
}