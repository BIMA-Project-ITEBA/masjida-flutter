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
      // === APPBAR DIPERBARUI TOTAL ===
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Menghilangkan tombol back otomatis
        // Judul sekarang menjadi search bar
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
              // IKON PROFIL PINDAH KE DALAM SEBAGAI SUFFIX
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
              // Sesuaikan padding agar hint text terlihat lebih di tengah
              contentPadding: const EdgeInsets.only(left: 50, right: 10, top: 12),
            ),
          ),
        ),
        // ACTIONS DIHAPUS DARI SINI
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

// Widget untuk menampilkan daftar masjid dari API
class MosqueListPage extends StatefulWidget {
  const MosqueListPage({super.key});

  @override
  State<MosqueListPage> createState() => _MosqueListPageState();
}

class _MosqueListPageState extends State<MosqueListPage> {
  late Future<List<Mosque>> futureMosques;

  @override
  void initState() {
    super.initState();
    futureMosques = ApiService().getMosques();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Mosque>>(
        future: futureMosques,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat masjid: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada masjid ditemukan.'));
          } else {
            final mosques = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mosques.length,
              itemBuilder: (context, index) {
                final mosque = mosques[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MosqueDetailScreen(mosqueId: mosque.id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              mosque.imageUrl ?? 'https://placehold.co/100x100/E4F2E8/333?text=Masjid',
                              width: 80, height: 80, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.mosque, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(mosque.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(
                                  mosque.fullAddress ?? 'Alamat tidak tersedia',
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        });
  }
}

