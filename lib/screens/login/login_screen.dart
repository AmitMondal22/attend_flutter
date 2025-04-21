import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/exceptions.dart';
import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controller = Get.find<LoginController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RxBool _isPasswordHidden = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                isPassword: false,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 24),
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isPassword,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
      keyboardType:
          isPassword ? TextInputType.text : TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        } else if (!isPassword &&
            !RegExp(r"^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$")
                .hasMatch(value)) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return Obx(() => TextFormField(
          controller: _passwordController,
          obscureText: _isPasswordHidden.value,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock, color: Colors.green),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordHidden.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.green,
              ),
              onPressed: () {
                _isPasswordHidden.value = !_isPasswordHidden.value; // Toggle
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.green),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Password';
            } else if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ));
  }

  Widget _buildLoginButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            if (await NetworkCheckerUtils.hasNetwork()) {
              PermissionStatus status = await Permission.location.request();
              if (status.isGranted) {
                await Permission.locationAlways.request();

                controller.login(
                    _emailController.text, _passwordController.text);
              } else if (status.isDenied) {
                Get.snackbar("Permission denied.",
                    "Please add the location permission allow all the time.",
                    snackPosition: SnackPosition.BOTTOM);
              } else if (status.isPermanentlyDenied) {
                Get.snackbar("Permission denied.",
                    "Permission permanently denied. Redirecting to app settings...",
                    snackPosition: SnackPosition.BOTTOM);

                Future.delayed(const Duration(seconds: 10), () async {
                  await openAppSettings();
                });
              }
            } else {
              Get.snackbar("No internet !", "Turn on the internet connection !",
                  snackPosition: SnackPosition.BOTTOM);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          elevation: 0,
        ),
        icon: const Icon(Icons.login, color: Colors.white),
        label: const Text(
          'Login',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
