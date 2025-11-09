import 'package:flutter/material.dart';
import 'package:masjida/features/auth/screen/signinscreen.dart';
import '../../../core/api/api_service.dart';
import '../../../core/models/profile_model.dart';

// --- PASTIKAN IMPOR INI ADA ---
import 'package:flutter_html/flutter_html.dart';

// --- IMPORT FILE EDIT PROFIL ---
import 'edit_profile_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ApiService apiService = ApiService();
  late Future<UserProfile> futureProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Memuat (atau memuat ulang) data profil dari API
  void _loadProfile() {
    setState(() {
      // Memanggil getUserProfile() yang sekarang akan menggunakan
      // model UserProfile.fromJson() yang sudah lengkap
      futureProfile = apiService.getUserProfile();
    });
  }
  
  /// Menangani proses logout
  void _handleSignOut() async {
    await apiService.signOut();
    if (mounted) {
      // Kembali ke halaman login dan hapus semua riwayat navigasi
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }
  
  /// Menangani navigasi ke halaman Edit Profile
  void _navigateToEditProfile(UserProfile user) async {
    // Navigasi ke EditProfileScreen dan tunggu hasilnya (true jika ada update)
    final bool? profileWasUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        // Kirim data user yang lengkap ke halaman edit
        builder: (context) => EditProfileScreen(user: user),
      ),
    );

    // Jika halaman edit mengembalikan 'true', muat ulang data profil
    if (profileWasUpdated == true && mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ));
      _loadProfile(); // Panggil fungsi muat ulang
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<UserProfile>(
        future: futureProfile,
        builder: (context, snapshot) {
          // --- 1. Tampilan Loading ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          // --- 2. Tampilan Error ---
          else if (snapshot.hasError) {
             String errorMsg = 'Gagal memuat profil: ${snapshot.error}';
            // Menangani error spesifik jika sesi habis
            if (snapshot.error.toString().contains('Sesi Anda telah berakhir')) {
              errorMsg = 'Sesi Anda telah berakhir. Silakan login kembali.';
              // Opsional: otomatis logout jika sesi habis
              // _handleSignOut(); 
            }
            return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(errorMsg, textAlign: TextAlign.center),
            ));
          } 
          
          // --- 3. Tampilan Data Berhasil ---
          else if (snapshot.hasData) {
            final user = snapshot.data!;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Selalu bisa di-scroll
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  children: [
                    _buildProfileHeader(user),
                    const SizedBox(height: 30),
                    _buildActionMenu(user),
                  ],
                ),
              ),
            );
          }
          
          // --- 4. Tampilan Default (Data tidak ditemukan) ---
          return const Center(child: Text('Profil tidak ditemukan.'));
        },
      ),
    );
  }

  /// Widget untuk bagian atas (Foto, Nama, Email)
  Widget _buildProfileHeader(UserProfile user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(apiService.getFullImageUrl(user.imageUrl)),
          backgroundColor: Colors.grey,
          // Tampilkan ikon jika tidak ada gambar
          child: (user.imageUrl == null) 
              ? const Icon(Icons.person, size: 50, color: Colors.white) 
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? 'Email tidak tersedia',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Widget untuk grup menu (Info, Edit, Logout)
  Widget _buildActionMenu(UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Data sekarang akan terisi karena model dan service sudah benar
          _buildInfoTile(
            icon: Icons.person_outline,
            title: 'Nama Lengkap',
            subtitle: user.name,
          ),
          _buildInfoTile(
            icon: Icons.phone_outlined,
            title: 'Phone',
            subtitle: user.phone ?? 'N/A',
          ),
          _buildInfoTile(
            icon: Icons.school_outlined,
            title: 'Pendidikan',
            subtitle: user.education ?? 'N/A',
          ),
            _buildInfoTile(
            icon: Icons.location_city_outlined,
            title: 'Area',
            subtitle: user.areaName ?? 'N/A',
          ),
          _buildInfoTile(
            icon: Icons.star_border_outlined,
            title: 'Spesialisasi',
            subtitle: user.specializationName ?? 'N/A',
          ),
          
          // --- INI ADALAH IMPLEMENTASI HTML ---
          _buildInfoTile(
            icon: Icons.text_snippet_outlined,
            title: 'Bio',
            subtitle: user.bio ?? 'N/A', // Kirim data HTML mentah
            isHtml: true, // Beri tanda bahwa ini adalah HTML
          ),
          const Divider(height: 20),
          
          // --- Tombol Edit Profile ---
          _buildMenuTile(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () {
              // Panggil fungsi navigasi
              _navigateToEditProfile(user);
            },
          ),
          // --- Tombol Sign Out ---
          _buildMenuTile(
            icon: Icons.logout,
            title: 'Sign Out',
            color: Colors.red,
            onTap: _handleSignOut,
          ),
        ],
      ),
    );
  }

  /// --- PERBAIKAN UTAMA: Widget untuk menampilkan Teks atau HTML ---
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isHtml = false, // Parameter opsional
  }) {
    // Jika subtitle kosong atau hanya tag HTML kosong (dari Odoo), tampilkan 'N/A'
    final displaySubtitle = (subtitle.isEmpty || subtitle == '<p><br></p>') ? 'N/A' : subtitle;

    // Tentukan widget untuk subtitle
    Widget subtitleWidget;

    // Jika 'isHtml' true dan data bukan 'N/A', gunakan Widget Html
    if (isHtml && displaySubtitle != 'N/A') {
      subtitleWidget = Html(
        data: displaySubtitle, // Data HTML Anda, misal: "<p>2</p>"
        style: {
          // Style 'body' untuk default
          "body": Style(
            fontSize: FontSize(16.0),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            margin: Margins.zero, // Hapus margin default
            padding: HtmlPaddings.zero, // Hapus padding default
          ),
          // Style 'p' untuk menghapus margin/padding dari tag <p> Odoo
          "p": Style( 
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
        },
      );
    } else {
      // Jika tidak, atau jika 'N/A', gunakan Widget Text biasa
      subtitleWidget = Text(
        displaySubtitle,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        maxLines: 2, // Batasi 2 baris jika teks biasa
        overflow: TextOverflow.ellipsis,
      );
    }

    return ListTile(
      visualDensity: VisualDensity.compact, // Mengurangi padding vertikal
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: subtitleWidget, // Gunakan widget yang sudah ditentukan
    );
  }

  /// Widget untuk baris menu yang bisa diklik
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: color == Colors.red ? Colors.red : Colors.grey,
      ),
      onTap: onTap,
    );
  }
}