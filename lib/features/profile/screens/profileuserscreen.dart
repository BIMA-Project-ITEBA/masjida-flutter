import 'package:flutter/material.dart';
import 'package:masjida/features/auth/screen/signinscreen.dart';
import '../../../core/api/api_service.dart';
import '../../../core/models/profile_model.dart';

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
    // Mengambil data profil saat halaman dimuat
    futureProfile = apiService.getUserProfile();
  }
  
  void _handleSignOut() async {
    await apiService.signOut();
    if (mounted) {
      // Kembali ke halaman login dan hapus semua halaman di atasnya
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (Route<dynamic> route) => false,
      );
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat profil: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return SingleChildScrollView(
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
          return const Center(child: Text('Profil tidak ditemukan.'));
        },
      ),
    );
  }

  // Widget untuk header profil (foto, nama, email)
  Widget _buildProfileHeader(UserProfile user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(apiService.getFullImageUrl(user.imageUrl)),
          backgroundColor: Colors.grey,
          child: (user.imageUrl == null) ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
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

  // Widget untuk menu (Informasi, Edit, Logout)
  Widget _buildActionMenu(UserProfile user) {
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
            subtitle: user.name,
          ),
          _buildInfoTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: user.email ?? 'N/A',
          ),
          _buildInfoTile(
            icon: Icons.phone_outlined,
            title: 'Phone',
            subtitle: user.phone ?? 'N/A',
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
            onTap: _handleSignOut,
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
      title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
