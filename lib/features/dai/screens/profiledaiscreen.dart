import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import '../../../core/api/api_service.dart';
import '../../../core/models/preacher_model.dart';

class ProfileDaiScreen extends StatefulWidget {
  final int preacherId;
  const ProfileDaiScreen({super.key, required this.preacherId});

  @override
  State<ProfileDaiScreen> createState() => _ProfileDaiScreenState();
}

class _ProfileDaiScreenState extends State<ProfileDaiScreen> {
  late Future<Preacher> futurePreacher;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Memanggil API untuk mendapatkan detail berdasarkan ID
    futurePreacher = apiService.getPreacherDetail(widget.preacherId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang utama
      body: FutureBuilder<Preacher>(
        future: futurePreacher,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final preacher = snapshot.data!;
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(preacher),
                _buildContent(preacher),
              ],
            );
          }
          return const Center(child: Text("Data tidak ditemukan."));
        },
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildSliverAppBar(Preacher preacher) {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.blue[800],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'preacher-image-${preacher.id}',
          child: Image.network(
            apiService.getFullImageUrl(preacher.imageUrl),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 100, color: Colors.grey),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Preacher preacher) {
    return SliverToBoxAdapter(
      child: Container(
        // Efek agar konten menumpuk di atas gambar
        transform: Matrix4.translationValues(0.0, -20.0, 0.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- NAMA DAN SPESIALISASI ---
              Text(
                preacher.name,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.school_outlined, preacher.specialization ?? 'N/A', Colors.blue[700]),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.location_on_outlined, preacher.area ?? 'N/A', Colors.grey[700]),
              const Divider(height: 40),

              // --- SEKSI BIOGRAFI ---
              const Text('Biografi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Colors.grey[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Html(data: preacher.bio ?? '<p>Tidak ada biografi.</p>'),
                ),
              ),
              const SizedBox(height: 24),

              // --- SEKSI JADWAL ---
              const Text('Jadwal Kajian', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (preacher.schedules == null || preacher.schedules!.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Belum ada jadwal.')))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: preacher.schedules!.length,
                  itemBuilder: (context, index) {
                    return _buildScheduleCard(preacher.schedules![index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String text, Color? color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(PreacherSchedule schedule) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    schedule.formattedTime,
                    style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    schedule.formattedDate.split(',')[0],
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
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
                      Icon(Icons.mosque_outlined, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          schedule.mosqueName,
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
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

