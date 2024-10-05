import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import '../../ViewModel/Auth.dart';
import 'Login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController(); // Password controller

  bool _obscurePassword = true; // For toggling password visibility

  String? _selectedTrade;
  String? _selectedLocation;

  // List of trade and location options
  final List<String> trades = ['FLUTTER', 'MERN', "PYTHON", "DIGITAL_MARKET"];
  final List<String> locations = [
    'KOZHIKODE',
    'PERINTHALMANNA',
    'PALAKKAD',
    'KOCHI'
  ];

  // Email validation logic
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validation logic
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Reusable InputDecoration method
  InputDecoration _inputDecoration({
    required String labelText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      fillColor: Colors.blue.shade50,
      filled: true,
      labelText: labelText,
      labelStyle: TextStyle(fontSize: 18.sp),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: SafeArea(
              child: ListView(
                children: [
                  // Logo or Placeholder Image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Register",
                        style: TextStyle(
                            fontSize: 40.sp,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                  SizedBox(height: 50.h),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),

                  // Email Field with validation
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration(labelText: 'Email'),
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20.h),

                  // Password Field with eye icon to toggle visibility
                  TextFormField(
                    controller: _passwordController,
                    obscureText:
                        _obscurePassword, // This controls the password visibility
                    decoration: _inputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: _validatePassword,
                  ),
                  SizedBox(height: 20.h),

                  // Trade Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedTrade,
                    decoration: _inputDecoration(labelText: 'Trade'),
                    items: trades
                        .map((trade) =>
                            DropdownMenuItem(value: trade, child: Text(trade)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTrade = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select your trade' : null,
                  ),
                  SizedBox(height: 20.h),

                  // Location Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    decoration: _inputDecoration(labelText: 'Location'),
                    items: locations
                        .map((location) => DropdownMenuItem(
                            value: location, child: Text(location)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select your location' : null,
                  ),
                  SizedBox(height: 40.h),

                  // Register Button
                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        // If all fields are valid, proceed with registration
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registering...')),
                        );
                        // Add your registration logic here
                      }
                    },
                    child: Container(
                      height: 50.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade200,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          "REGISTER",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h), // Replace Spacer with SizedBox

                  // Navigate to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Login();
                              },
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Social Login Button (e.g., Google)
                  SocialLoginButton(
                    backgroundColor: Colors.blue.shade50,
                    buttonType: SocialLoginButtonType.google,
                    onPressed: () {
                      Provider.of<Auth>(context, listen: false)
                          .signInWithGoogle(context);

                      // Alternatively:
                      // context.read<Auth>().signInWithGoogle(context);
                    },
                  ),
                  SizedBox(height: 50.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
