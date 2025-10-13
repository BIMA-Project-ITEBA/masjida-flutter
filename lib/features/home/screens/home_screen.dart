import 'package:flutter/material.dart';
import 'package:masjida/core/api/api_service.dart';
import 'package:masjida/core/models/mosque_model.dart';
import 'package:masjida/features/dai/screens/dailistscreen.dart';
import 'package:masjida/features/home/screens/mosque_detail_screen.dart';
import 'package:masjida/features/notification/screens/notificationscreen.dart';
import 'package:masjida/features/profile/screens/profileuserscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MosqueListPage(),
    DaiListScreen(),
    NotificationScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Menghilangkan tombol back otomatis
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Search',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(4.0), // Beri sedikit jarak
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserProfileScreen()));
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: const Icon(Icons.person, color: Colors.blue, size: 20),
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.only(left: 50, right: 10, top: 12),
            ),
          ),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.mosque), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.record_voice_over), label: 'Da\'i'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}

// === WIDGET DAFTAR MASJID DENGAN TAMPILAN BARU ===
class MosqueListPage extends StatefulWidget {
  const MosqueListPage({super.key});

  @override
  State<MosqueListPage> createState() => _MosqueListPageState();
}

class _MosqueListPageState extends State<MosqueListPage> {
  late Future<List<Mosque>> futureMosques;
  final ApiService apiService = ApiService(); // Instance ApiService

  @override
  void initState() {
    super.initState();
    futureMosques = apiService.getMosques();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Mosque>>(
      future: futureMosques,
      builder: (context, snapshot) {
        // 1. Saat data sedang dimuat
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // 2. Jika terjadi error saat memuat data
        else if (snapshot.hasError) {
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
                        futureMosques = apiService.getMosques();
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }
        // 3. Jika data berhasil dimuat tetapi kosong
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Tidak ada data masjid ditemukan."));
        }
        // 4. Jika data berhasil dimuat dan tidak kosong
        else {
          final mosques = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: mosques.length,
            itemBuilder: (context, index) {
              final mosque = mosques[index];
              // Menggunakan helper function dari ApiService untuk URL gambar
              final imageUrl = apiService.getFullImageUrl(mosque.imageUrl);

              // Widget Card baru yang lebih menarik
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MosqueDetailScreen(mosqueId: mosque.id),
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      // Gambar sebagai latar belakang
                      Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.mosque,
                                color: Colors.grey, size: 60),
                          );
                        },
                      ),
                      // Lapisan gradien untuk keterbacaan teks
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      // Teks nama dan area masjid di atas gambar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              mosque.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                        blurRadius: 2.0, color: Colors.black54)
                                  ]),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    mosque.area ?? 'Lokasi tidak tersedia',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        shadows: [
                                          Shadow(
                                              blurRadius: 2.0,
                                              color: Colors.black54)
                                        ]),
                                    maxLines: 1,
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
            },
          );
        }
      },
    );
  }
}
