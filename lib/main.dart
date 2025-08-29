import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/barang.dart';
import 'models/transaksi.dart';
import 'services/db_services.dart';
import './pages/layout/mainLayout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(BarangAdapter());
  Hive.registerAdapter(TransaksiAdapter());

  await Hive.openBox<Barang>('barangBox');
  await Hive.openBox<Transaksi>('transaksiBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "stokmate",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const MainLayout(),
    );
  }
}
