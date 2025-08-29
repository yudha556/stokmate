// main_layout.dart
import 'package:flutter/material.dart';
import '../screen/dashboard.dart';
import '../screen/product.dart';
import '../components/header.dart';
import '../components/sidebar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> pages = [
    const Dashboard(),
    const Product(),
  ];

  final List<String> titles = [
    'Dashboard',
    'Product',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(
          onMenuPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: Sidebar(
          selectedIndex: selectedIndex,
          onItemSelected: (index) {
            setState(() => selectedIndex = index);
            Navigator.pop(context); // Tutup drawer setelah pilih menu
          },
        ),
      ),
      body: pages[selectedIndex],
    );
  }
}