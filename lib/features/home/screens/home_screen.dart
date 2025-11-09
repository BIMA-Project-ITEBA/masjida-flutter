import 'dart:async'; // Diperlukan untuk Debouncer di MosqueListPage
import 'package:flutter/foundation.dart'; // Diperlukan untuk debugPrint
import 'package:flutter/material.dart';
import 'package:masjida/core/api/api_service.dart';
import 'package:masjida/core/models/mosque_model.dart';
import 'package:masjida/features/dai/screens/dailistscreen.dart';
import 'package:masjida/features/home/screens/mosque_detail_screen.dart';
import 'package:masjida/features/notification/screens/notificationscreen.dart';
import 'package:masjida/features/profile/screens/profileuserscreen.dart';

// --- IMPORT BARU UNTUK HALAMAN JADWAL ---
import 'package:masjida/features/schedules/screen/schedule_list_screen.dart'; 
// (Pastikan path ini benar sesuai struktur folder Anda: lib/features/schedules/screens/schedule_list_screen.dart)

// --- Logger (Opsional tapi disarankan) ---
class _Logger {
  void info(String message) {
    debugPrint('[INFO] $message');
  }
  void warning(String message) {
    debugPrint('⚠️ [WARNING] $message');
  }
}
final _logger = _Logger();
// ------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // --- WIDGET OPTIONS DIPERBARUI ---
  // "NotificationScreen" diganti dengan "ScheduleListScreen"
  static const List<Widget> _widgetOptions = <Widget>[
    MosqueListPage(), // Tab Home (Index 0)
    DaiListScreen(), // Tab Da'i (Index 1)
    ScheduleListScreen(), // Tab Jadwal (Index 2)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- AppBar BARU Sesuai Desain ---
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0, // Mencegah perubahan warna saat scroll
      automaticallyImplyLeading: false, // Menghilangkan tombol back
      
      // Kiri: Profile Icon
      leadingWidth: 60, // Beri ruang lebih untuk CircleAvatar
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfileScreen()),
            );
          },
          child: const CircleAvatar(
            radius: 20,
            // Ganti dengan gambar profil pengguna jika sudah login
            backgroundImage: NetworkImage('https://placehold.co/100x100/EFEFEF/333?text=U'),
          ),
        ),
      ),
      
      // Tengah: Teks Sapaan
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Hi, Selamat Datang!', // Ganti dengan nama pengguna jika login
            style: TextStyle(
              color: Colors.black, 
              fontWeight: FontWeight.bold, 
              fontSize: 16,
            ),
          ),
          Text(
            'Sedang mencari masjid terdekat?',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),

      // Kanan: Notification Icon
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: Colors.grey[700], size: 28),
          // --- PERUBAHAN LOGIKA ---
          // Aksi ini sekarang langsung membuka NotificationScreen
          // BUKAN lagi mengganti tab ke index 2
          onPressed: () {
             Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
          },
        ),
        const SizedBox(width: 8), // Jarak
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang utama
      appBar: _buildAppBar(context), // Panggil AppBar baru
      body: IndexedStack( // Gunakan IndexedStack agar state halaman tetap terjaga
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.mosque), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.record_voice_over), label: 'Da\'i'),
          
          // --- PERUBAHAN UI BOTTOMNAV ---
          // Ikon dan Label diganti dari Notifikasi ke Jadwal
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined), 
            label: 'Jadwal'
          ),
          // -----------------------------
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }
}

// ===================================================================
// === WIDGET DAFTAR MASJID (DIROMBAK TOTAL) ===
// ===================================================================
class MosqueListPage extends StatefulWidget {
  const MosqueListPage({super.key});

  @override
  State<MosqueListPage> createState() => _MosqueListPageState();
}

class _MosqueListPageState extends State<MosqueListPage> {
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  // State untuk data
  late Future<List<Mosque>> _futureMosques;
  List<dynamic>? _areaList; // Untuk menyimpan daftar area
  
  // State untuk filter
  String _searchQuery = '';
  int? _selectedAreaId;

  // State untuk debouncer pencarian
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Memuat data saat halaman pertama kali dibuka
    _loadMosques();
    _loadAreas();

