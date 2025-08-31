import 'package:flutter/material.dart';
import 'package:stokmate/pages/screen/transaksi/transaksi.dart';
import '../screen/dashboard/dashboard.dart';
import '../screen/produk/product.dart';
import '../screen/statistik/statistik.dart';
import '../components/header.dart';
import '../components/sidebar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> pages = [
    const Dashboard(),
    const Product(),
    const InputTransaksiPage(),
    const Statistik(),
  ];

  final List<String> titles = [
    'Dashboard',
    'Product',
    'Transaksi',
    'Statistik',
  ];

  @override
  Widget build(BuildContext context) {
    // Dapatkan tinggi status bar
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        // Tambahkan statusBarHeight ke preferredSize
        preferredSize: Size.fromHeight(60 + statusBarHeight),
        child: Container(
          padding: EdgeInsets.only(top: statusBarHeight),
          child: Header(
            onMenuPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: Sidebar(
          selectedIndex: selectedIndex,
          onItemSelected: (index) {
            setState(() => selectedIndex = index);
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(child: pages[selectedIndex]),
    );
  }
}
