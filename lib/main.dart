import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/barang.dart';
import 'models/transaksi.dart';
import 'services/db_services.dart';

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
      home: Scaffold(
        appBar: AppBar(title: const Text("Hive Setup Berhasil")),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // contoh test: tambah barang
              await DBService.tambahBarang(Barang(
                nama: "Indomie",
                stok: 50,
                hargaBeli: 2000,
                hargaJual: 3000,
              ));
            },
            child: const Text("Tambah Barang Contoh"),
          ),
        ),
      ),
    );
  }
}
