import 'package:flutter/material.dart';

void main() {
  // Entry point of the Flutter app
  runApp(const MyApp());
}

// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Expression and result (temporary static values for now)
  String expression = "0";
  String result = "0";

  // Buttons (5 per row layout)
  final List<String> buttons = [
    "7", "8", "9", "C", "AC",
    "4", "5", "6", "+", "-",
    "1", "2", "3", "×", "÷",
    "0", ".", "00", "=", ""
  ];

  // Handle button press (debug only for now)
  void onButtonPressed(String value) {
    print("Pressed: $value");
  }

  // Decide text color based on button type
  Color getTextColor(String value) {
    if (value == "AC" || value == "C") {
      return Colors.red;
    } else if ("0123456789.".contains(value)) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        centerTitle: true,
      ),

      body: Column(
        children: [

          // ---------------- DISPLAY AREA ----------------
          Flexible(
            fit: FlexFit.loose,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF5A6B7A),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start, // 👈 FIX: top aligned

                children: [
                  Text(
                    expression,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    result,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------------- BUTTON GRID (FIXED SPACING) ----------------
          Expanded(
            child: Column(
              children: List.generate(4, (rowIndex) {
                return Flexible(
                  fit: FlexFit.tight, // 👈 FIX: removes extra row spacing

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // fill height

                    children: List.generate(5, (colIndex) {
                      final index = rowIndex * 5 + colIndex;
                      final value = buttons[index];

                      if (value == "") {
                        return const Expanded(child: SizedBox());
                      }

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(1),

                          child: ElevatedButton(
                            onPressed: () => onButtonPressed(value),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD0D5DB),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              padding: EdgeInsets.zero,
                            ),

                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                value,
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: getTextColor(value),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}