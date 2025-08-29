// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaksi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransaksiAdapter extends TypeAdapter<Transaksi> {
  @override
  final int typeId = 1;

  @override
  Transaksi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaksi(
      namaBarang: fields[0] as String,
      jumlah: fields[1] as int,
      totalHarga: fields[2] as int,
      tanggal: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Transaksi obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.namaBarang)
      ..writeByte(1)
      ..write(obj.jumlah)
      ..writeByte(2)
      ..write(obj.totalHarga)
      ..writeByte(3)
      ..write(obj.tanggal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransaksiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
