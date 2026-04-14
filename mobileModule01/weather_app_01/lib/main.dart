import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

// We use StatefulWidget because we need to update UI dynamically
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controller to read text from TextField
  final TextEditingController _controller = TextEditingController();

  // Stores what should be displayed (search text or "Geolocation")
  String _displayText = '';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(

        // ---------------------- APP BAR ----------------------
        appBar: AppBar(
          title: Row(
            children: [

              // Search field (responsive)
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),

                  // When user submits text
                  onSubmitted: (value) {
                    setState(() {
                      _displayText = value;
                    });
                  },
                ),
              ),

              const SizedBox(width: 10),

              // Geolocation button
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () {
                  setState(() {
                    _displayText = 'Geolocation';
                  });
                },
              ),
            ],
          ),
        ),

        // ---------------------- BODY ----------------------
        body: TabBarView(
          children: [
            _buildTabContent('Currently'),
            _buildTabContent('Today'),
            _buildTabContent('Weekly'),
          ],
        ),

        // ---------------------- BOTTOM BAR ----------------------
        bottomNavigationBar: BottomAppBar(
          child: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.wb_sunny), text: 'Currently'),
              Tab(icon: Icon(Icons.today), text: 'Today'),
              Tab(icon: Icon(Icons.calendar_view_week), text: 'Weekly'),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
          ),
        ),
      ),
    );
  }

  // Widget to build content for each tab
  Widget _buildTabContent(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // Tab name (e.g., Today)
          Text(
            tabName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // Display search text OR "Geolocation"
          Text(
            _displayText.isEmpty ? '' : _displayText,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
