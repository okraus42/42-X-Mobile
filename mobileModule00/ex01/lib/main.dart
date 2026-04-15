import 'package:flutter/material.dart';

void main() {
  // Entry point of the Flutter app
  // runApp starts the widget tree
  runApp(const MyApp());
}

// Root widget of the application
// StatelessWidget means the UI does not change over time
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp sets up Material Design and app configuration
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // removes debug banner

      // First screen of the app
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// This class holds the changing data (state)
class _HomePageState extends State<HomePage> {
  
  // Store available texts
  List<String> displayTexts = ["A simple text", "Hello World"];
  // This variable stores the current text
  // Declare variable without value first, needs to wait for displayTexts to be created

  int idx = 0;

  // Function triggered when button is pressed
  void handleButtonPress() {
    setState(() {
      idx ^= 1;
    });

    // Still prints to console
    print("Button pressed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // TEXT (now dynamic)
            Container(
              padding: const EdgeInsets.symmetricc(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF808000),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayTexts[idx], // 👈 uses variable instead of fixed text
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // BUTTON
            ElevatedButton(
              onPressed: handleButtonPress,
              child: const Text("Click me"),
            ),
          ],
        ),
      ),
    );
  }
}
