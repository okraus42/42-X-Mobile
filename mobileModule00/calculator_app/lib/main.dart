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

class Token {
    final String value;
    final bool isNumber;

    Token(this.value, this.isNumber);
  }

class _HomePageState extends State<HomePage> {
  // Expression and result
  String expression = "0";
  String result = "0";

  // Buttons (5 per row layout)
  final List<String> buttons = [
    "7", "8", "9", "C", "AC",
    "4", "5", "6", "+", "-",
    "1", "2", "3", "×", "÷",
    "0", ".", "00", "=", ""
  ];

  String formatExpression(String expr) {
    // Replace UI symbols with real operators
    return expr
        .replaceAll("×", "*")
        .replaceAll("÷", "/");
  }

  bool shouldUseExponent(double value) {
    if (value == 0) return false;

    double abs = value.abs();

    // too large
    if (abs >= 100000) return true;

    // too small (but not zero)
    if (abs < 0.0001) return true;

    return false;
  }

  String formatResult(double value) {
    if (value.isNaN) return "ERROR!";
    if (value.isInfinite) return "∞";

    // use exponent ONLY when needed
    if (shouldUseExponent(value)) {
      return value.toStringAsExponential(4);
    }

    // normal formatting
    String result = value.toStringAsPrecision(12);

    // remove trailing zeros
    if (result.contains(".")) {
      result = result.replaceAll(RegExp(r'0+$'), '');
      result = result.replaceAll(RegExp(r'\.$'), '');
    }

    return result;
  }

  double safeParse(String value) {
    double v = double.parse(value);

    if (v.abs() > 1e15) {
      throw Exception("OVERFLOW");
    }

    return v;
  }

  List<Token> tokenize(String expr) {
    List<Token> tokens = [];
    String buffer = "";

    for (int i = 0; i < expr.length; i++) {
      String c = expr[i];

      // numbers
      if ("0123456789.".contains(c)) {
        buffer += c;
        continue;
      }

      // operators
      if ("+-*/".contains(c)) {

        if (buffer.isNotEmpty) {
          tokens.add(Token(buffer, true));
          buffer = "";
        }

        // unary + or -
        if ((c == "-" || c == "+") &&
            (tokens.isEmpty || !tokens.last.isNumber)) {
          buffer = c;
          continue;
        }

        tokens.add(Token(c, false));
      }
    }

    if (buffer.isNotEmpty) {
      tokens.add(Token(buffer, true));
    }

    return tokens;
  }

  double evaluateTokens(List<Token> tokens) {
    if (tokens.isEmpty) throw Exception("EMPTY");

    // PASS 1: * and /

    List<Token> pass1 = [];
    double current = safeParse(tokens[0].value);

    for (int i = 1; i < tokens.length; i += 2) {
      String op = tokens[i].value;
      double next = safeParse(tokens[i + 1].value);

      if (op == "*") {
        current *= next;
      } else if (op == "/") {
        if (next == 0) throw Exception("DIV0");
        current /= next;
      } else {
        pass1.add(Token(current.toString(), true));
        pass1.add(Token(op, false));
        current = next;
      }
    }

    pass1.add(Token(current.toString(), true));

    // PASS 2: + and -

    double result = double.parse(pass1[0].value);

    for (int i = 1; i < pass1.length; i += 2) {
      String op = pass1[i].value;
      double num = double.parse(pass1[i + 1].value);

      if (op == "+") {
        result += num;
      } else {
        result -= num;
      }
    }

    return result;
  }

  String evaluateExpression(String expr) {
    try {
      String cleaned = formatExpression(expr);

      List<Token> tokens = tokenize(cleaned);

      if (tokens.isEmpty) return "ERROR!";

      double result = evaluateTokens(tokens);

      return formatResult(result);

    } catch (e) {
      if (e.toString().contains("DIV0")) return "ERROR!";
      return "ERROR!";
    }
  }

  // Handle button press
  void onButtonPressed(String value) {
    setState(() {

      // -------- CLEAR ALL --------
      if (value == "AC") {
        expression = "0";
        result = "0";
        return;
      }

      // -------- DELETE LAST --------
      if (value == "C") {
        if (expression.length <= 1) {
          expression = "0";
        } else {
          expression = expression.substring(0, expression.length - 1);
        }
        return;
      }

      // -------- EQUALS --------
      if (value == "=") {
        result = evaluateExpression(expression);
        return;
      }

      // -------- FIRST INPUT REPLACE ZERO --------
      if (expression == "0") {
        expression = value;
      } else {
        expression += value;
      }
    });

    // Debug output
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
        backgroundColor: Colors.blue.shade900, // dark blue
        centerTitle: true,

        title: const Text(
          "Calculator",
          style: TextStyle(
            color: Colors.white, // white text
          ),
        ),
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
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        expression,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
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