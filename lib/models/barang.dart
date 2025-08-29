import 'package:hive/hive.dart';

part 'barang.g.dart';

@HiveType(typeId: 0)
class Barang extends HiveObject {
  @HiveField(0)
  String nama;

  @HiveField(1)
  int stok;

  @HiveField(2)
  int hargaBeli;

  @HiveField(3)
  int hargaJual;

  Barang({
    required this.nama,
    required this.stok,
    required this.hargaBeli,
    required this.hargaJual,
  });
}
