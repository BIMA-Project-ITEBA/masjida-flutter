import 'package:flutter/material.dart';
import 'package:masjida/core/api/api_service.dart';
import 'package:masjida/core/models/preacher_model.dart';
import 'package:masjida/features/dai/screens/profiledaiscreen.dart';

class DaiListScreen extends StatefulWidget {
  const DaiListScreen({super.key});

  @override
  State<DaiListScreen> createState() => _DaiListScreenState();
}

class _DaiListScreenState extends State<DaiListScreen> {
  late Future<List<Preacher>> futurePreachers;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futurePreachers = apiService.getPreachers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Preacher>>(
        future: futurePreachers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Gagal memuat data: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      onPressed: () {
                        setState(() {
                          futurePreachers = apiService.getPreachers();
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada data Da'i ditemukan."));
          } else {
            final preachers = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: preachers.length,
              itemBuilder: (context, index) {
                final preacher = preachers[index];
                return _buildDaiCard(context, preacher);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildDaiCard(BuildContext context, Preacher preacher) {
    final imageUrl = apiService.getFullImageUrl(preacher.imageUrl);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileDaiScreen(preacherId: preacher.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(imageUrl),
                backgroundColor: Colors.grey[200],
                onBackgroundImageError: (exception, stackTrace) {},
                child: (preacher.imageUrl == null || preacher.imageUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 35, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preacher.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.school_outlined,
                            size: 14, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            // PERBAIKAN DI SINI: Memberikan fallback jika null
                            preacher.specialization ?? 'N/A',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          // PERBAIKAN DI SINI: Memberikan fallback jika null
                          preacher.area ?? 'N/A',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

