import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/transaksi.dart';
import '../../../models/barang.dart';
import '../../widget/app_colors.dart';
import '../../widget/modern_text_field.dart';
import '../../widget/modern_snackbar.dart';
import '../../widget/modern_dialog.dart';
import '../../widget/empty_state.dart';
import '../../layout/mainLayout.dart';

class InputTransaksiPage extends StatefulWidget {
  const InputTransaksiPage({super.key});

  @override
  State<InputTransaksiPage> createState() => _InputTransaksiPageState();
}

class _InputTransaksiPageState extends State<InputTransaksiPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBarang;
  final _jumlahController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isHistoricalTransaction = false; // Tambahkan state ini

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPurple,
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Transaksi>('transaksiBox').listenable(),
        builder: (context, Box<Transaksi> transaksiBox, _) {
          final transaksiList = transaksiBox.values.toList()
            ..sort((a, b) => b.tanggal.compareTo(a.tanggal));

          return ValueListenableBuilder(
            valueListenable: Hive.box<Barang>('barangBox').listenable(),
            builder: (context, Box<Barang> barangBox, _) {
              final barangList = barangBox.values.toList();

              if (barangList.isEmpty) {
                return EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: "Belum ada produk",
                  subtitle:
                      "Tambahkan produk terlebih dahulu sebelum melakukan transaksi",
                  buttonText: "Tambah Produk",
                  onButtonPressed: () => _navigateToProducts(context),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputSection(barangList),
                    const SizedBox(height: 32),
                    _buildTransactionList(transaksiList, barangList),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInputSection(List<Barang> barangList) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Input Transaksi Baru",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedBarang,
              decoration: InputDecoration(
                labelText: "Pilih Produk",
                prefixIcon: const Icon(Icons.inventory_2_outlined),
                filled: true,
                fillColor: AppColors.lightPurple,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: barangList.map((barang) {
                return DropdownMenuItem(
                  value: barang.nama,
                  child: Text("${barang.nama} (Stok: ${barang.stok})"),
                );
              }).toList(),
              validator: (value) => value == null ? "Pilih produk" : null,
              onChanged: (value) => setState(() => _selectedBarang = value),
            ),
            const SizedBox(height: 16),

            // Tambahkan switch untuk transaksi lama
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Transaksi Lama"),
              subtitle: const Text("Aktifkan untuk input transaksi sebelumnya"),
              value: _isHistoricalTransaction,
              onChanged: (bool value) {
                setState(() {
                  _isHistoricalTransaction = value;
                  if (value) {
                    _selectedDate = DateTime.now().subtract(
                      const Duration(days: 1),
                    );
                  } else {
                    _selectedDate = DateTime.now();
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Modifikasi validator jumlah
            ModernTextField(
              controller: _jumlahController,
              label: "Jumlah",
              icon: Icons.shopping_cart_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Masukkan jumlah";
                }
                final jumlah = int.tryParse(value);
                if (jumlah == null || jumlah <= 0) {
                  return "Jumlah harus lebih dari 0";
                }

                // Hanya validasi stok untuk transaksi baru
                if (!_isHistoricalTransaction) {
                  final barang = barangList.firstWhere(
                    (b) => b.nama == _selectedBarang,
                  );
                  if (jumlah > barang.stok) {
                    return "Stok tidak mencukupi";
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_today,
                color: AppColors.primaryPurple,
              ),
              title: Text(_formatDate(_selectedDate)),
              subtitle: Text(
                _isHistoricalTransaction
                    ? "Pilih tanggal transaksi lama"
                    : "Transaksi hari ini",
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _simpanTransaksi(barangList),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save),
                label: const Text("Simpan Transaksi"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    List<Transaksi> transaksiList,
    List<Barang> barangList,
  ) {
    if (transaksiList.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada transaksi",
          style: TextStyle(color: AppColors.lightText),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Riwayat Transaksi",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 16),
        ...transaksiList.map((transaksi) {
          final barang = barangList.firstWhere(
            (b) => b.nama == transaksi.namaBarang,
            orElse: () => Barang(
              nama: transaksi.namaBarang,
              stok: 0,
              hargaBeli: 0,
              hargaJual: 0,
            ),
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaksi.namaBarang,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${transaksi.jumlah} unit × ${_formatCurrency(barang.hargaJual)}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(transaksi.tanggal),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(transaksi.totalHarga),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: _isHistoricalTransaction
          ? DateTime.now().subtract(const Duration(days: 1))
          : DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _simpanTransaksi(List<Barang> barangList) async {
    if (_formKey.currentState!.validate()) {
      final barang = barangList.firstWhere((b) => b.nama == _selectedBarang);
      final jumlah = int.parse(_jumlahController.text);
      final totalHarga = jumlah * barang.hargaJual;

      final transaksi = Transaksi(
        namaBarang: barang.nama,
        jumlah: jumlah,
        totalHarga: totalHarga,
        tanggal: _selectedDate,
      );

      // Update stok hanya untuk transaksi baru
      if (!_isHistoricalTransaction) {
        barang.stok -= jumlah;
        await barang.save();
      }

      // Simpan transaksi
      final box = Hive.box<Transaksi>('transaksiBox');
      await box.add(transaksi);

      // Reset form
      setState(() {
        _selectedBarang = null;
        _jumlahController.clear();
        _selectedDate = _isHistoricalTransaction
            ? DateTime.now().subtract(const Duration(days: 1))
            : DateTime.now();
      });

      if (mounted) {
        ModernSnackBar.show(
          context: context,
          message: "Transaksi berhasil disimpan",
          type: SnackBarType.success,
        );
      }
    }
  }

  void _navigateToProducts(BuildContext context) {
    final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
    if (mainLayoutState != null) {
      mainLayoutState.setState(() {
        mainLayoutState.selectedIndex = 1; // index halaman produk
      });
    }
  }

  String _formatCurrency(int amount) {
    return "Rp${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  String _formatDate(DateTime date) {
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return "${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
