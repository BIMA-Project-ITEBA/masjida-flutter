import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' hide Marker;
import 'package:intl/intl.dart';
// --- IMPORT BARU UNTUK GOOGLE MAPS ---
import 'package:url_launcher/url_launcher.dart';
// ------------------------------------

// --- IMPORT BARU UNTUK PETA ---
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
// ------------------------------

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

  // --- FUNGSI BARU UNTUK MEMBUKA GOOGLE MAPS ---
  Future<void> _launchGoogleMaps(double? lat, double? lon, String? address) async {
    // Prioritaskan Latitude/Longitude jika ada
    if (lat != null && lon != null && lat != 0.0 && lon != 0.0) {
      // URL universal untuk membuka Google Maps di lat/lon
      final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
      final Uri uri = Uri.parse(googleMapsUrl);

      if (await canLaunchUrl(uri)) {
        // Buka di aplikasi Google Maps eksternal
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showMapError();
      }
    }
    // Jika tidak ada lat/lon, coba cari berdasarkan alamat (fullAddress)
    else if (address != null && address.isNotEmpty) {
      final String query = Uri.encodeComponent(address);
      final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showMapError();
      }
    } 
    // Jika tidak ada data sama sekali
    else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koordinat atau alamat lokasi masjid tidak tersedia.')),
      );
    }
  }

  void _showMapError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka Google Maps.')),
      );
    }
  }
  // ---------------------------------------------

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
            // --- KARTU INFORMASI UTAMA (MODIFIKASI) ---
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.qr_code_scanner, 'Kode', mosque.code ?? 'N/A'),
                    const Divider(height: 24),
                    
                    // --- GANTI INFO AREA DENGAN ALAMAT YANG BISA DIKLIK ---
                    _buildAddressRow(
                      Icons.location_on_outlined, 
                      'Alamat', 
                      // Gunakan fullAddress, jika tidak ada, gunakan area
                      mosque.fullAddress ?? mosque.area, 
                      () {
                        // Panggil fungsi Google Maps
                        _launchGoogleMaps(mosque.latitude, mosque.longitude, mosque.fullAddress);
                      }
                    ),
                    // ----------------------------------------------------
                    
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- TAMBAHAN BARU: PETA LOKASI ---
            _buildEmbeddedMap(mosque),
            // ---------------------------------

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
  
  // --- WIDGET BARU UNTUK PETA EMBEDDED ---
  Widget _buildEmbeddedMap(Mosque mosque) {
    // Cek jika lat/lon valid (tidak null DAN tidak 0.0)
    final bool hasCoordinates = mosque.latitude != null &&
        mosque.longitude != null &&
        mosque.latitude != 0.0 &&
        mosque.longitude != 0.0;

    // Jika tidak ada koordinat, jangan tampilkan apapun
    if (!hasCoordinates) {
      return const SizedBox.shrink(); // Mengembalikan widget kosong
    }

    // Jika ada koordinat, tampilkan peta
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Peta Lokasi',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias, // Penting agar peta terpotong rapi di sudut
          child: AspectRatio(
            aspectRatio: 16 / 10, // Rasio peta (lebar/tinggi)
            child: FlutterMap(
              options: MapOptions(
                // Gunakan '!' karena kita sudah cek null di 'hasCoordinates'
                initialCenter: latlng.LatLng(mosque.latitude!, mosque.longitude!),
                initialZoom: 16.0, // Zoom level (15-17 biasanya ideal)
              ),
              children: [
                // Layer 1: Tile (Gambar Peta) dari OpenStreetMap
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.masjida', // Ganti dengan ID aplikasi Anda
                ),
                // Layer 2: Marker (Pin Lokasi)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: latlng.LatLng(mosque.latitude!, mosque.longitude!),
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red.shade700,
                        size: 40.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24), // Jarak sebelum "Deskripsi Masjid"
      ],
    );
  }
  // ------------------------------------

  // --- WIDGET BARU UNTUK ALAMAT YANG BISA DIKLIK ---
  Widget _buildAddressRow(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, // Panggil fungsi saat diklik
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Beri padding agar area klik nyaman
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Agar rapi jika alamat panjang
          children: [
            Icon(icon, color: Colors.blue, size: 20), // Ganti warna jadi biru
            const SizedBox(width: 16),
            Text('$label:', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value, 
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue, // Ganti warna jadi biru
                  decoration: TextDecoration.underline, // Tambah garis bawah
                  decorationColor: Colors.blue,
                  decorationStyle: TextDecorationStyle.dotted,
                )
              )
            ),
            const SizedBox(width: 8),
            const Icon(Icons.launch, color: Colors.blue, size: 16), // Ikon 'buka'
          ],
        ),
      ),
    );
  }
  // -------------------------------------------------

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