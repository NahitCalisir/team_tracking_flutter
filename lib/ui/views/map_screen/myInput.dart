import 'package:flutter/material.dart';

class myInput extends StatefulWidget {

  final controller;
  final String hint;

  const myInput({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  State<myInput> createState() => _MyInputState();
}

class _MyInputState extends State<myInput> {

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white)
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide( color: Colors.white)
        ),
        fillColor: Colors.white,
        filled: true,
        hintText: widget.hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
    );
  }
}
