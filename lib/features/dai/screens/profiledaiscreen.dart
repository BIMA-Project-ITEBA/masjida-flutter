import 'package:flutter/material.dart';

class ProfileDaiScreen extends StatelessWidget {
  const ProfileDaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // Navigator.pop(context);
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Bagian Info Profil Utama
          _buildProfileHeader(),
          const SizedBox(height: 30),
          // Bagian Statistik
          _buildStatsRow(),
          const SizedBox(height: 30),
          // Garis Pemisah
          const Divider(thickness: 1, indent: 20, endIndent: 20),
          // Daftar Menu
          _buildMenuList(),
        ],
      ),
    );
  }

  // Widget untuk header profil (Avatar, Nama, Email)
  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage('https://placehold.co/200x200/FFC0CB/333?text=H'),
          backgroundColor: Colors.pinkAccent,
        ),
        const SizedBox(height: 16),
        const Text(
          'Ust. Haidil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'haidilfauzan@gmail.com',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Widget untuk baris statistik
  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Dawah', '360'),
        _buildStatItem('Booked', '238'),
        _buildStatItem('Available', '473'),
      ],
    );
  }

  // Widget untuk satu item statistik
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  // Widget untuk daftar menu di bawah statistik
  Widget _buildMenuList() {
    return Column(
      children: [
        _buildMenuListItem(icon: Icons.person_outline, title: 'Profile'),
        _buildMenuListItem(icon: Icons.bookmark_border, title: 'Book Da\'i'),
        _buildMenuListItem(icon: Icons.calendar_today_outlined, title: 'Schedule'),
      ],
    );
  }

  // Widget untuk satu baris item menu
  Widget _buildMenuListItem({required IconData icon, required String title}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: () {},
    );
  }
}

