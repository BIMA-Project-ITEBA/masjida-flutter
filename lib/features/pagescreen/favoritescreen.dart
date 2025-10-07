import 'package:flutter/material.dart';

class FavoriteMosquesScreen extends StatelessWidget {
  const FavoriteMosquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk daftar masjid
    final List<Map<String, String>> mosques = [
      {
        "name": "Masjid Agung",
        "date": "16 July-28 July",
        "rating": "4.8",
        "capacity": "24K/jama'ah",
        "image": "https://images.unsplash.com/photo-1597018253793-1275ea46a759?q=80&w=1887&auto=format&fit=crop"
      },
      {
        "name": "Jabal Arafah",
        "date": "16 July-28 July",
        "rating": "4.8",
        "capacity": "50K/jama'ah",
        "image": "https://images.unsplash.com/photo-1610212570253-b7de9c43d939?q=80&w=1887&auto=format&fit=crop"
      },
      {
        "name": "Sultan Mahmud",
        "date": "16 July-28 July",
        "rating": "4.8",
        "capacity": "42K/jama'ah",
        "image": "https://images.unsplash.com/photo-1583410542918-6f6d6c65602a?q=80&w=1964&auto=format&fit=crop"
      },
      {
        "name": "Masjid Agung",
        "date": "16 July-28 July",
        "rating": "4.8",
        "capacity": "69K/jama'ah",
        "image": "https://images.unsplash.com/photo-1588928039572-c234a9b2b93f?q=80&w=1887&auto=format&fit=crop"
      }
    ];

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
          'Terkait',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const Text(
            'Terdekat',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Menggunakan ListView.builder untuk membuat daftar
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mosques.length,
            itemBuilder: (context, index) {
              final mosque = mosques[index];
              return _buildMosqueCard(
                context: context,
                name: mosque['name']!,
                date: mosque['date']!,
                rating: mosque['rating']!,
                capacity: mosque['capacity']!,
                imageUrl: mosque['image']!,
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget untuk satu kartu masjid
  Widget _buildMosqueCard({
    required BuildContext context,
    required String name,
    required String date,
    required String rating,
    required String capacity,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gambar Masjid
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.mosque, size: 80, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          // Detail Masjid
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.calendar_today, date),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.star, rating, color: Colors.amber),
                const SizedBox(height: 4),
                Text(
                  capacity,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Tombol Aksi
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.blue),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  // Widget kecil untuk baris info (icon + text)
  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
