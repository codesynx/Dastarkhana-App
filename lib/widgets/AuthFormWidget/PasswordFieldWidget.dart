import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PasswordFieldWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;

  PasswordFieldWidget({required this.onChanged});

  @override
  _PasswordFieldWidgetState createState() => _PasswordFieldWidgetState();
}

class _PasswordFieldWidgetState extends State<PasswordFieldWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: CupertinoColors.black,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: "Құпия сөз",
        hintStyle: TextStyle(fontSize: 13, fontFamily: 'SF-Pro-Text-Regular',color: Colors.black, fontWeight: FontWeight.w300),
        prefixIcon: Icon(Icons.password_sharp,color: Colors.black),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.black54,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        filled: true,
        fillColor: Colors.grey[100],
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2.0),
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Құпия сөзді енгізіңіз';
        }
        return null;
      },
      onChanged: widget.onChanged,
    );
  }
}
