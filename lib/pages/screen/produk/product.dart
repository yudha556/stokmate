// pages/produk_page.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/barang.dart';
import '../../widget/app_colors.dart';
import '../../widget/stats_card.dart';
import '../../widget/modern_text_field.dart';
import '../../widget/modern_dialog.dart';
import '../../widget/modern_snackbar.dart';
import '../../widget/empty_state.dart';
import '../../widget/modern_app_bar.dart';
import '../../widget/modern_floating_action_button.dart';
import '../../widget/product_card.dart';

class Product extends StatelessWidget {
  const Product({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<Barang> barangBox = Hive.box<Barang>('barangBox');

    return Scaffold(
      backgroundColor: AppColors.lightPurple,
      body: ValueListenableBuilder(
        valueListenable: barangBox.listenable(),
        builder: (context, Box<Barang> box, _) {
          if (box.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: "Belum ada produk",
              subtitle: "Mulai tambahkan produk pertama Anda",
              buttonText: "Tambah Produk",
              onButtonPressed: () => _addProduct(context, barangBox),
            );
          }

          final items = box.values.toList();
          
          return Column(
            children: [
              // Stats Section
              Container(
                margin: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: "Total Produk",
                        value: items.length.toString(),
                        icon: Icons.widgets_outlined,
                        color: AppColors.primaryPurple,
                        onTap: () => _showProductStats(context, items),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatsCard(
                        title: "Total Stok",
                        value: items.fold(0, (sum, item) => sum + item.stok).toString(),
                        icon: Icons.inventory_outlined,
                        color: AppColors.successGreen,
                        onTap: () => _showStockStats(context, items),
                      ),
                    ),
                  ],
                ),
              ),

              // Product List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      _buildListHeader(items.length),
                      
                      // Product List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final barang = items[index];
                            return ProductCard(
                              name: barang.nama,
                              stock: barang.stok,
                              buyPrice: barang.hargaBeli,
                              sellPrice: barang.hargaJual,
                              isLowStock: barang.stok < 10,
                              onTap: () => _editProduct(context, barangBox, index, barang),
                              onEdit: () => _editProduct(context, barangBox, index, barang),
                              onDelete: () => _deleteProduct(context, barangBox, index, barang),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: ModernFloatingActionButton(
        onPressed: () => _addProduct(context, barangBox),
        label: "Tambah Produk",
        icon: Icons.add,
      ),
    );
  }

  Widget _buildListHeader(int itemCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Row(
        children: [
          const Text(
            "Daftar Produk",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const Spacer(),
          Text(
            "$itemCount item${itemCount > 1 ? 's' : ''}",
            style: const TextStyle(
              color: AppColors.lightText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showProductStats(BuildContext context, List<Barang> items) {
    final lowStockItems = items.where((item) => item.stok < 10).length;
    final averageProfit = items.isEmpty 
        ? 0 
        : items.fold(0, (sum, item) => sum + (item.hargaJual - item.hargaBeli)) / items.length;

    ModernDialog.show(
      context: context,
      title: "Statistik Produk",
      icon: Icons.analytics_outlined,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatItem("Total Produk", "${items.length}"),
          _buildStatItem("Stok Rendah", "$lowStockItems"),
          _buildStatItem("Rata-rata Keuntungan", _formatCurrency(averageProfit.round())),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Tutup"),
        ),
      ],
    );
  }

  void _showStockStats(BuildContext context, List<Barang> items) {
    final totalStock = items.fold(0, (sum, item) => sum + item.stok);
    final lowStockItems = items.where((item) => item.stok < 10).toList();
    
    ModernDialog.show(
      context: context,
      title: "Statistik Stok",
      icon: Icons.inventory_outlined,
      iconColor: AppColors.successGreen,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatItem("Total Stok", "$totalStock"),
          _buildStatItem("Produk Stok Rendah", "${lowStockItems.length}"),
          if (lowStockItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              "Produk dengan stok rendah:",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...lowStockItems.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text("• ${item.nama} (${item.stok})"),
            )),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Tutup"),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return "Rp${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}";
  }

  void _addProduct(BuildContext context, Box<Barang> box) {
    _showProductForm(context, box);
  }

  void _editProduct(BuildContext context, Box<Barang> box, int index, Barang barang) {
    _showProductForm(context, box, index: index, barang: barang);
  }

  void _deleteProduct(BuildContext context, Box<Barang> box, int index, Barang barang) async {
    final confirmed = await ModernDialog.showConfirmation(
      context: context,
      title: "Konfirmasi Hapus",
      message: "Apakah Anda yakin ingin menghapus produk '${barang.nama}'? Tindakan ini tidak dapat dibatalkan.",
      confirmText: "Hapus",
      cancelText: "Batal",
    );

    if (confirmed == true) {
      box.deleteAt(index);
      if (context.mounted) {
        ModernSnackBar.show(
          context: context,
          message: "Produk '${barang.nama}' berhasil dihapus",
          type: SnackBarType.success,
        );
      }
    }
  }

  void _showProductForm(BuildContext context, Box<Barang> box, {int? index, Barang? barang}) {
    final nameController = TextEditingController(text: barang?.nama ?? "");
    final stokController = TextEditingController(text: barang?.stok.toString() ?? "");
    final hargaBeliController = TextEditingController(text: barang?.hargaBeli.toString() ?? "");
    final hargaJualController = TextEditingController(text: barang?.hargaJual.toString() ?? "");
    final formKey = GlobalKey<FormState>();

    ModernDialog.show(
      context: context,
      title: barang == null ? "Tambah Produk" : "Edit Produk",
      icon: barang == null ? Icons.add : Icons.edit,
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModernTextField(
              controller: nameController,
              label: "Nama Produk",
              icon: Icons.inventory_2_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Nama produk tidak boleh kosong";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: stokController,
              label: "Stok",
              icon: Icons.numbers,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Stok tidak boleh kosong";
                }
                if (int.tryParse(value) == null || int.parse(value) < 0) {
                  return "Stok harus berupa angka positif";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: hargaBeliController,
              label: "Harga Beli",
              icon: Icons.shopping_cart_outlined,
              keyboardType: TextInputType.number,
              prefixText: "Rp ",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Harga beli tidak boleh kosong";
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return "Harga beli harus berupa angka positif";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: hargaJualController,
              label: "Harga Jual",
              icon: Icons.sell_outlined,
              keyboardType: TextInputType.number,
              prefixText: "Rp ",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Harga jual tidak boleh kosong";
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return "Harga jual harus berupa angka positif";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Batal",
            style: TextStyle(color: AppColors.lightText),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final newBarang = Barang(
                nama: nameController.text,
                stok: int.parse(stokController.text),
                hargaBeli: int.parse(hargaBeliController.text),
                hargaJual: int.parse(hargaJualController.text),
              );

              if (index != null) {
                // Edit existing
                box.putAt(index, newBarang);
                ModernSnackBar.show(
                  context: context,
                  message: "Produk berhasil diupdate",
                  type: SnackBarType.success,
                );
              } else {
                // Add new
                box.add(newBarang);
                ModernSnackBar.show(
                  context: context,
                  message: "Produk berhasil ditambahkan",
                  type: SnackBarType.success,
                );
              }
              
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(barang == null ? "Tambah" : "Simpan"),
        ),
      ],
    );
  }
}