    // Listener untuk search bar (menggunakan debouncer)
    _searchController.addListener(_onSearchChanged);
  }
  
  // --- LOGIKA PEMUATAN DATA & PENCARIAN ---

  // Memuat (atau memuat ulang) daftar masjid
  void _loadMosques() {
    setState(() {
      _futureMosques = apiService.getMosques(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        areaId: _selectedAreaId,
      );
    });
  }

  // Memuat daftar area untuk filter
  void _loadAreas() async {
    try {
      _areaList = await apiService.getAreas();
    } catch (e) {
      // Gagal memuat area, tidak masalah untuk saat ini
      _logger.warning("Gagal memuat daftar area: $e");
    }
  }

  /// Debouncer: Menunda pencarian 500ms setelah pengguna berhenti mengetik
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
        });
        _loadMosques();
      }
    });
  }

  // Dipanggil saat filter area dipilih
  void _onAreaSelected(int? areaId) {
    if (_selectedAreaId != areaId) {
      setState(() {
        _selectedAreaId = areaId;
      });
      _loadMosques();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- WIDGET UI ---

  // 1. Widget Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari Masjid atau Area...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        // onSubmitted tidak diperlukan lagi karena kita pakai listener
      ),
    );
  }

  // 2. Widget Header (Rekomendasi & Filter)
  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Rekomendasi Masjid',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list, 
              color: _selectedAreaId != null ? Colors.blue : Colors.grey[700],
              size: 28,
            ),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
    );
  }
  
  // 3. Widget Grid Card
  Widget _buildMosqueGridCard(Mosque mosque) {
    final imageUrl = apiService.getFullImageUrl(mosque.imageUrl);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MosqueDetailScreen(mosqueId: mosque.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar (mengisi ruang yang tersedia)
            Expanded(
              child: Image.network(
                imageUrl,
                height: 120, // Beri tinggi agar konsisten
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.mosque, color: Colors.grey, size: 40),
                  );
                },
              ),
            ),
            
            // Teks Detail
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mosque.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15, // Sedikit lebih kecil untuk grid
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          mosque.area ?? 'Lokasi tidak tersedia',
                          style: TextStyle(color: Colors.grey[700], fontSize: 12),
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
  }

  // --- Tampilan Utama MosqueListPage ---
  @override
  Widget build(BuildContext context) {
    // Gunakan Column untuk menata Search Bar di atas Grid
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(),
        _buildSectionHeader(),
        
        // Expanded agar GridView mengisi sisa ruang
        Expanded(
          child: FutureBuilder<List<Mosque>>(
            future: _futureMosques,
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
                          onPressed: _loadMosques, // Panggil fungsi load ulang
                        ),
                      ],
                    ),
                  ),
                );
              }
              // 3. Jika data berhasil dimuat tetapi kosong
              else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Tidak ada masjid ditemukan."));
              }
              // 4. Jika data berhasil dimuat (Tampilan Grid)
              else {
                final mosques = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: mosques.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 Kolom
                    crossAxisSpacing: 16.0, // Jarak horizontal
                    mainAxisSpacing: 16.0,  // Jarak vertikal
                    childAspectRatio: 0.8, // Rasio PxL (Tinggi > Lebar)
                  ),
                  itemBuilder: (context, index) {
                    return _buildMosqueGridCard(mosques[index]);
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
  
  // --- Fungsi untuk menampilkan Dialog Filter ---
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar bisa set tinggi
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Gunakan StatefulBuilder agar bisa update state di dalam dialog
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Berdasarkan Area',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Tombol untuk Hapus Filter
                    ListTile(
                      leading: Icon(
                        Icons.clear_all,
                        color: _selectedAreaId == null ? Colors.blue : Colors.grey,
                      ),
                      title: const Text('Tampilkan Semua Area'),
                      onTap: () {
                        setDialogState(() {
                          _selectedAreaId = null; // Update state dialog
                        });
                        _onAreaSelected(null); // Terapkan state utama
                        Navigator.pop(context); // Tutup dialog
                      },
                      selected: _selectedAreaId == null,
                      selectedTileColor: Colors.blue.withOpacity(0.1),
                    ),
                    const Divider(),
                    // Daftar Area
                    if (_areaList == null)
                      const Center(child: CircularProgressIndicator())
                    else
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _areaList!.length,
                          itemBuilder: (context, index) {
                            final area = _areaList![index]; // area['id'] dan area['name']
                            final bool isSelected = _selectedAreaId == area['id'];
                            
                            return ListTile(
                              leading: Icon(
                                Icons.location_city, 
                                color: isSelected ? Colors.blue : Colors.grey,
                              ),
                              title: Text(area['name']),
                              onTap: () {
                                setDialogState(() {
                                  _selectedAreaId = area['id']; // Update state dialog
                                });
                                _onAreaSelected(area['id']); // Terapkan state utama
                                Navigator.pop(context); // Tutup dialog
                              },
                              selected: isSelected,
                              selectedTileColor: Colors.blue.withOpacity(0.1),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}