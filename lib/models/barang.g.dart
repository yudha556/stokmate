// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barang.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BarangAdapter extends TypeAdapter<Barang> {
  @override
  final int typeId = 0;

  @override
  Barang read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Barang(
      nama: fields[0] as String,
      stok: fields[1] as int,
      hargaBeli: fields[2] as int,
      hargaJual: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Barang obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.nama)
      ..writeByte(1)
      ..write(obj.stok)
      ..writeByte(2)
      ..write(obj.hargaBeli)
      ..writeByte(3)
      ..write(obj.hargaJual);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarangAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
