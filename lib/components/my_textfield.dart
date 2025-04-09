import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  const MyTextfield({
    super.key,
    required this.hintText,
    //default is false, optionally passed in the argument
    this.obscured = false,
    required this.controller, this.focusNode,
  });

  final String hintText;
  final bool obscured;
  final TextEditingController controller;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 5,
      ),
      child: TextField(
        obscureText: obscured,
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          fillColor:
              Theme.of(context).colorScheme.secondary,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
