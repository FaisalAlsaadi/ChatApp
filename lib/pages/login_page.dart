import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/components/my_button.dart';
import 'package:chatapp/components/my_textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  //email and password text controllers

  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  //tap function to go to register page if no account
  //pass it as a parameter
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  //login method
  void login(BuildContext context) async {
    //get auth service
    final authService = AuthService();
    //try login
    try {
      await authService.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (context) =>
                AlertDialog(title: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
            //welcome back msg
            SizedBox(height: 50),
            Text(
              "Welcome back!",
              style: TextStyle(
                color:
                    Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 50),

            //email textfield
            MyTextfield(
              hintText: "Email",
              controller: _emailController,
            ),
            //pw textfield
            MyTextfield(
              hintText: "Password",
              obscured: true,
              controller: _passwordController,
            ),
            SizedBox(height: 50),

            //login button
            MyButton(
              text: 'Login',
              onTap: () => login(context),
            ),
            SizedBox(height: 50),

            //register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Not a member? ',
                  style: TextStyle(
                    color:
                        Theme.of(
                          context,
                        ).colorScheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    'Register here',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(
                            context,
                          ).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
