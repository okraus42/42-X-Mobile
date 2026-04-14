import 'package:flutter/material.dart';

// Entry point of the Flutter application
void main() {
  runApp(const MyApp());
}

// Root widget of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

// Main page with tabs and layout
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        
        // ---------------------- APP BAR ----------------------
        appBar: AppBar(
          title: Row(
            children: [
              
              // Expanded makes the TextField responsive
              Expanded(
                child: TextField(
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
                ),
              ),

              const SizedBox(width: 10),

              // Geolocation button
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () {
                  // TODO: Add geolocation logic
                },
              ),
            ],
          ),
        ),

        // ---------------------- BODY ----------------------
        body: const TabBarView(
          // Enables swipe between tabs
          children: [
            Center(child: Text('Currently')),
            Center(child: Text('Today')),
            Center(child: Text('Weekly')),
          ],
        ),

        // ---------------------- BOTTOM BAR ----------------------
        bottomNavigationBar: BottomAppBar(
          child: TabBar(
            tabs: [
              
              // First tab (default selected)
              Tab(
                icon: Icon(Icons.wb_sunny),
                text: 'Currently',
              ),

              Tab(
                icon: Icon(Icons.today),
                text: 'Today',
              ),

              Tab(
                icon: Icon(Icons.calendar_view_week),
                text: 'Weekly',
              ),
            ],
            
            // Optional styling
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
          ),
        ),
      ),
    );
  }
}
