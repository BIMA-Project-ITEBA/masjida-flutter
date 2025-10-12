import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; // <-- Jangan lupa package ini!
import '../../../core/api/api_service.dart';
import '../../../core/models/mosque_model.dart';

class MosqueDetailScreen extends StatefulWidget {
  final int mosqueId;
  const MosqueDetailScreen({super.key, required this.mosqueId});

  @override
  State<MosqueDetailScreen> createState() => _MosqueDetailScreenState();
}

class _MosqueDetailScreenState extends State<MosqueDetailScreen> {
  late Future<Mosque> futureMosque;

  @override
  void initState() {
    super.initState();
    // Memanggil API untuk mendapatkan detail berdasarkan ID
    futureMosque = ApiService().getMosqueDetail(widget.mosqueId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Masjid'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<Mosque>(
        future: futureMosque,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final mosque = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Masjid
                  Image.network(
                    mosque.imageUrl ?? 'https://placehold.co/600x400/E4F2E8/333?text=Masjid',
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    // Fallback jika URL gambar error
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://placehold.co/600x400/E4F2E8/333?text=Masjid',
                         width: double.infinity,
                         height: 250,
                         fit: BoxFit.cover,
                      );
                    },
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Masjid
                        Text(
                          mosque.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Alamat
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                mosque.fullAddress ?? 'Alamat tidak tersedia',
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        // Deskripsi
                        const Text(
                          'Deskripsi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Merender HTML dari deskripsi
                        Html(
                          data: mosque.description ?? '<p>Tidak ada deskripsi.</p>',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text("Data tidak ditemukan."));
        },
      ),
    );
  }
}
