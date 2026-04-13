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

// Main screen widget
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Function executed when button is pressed
  void handleButtonPress() {
    // Prints output to the console (debug terminal)
    print("Button pressed");
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold provides basic page structure
    return Scaffold(
      body: Center(
        // Centers content in the middle of the screen
        child: LayoutBuilder(
          // Provides screen size information for responsiveness
          builder: (context, constraints) {
            return Column(
              // Arranges children vertically

              mainAxisAlignment: MainAxisAlignment.center,
              // Centers children vertically

              crossAxisAlignment: CrossAxisAlignment.center,
              // Centers children horizontally

              mainAxisSize: MainAxisSize.min,
              // Column takes only needed space

              children: [
                // Text container with background styling
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFF808000), // olive color
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: const Text(
                    "A simple text",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Space between text and button
                const SizedBox(height: 8),

                // Button widget
                ElevatedButton(
                  onPressed: handleButtonPress, // button click handler

                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF808000), // text color
                  ),

                  child: const Text("Click me"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}