import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:testpro/auth_screen/login_screen.dart';

import '../resources/common_textFormField.dart';
import '../resources/theme.dart';

class SignupScreen extends StatefulWidget {
  static String route = "/signupScreen";
  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;

  late AnimationController controller;
  late Animation<double> fadeAnimation;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    fadeAnimation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  Future<void> signup() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      try {
        await auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup successful!")),
        );
        emailController.clear();
        passwordController.clear();
        nameController.clear();
        Get.toNamed(LoginScreen.route);
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message;
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FadeTransition(
        opacity: fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Lottie.asset('assets/images/signup.json', height: 200),
              const SizedBox(height: 10),
              AnimatedTextKit(
                animatedTexts: [
                  WavyAnimatedText(
                    'Create Your Account',
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
                repeatForever: true,
                isRepeatingAnimation: true,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      CommonTextField.buildTextField(
                        controller: nameController,
                        label: "Full Name",
                        icon: Icons.person,
                        validator: (value) {
                          if (value!.isEmpty) return "Please enter your name";
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      CommonTextField.buildTextField(
                        controller: emailController,
                        label: "Email",
                        icon: Icons.email,
                        validator: (value) {
                          if (value!.isEmpty) return "Enter your email";
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      CommonTextField.buildTextField(
                        controller: passwordController,
                        label: "Password",
                        icon: Icons.lock,
                        isPassword: true,
                        validator: (value) {
                          if (value!.isEmpty) return "Enter your password";
                          if (value.length < 6) {
                            return "Password must be at least 6 chars";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      if (errorMessage != null)
                        Text(
                          errorMessage!,
                          style:
                              const TextStyle(color: AppTheme.redColor, fontSize: 14),
                        ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isLoading ? null : signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: AppTheme.whiteColor,
                              )
                            : const Text(
                                "SIGN UP",
                                style: TextStyle(fontSize: 18,color: AppTheme.whiteColor),
                              ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(LoginScreen.route);
                        },
                        child:  Text(
                          "Already have an account? Log In",
                          style: TextStyle(color: AppTheme.primaryColor),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
