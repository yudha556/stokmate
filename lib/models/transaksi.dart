import 'package:hive/hive.dart';

part 'transaksi.g.dart';

@HiveType(typeId: 1)
class Transaksi extends HiveObject {
  @HiveField(0)
  String namaBarang;

  @HiveField(1)
  int jumlah;

  @HiveField(2)
  int totalHarga;

  @HiveField(3)
  DateTime tanggal;

  Transaksi({
    required this.namaBarang,
    required this.jumlah,
    required this.totalHarga,
    required this.tanggal,
  });
}
