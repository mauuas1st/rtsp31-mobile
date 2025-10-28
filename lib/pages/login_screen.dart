// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rtsp31_mobile/constants/app_color.dart';
import 'package:rtsp31_mobile/navigation/bottomnav.dart';
import 'package:rtsp31_mobile/utils/auth_utils.dart';
import 'package:rtsp31_mobile/widget/sizebox.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _error;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _loadRememberedCredentials();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      setState(() => _isLoading = true);
      final isValid = await AuthUtils.checkToken(token);
      setState(() => _isLoading = false);

      if (isValid && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavBar()),
        );
      } else {
        await prefs.remove('token');
      }
    }
  }

  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_me') ?? false;

    if (remember) {
      setState(() {
        _rememberMe = true;
        _emailController.text = prefs.getString('remembered_email') ?? '';
        _passwordController.text = prefs.getString('remembered_password') ?? '';
      });
    }
  }

  Future<void> _saveLoginData(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('remembered_email', _emailController.text);
      await prefs.setString('remembered_password', _passwordController.text);
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('remembered_email');
      await prefs.remove('remembered_password');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await AuthUtils.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      await _saveLoginData(token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavBar()),
      );
    } else {
      setState(() => _error = result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Center(
        child: Card(
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(32.0),
            constraints: const BoxConstraints(maxWidth: 350),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                    ),
                    Sizebox(),
                    Text(
                      "Selamat datang di",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      "PT. Hulu Batu Perkasa",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Masukan email dan kata sandi untuk melanjutkan.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Sizebox(),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tolong masukan email';
                        }
                        final emailValid = RegExp(
                          r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$",
                        ).hasMatch(value);
                        if (!emailValid) {
                          return 'Tolong masukan email yang valid';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Masukan email kamu',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Sizebox(),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tolong masukan kata sandi';
                        }
                        if (value.length < 6) {
                          return 'Kata sandi minimal 6 karakter';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi',
                        hintText: 'Masukan kata sandi',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    Sizebox(),
                    CheckboxListTile(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      title: const Text('Ingat saya'),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: const EdgeInsets.all(0),
                    ),
                    Sizebox(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
