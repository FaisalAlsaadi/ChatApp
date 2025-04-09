import 'package:chatapp/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/components/my_button.dart';
import 'package:chatapp/components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key, required this.onTap});

  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  //tap function to go to login page if have account
  //pass it as a parameter
  final void Function()? onTap;

  //register button function
  void register(BuildContext context) {
    //get auth service

    //if passwords match create user
    final _auth = AuthService();
    if (_passwordController.text ==
        _confirmPasswordController.text) {
      try {
        _auth.singUpWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );
      } on FirebaseAuth catch (e) {
        showDialog(
          context: context,
          builder:
              (context) =>
                  AlertDialog(title: Text(e.toString())),
        );
      }
    } else {
      showDialog(
        context: context,
        builder:
            (context) => const AlertDialog(
              title: Text('Passwords don\'t match!'),
            ),
      );
    }
    //if passwords don't match show error to user
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
              "Let's create an account for you",
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
            //confirm pw
            MyTextfield(
              hintText: "Confirm Password",
              obscured: true,
              controller: _confirmPasswordController,
            ),
            SizedBox(height: 50),

            //register button
            MyButton(
              text: 'Register',
              onTap: () => register(context),
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
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
                    'Login here',
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
