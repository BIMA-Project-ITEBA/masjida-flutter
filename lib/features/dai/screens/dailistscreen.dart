import 'package:flutter/material.dart';
import 'package:masjida/features/dai/screens/profiledaiscreen.dart';

class DaiListScreen extends StatelessWidget {
  const DaiListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk daftar Da'i
    final List<Map<String, String>> daiList = [
      {
        "name": "Ust. Haidil Fauzan",
        "specialty": "Fiqih & Tafsir",
        "rating": "4.9",
        "location": "Batam, Kepri",
        "image": "https://placehold.co/200x200/EFEFEF/333?text=HF"
      },
      {
        "name": "Ust. Abdul Somad",
        "specialty": "Hadits & Sejarah Islam",
        "rating": "5.0",
        "location": "Pekanbaru, Riau",
        "image": "https://placehold.co/200x200/DDEEFF/333?text=AS"
      },
      {
        "name": "Ust. Adi Hidayat",
        "specialty": "Al-Qur'an & Sains",
        "rating": "4.9",
        "location": "Bekasi, Jawa Barat",
        "image": "https://placehold.co/200x200/FFDDCB/333?text=AH"
      },
      {
        "name": "Ust. Hanan Attaki",
        "specialty": "Dakwah Pemuda",
        "rating": "4.8",
        "location": "Bandung, Jawa Barat",
        "image": "https://placehold.co/200x200/DDFFDD/333?text=HA"
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
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'List of Da\'i',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: daiList.length,
        itemBuilder: (context, index) {
          final dai = daiList[index];
          return _buildDaiCard(
            context: context,
            name: dai['name']!,
            specialty: dai['specialty']!,
            rating: dai['rating']!,
            location: dai['location']!,
            imageUrl: dai['image']!,
          );
        },
      ),
    );
  }

  // Widget untuk satu kartu Da'i
  Widget _buildDaiCard({
    required BuildContext context,
    required String name,
    required String specialty,
    required String rating,
    required String location,
    required String imageUrl,
  }) {
    // DIBUNGKUS DENGAN INKWELL AGAR BISA DI-TAP
    return InkWell(
      onTap: () {
        // NAVIGASI KE HALAMAN PROFIL SAAT DI-TAP
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileDaiScreen()),
        );
      },
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
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
            // Foto Profil Da'i
            CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 16),
            // Detail Da'i
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
                  Text(
                    specialty,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Rating
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

