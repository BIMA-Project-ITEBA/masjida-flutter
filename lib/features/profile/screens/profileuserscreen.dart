import 'package:flutter/material.dart';
import 'package:masjida/features/auth/screen/signinscreen.dart';
// IMPORT BARU untuk mengarahkan ke halaman login

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: [
              // Bagian Header Profil
              _buildProfileHeader(),
              const SizedBox(height: 30),
              // Menu Aksi
              _buildActionMenu(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk header profil (foto, nama, email)
  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage:
          NetworkImage('https://placehold.co/200x200/EFEFEF/333?text=U'),
          backgroundColor: Colors.grey,
        ),
        const SizedBox(height: 16),
        const Text(
          'Name',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'user.email@gmail.com',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Widget untuk menu (Informasi, Edit, Logout)
  Widget _buildActionMenu() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.person_outline,
            title: 'Username',
            subtitle: 'user123',
          ),
          _buildInfoTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'user.email@gmail.com',
          ),
          _buildInfoTile(
            icon: Icons.phone_outlined,
            title: 'Phone',
            subtitle: '+62 812 3456 7890',
          ),
          const Divider(height: 20),
          _buildMenuTile(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () {
              // Logika untuk pindah ke halaman edit profil
            },
          ),
          _buildMenuTile(
            icon: Icons.logout,
            title: 'Sign Out',
            color: Colors.red, // Warna merah untuk aksi logout
            onTap: () {
              // === LOGIKA LOGOUT DITAMBAHKAN DI SINI ===
              // Mengarahkan ke halaman Sign In dan menghapus semua halaman sebelumnya
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SignInScreen()),
                    (Route<dynamic> route) => false, // Predikat yang selalu false
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget untuk baris informasi (tidak bisa diklik)
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title:
      Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Widget untuk baris menu (bisa diklik)
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
