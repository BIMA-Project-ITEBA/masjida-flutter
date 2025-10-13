import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
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
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futureMosque = apiService.getMosqueDetail(widget.mosqueId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background agar tidak ada area putih saat overscroll
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<Mosque>(
        future: futureMosque,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final mosque = snapshot.data!;
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(mosque),
                _buildContent(mosque),
              ],
            );
          }
          return const Center(child: Text("Data tidak ditemukan."));
        },
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildSliverAppBar(Mosque mosque) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.teal[800],
      elevation: 2,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          mosque.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 2.0, color: Colors.black45)],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              apiService.getFullImageUrl(mosque.imageUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey[300]);
              },
            ),
            // Gradien agar judul lebih terbaca
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: <Color>[Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Mosque mosque) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- KARTU INFORMASI UTAMA ---
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.qr_code_scanner, 'Kode', mosque.code ?? 'N/A'),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.location_on_outlined, 'Area', mosque.area ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- SEKSI DESKRIPSI ---
            const Text('Deskripsi Masjid', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Html(data: mosque.description ?? '<p>Tidak ada deskripsi.</p>'),
              ),
            ),
            const SizedBox(height: 24),

            // --- SEKSI JADWAL ---
            const Text('Jadwal Kajian', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (mosque.schedules == null || mosque.schedules!.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Belum ada jadwal.')))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mosque.schedules!.length,
                itemBuilder: (context, index) {
                  return _buildScheduleCard(mosque.schedules![index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: 20),
        const SizedBox(width: 16),
        Text('$label:', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Bagian Kiri: Tanggal
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    schedule.formattedTime,
                    style: TextStyle(color: Colors.teal[800], fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    schedule.formattedDate.split(',')[0], // Hanya nama hari
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Bagian Kanan: Info Kajian
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.topic,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 6),
                      Text(
                        schedule.preacherName,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
