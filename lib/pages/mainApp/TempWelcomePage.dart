// ignore: file_names
import 'package:flutter/material.dart';

class TempWelcomePage extends StatelessWidget {
  const TempWelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Click Button Below to get started",
                style: TextStyle(color: Colors.white, fontSize: 32),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}