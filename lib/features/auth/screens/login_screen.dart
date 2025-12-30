import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_management_app/features/dashboard/screens/combine_dashboard.dart';
import '../../../core/constants.dart';
import '../../../shared_widgets/custom_text_field.dart';
import '../../../shared_widgets/custom_button.dart';
import '../../company_module/screens/register_company.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailLogin = true;
  final bool _isUserLogin = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withValues(alpha: 0.8),
              secondaryColor.withValues(alpha: 0.6),
              backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                // Logo/Icon
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(Icons.hiking, size: 60, color: primaryColor),
                ),
                SizedBox(height: 30),
                Text(
                  appName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  welcomeMessage,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                // Login Card
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      defaultBorderRadius * 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Login Type Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(
                            defaultBorderRadius,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isEmailLogin = true),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isEmailLogin
                                        ? primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                      defaultBorderRadius,
                                    ),
                                  ),
                                  child: Text(
                                    'Email',
                                    style: TextStyle(
                                      color: _isEmailLogin
                                          ? Colors.white
                                          : textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isEmailLogin = false),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isEmailLogin
                                        ? primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                      defaultBorderRadius,
                                    ),
                                  ),
                                  child: Text(
                                    'Mobile',
                                    style: TextStyle(
                                      color: !_isEmailLogin
                                          ? Colors.white
                                          : textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      // Email/Mobile Field
                      CustomTextField(
                        controller: _emailController,
                        labelText: _isEmailLogin
                            ? 'Email Address'
                            : 'Mobile Number',
                        keyboardType: _isEmailLogin
                            ? TextInputType.emailAddress
                            : TextInputType.phone,
                        prefixIcon: _isEmailLogin ? Icons.email : Icons.phone,
                      ),
                      SizedBox(height: 16),
                      // Password Field
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        obscureText: !_isPasswordVisible,
                        prefixIcon: Icons.lock,
                        suffixIcon: _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        onSuffixIconPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      ),
                      SizedBox(height: 24),
                      // Login Button
                      CustomButton(
                        text: 'Login',
                        onPressed: _login,
                        isLoading: _isLoading,
                        backgroundColor: const Color.fromARGB(255, 3, 104, 6),
                      ),
                      SizedBox(height: 16),
                      // Register Company
                      CustomButton(
                        text: 'Register Company',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterCompany(),
                            ),
                          );
                        },
                        backgroundColor: const Color.fromARGB(255, 3, 105, 8),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    setState(() => _isLoading = true);
    // Simulate login process
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);
    // Save login state
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userType', _isUserLogin ? 'user' : 'company');
    // Navigate to dashboard on success
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CombinedDashboard()),
      );
    }
  }
}
