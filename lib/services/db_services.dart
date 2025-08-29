import 'package:hive/hive.dart';
import '../models/barang.dart';
import '../models/transaksi.dart';

class DBService {
  static Box<Barang> get barangBox => Hive.box<Barang>('barangBox');
  static Box<Transaksi> get transaksiBox => Hive.box<Transaksi>('transaksiBox');

  // === CRUD Barang ===
  static Future<void> tambahBarang(Barang barang) async {
    await barangBox.add(barang);
  }

  static Future<void> updateBarang(int index, Barang barang) async {
    await barangBox.putAt(index, barang);
  }

  static Future<void> hapusBarang(int index) async {
    await barangBox.deleteAt(index);
  }

  // === Input Transaksi ===
  static Future<void> tambahTransaksi(String namaBarang, int jumlah) async {
    // cari barang
    final barangIndex = barangBox.values.toList().indexWhere((b) => b.nama == namaBarang);
    if (barangIndex == -1) return;

    final barang = barangBox.getAt(barangIndex)!;

    // kurangi stok
    barang.stok -= jumlah;
    await barang.save();

    // hitung total harga jual
    int totalHarga = barang.hargaJual * jumlah;

    // simpan transaksi
    final transaksi = Transaksi(
      namaBarang: barang.nama,
      jumlah: jumlah,
      totalHarga: totalHarga,
      tanggal: DateTime.now(),
    );

    await transaksiBox.add(transaksi);
  }

  // === Hitungan Laba ===
  static int getLabaKotor() {
    int total = 0;
    for (var transaksi in transaksiBox.values) {
      final barang = barangBox.values.firstWhere((b) => b.nama == transaksi.namaBarang);
      int laba = (barang.hargaJual - barang.hargaBeli) * transaksi.jumlah;
      total += laba;
    }
    return total;
  }

  static int getLabaBersih(int biayaOperasional) {
    return getLabaKotor() - biayaOperasional;
  }
}
