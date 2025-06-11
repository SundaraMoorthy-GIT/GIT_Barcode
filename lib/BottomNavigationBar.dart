import 'package:flutter/material.dart';
import 'package:git_barcode/Barcode_entry.dart';
import 'package:git_barcode/Barcode_Report.dart';
import 'package:git_barcode/Setting/Select_Printer.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    home: const HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Dynamic Navigation Items
  List<Map<String, dynamic>> dynamicNavItems = [];

  // Pages Map
  List<Widget> _allPages = [];

  @override
  void initState() {
    super.initState();
    loadNavigationItems();
  }

  void loadNavigationItems() {
    // Load navigation dynamically
    setState(() {
      dynamicNavItems = [
        {
          "icon": Icons.home,
          "label": "Make Barcode",
          "page": const BarcodePage(),
        },
        {
          "icon": Icons.report,
          "label": "Reports",
          "page": const ReportPage(),
        },
        {
          "icon": Icons.settings,
          "label": "Select Printer",
          "page": SelectPrinterPage(),
        },
      ];

      // Extract pages
      _allPages =
          dynamicNavItems.map((item) => item["page"] as Widget).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _allPages.isNotEmpty
          ? _allPages[_selectedIndex]
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: dynamicNavItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item["icon"]),
            label: item["label"],
          );
        }).toList(),
      ),
    );
  }
}
