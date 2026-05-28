import 'package:flutter/material.dart';
import 'package:touch365_scanner/pages/commonServices/LoginPage.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});
  @override
  State<StatefulWidget> createState() => _StartPage();
}

class _StartPage extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Padding(
        padding: const EdgeInsets.only(top: 210.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome to\nScanner 365",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 60.0,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.only(top: 200.0),
                  child: ElevatedButton.icon(
                    iconAlignment: IconAlignment.end,
                    label: const Text(
                      "Click here to get started",
                      style: TextStyle(fontSize: 20),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 25),
                    style: ElevatedButton.styleFrom(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.only(
                        top: 20,
                        bottom: 20,
                        left: 30,
                        right: 30,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
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