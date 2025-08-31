import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final Color? backgroundColor;
  final double height;

  const Header({
    Key? key,
    this.onMenuPressed,
    this.backgroundColor,
    this.height = 60.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Color(0xFFF4F6FF),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
                size: 24,
              ),
              onPressed: onMenuPressed,
              tooltip: 'Menu',
            ),
            
            // Brand Text - StokMate
            const SizedBox(width: 8),
            const Text(
              'StokMate',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            
            const Spacer(),
            
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/icon/icon.png'),
              backgroundColor: Theme.of(context).primaryColor,
              onBackgroundImageError: (exception, stackTrace) {
                // Jika gambar tidak ditemukan, akan menggunakan backgroundColor
              },
              child: Container(), // Empty container, gambar akan ditampilkan sebagai background
            ),
          ],
        ),
      ),
    );
  }
}