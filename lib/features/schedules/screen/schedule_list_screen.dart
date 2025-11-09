import 'dart:async'; // Diperlukan untuk Timer (Debouncer)
import 'package:flutter/material.dart';
import 'package:masjida/core/api/api_service.dart';
import 'package:masjida/core/models/public_schedule_model.dart';
import 'package:masjida/features/home/screens/mosque_detail_screen.dart'; // Untuk navigasi ke detail masjid

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  // State untuk data
  late Future<List<PublicSchedule>> _futureSchedules;
  late Future<List<dynamic>> _futureAreas;

  // State untuk filter
  String _searchQuery = '';
  int? _selectedAreaId;
  int? _selectedDayOfWeek;

  // State untuk UI filter
  String _selectedAreaName = 'Semua Area';
  String _selectedDayName = 'Semua Hari';

  // State untuk debouncer pencarian
  Timer? _debounce;

  // Daftar hari (sesuai standar Python .weekday(): Senin=0, Minggu=6)
  final Map<int, String> _daysOfWeek = {
    0: 'Senin',
    1: 'Selasa',
    2: 'Rabu',
    3: 'Kamis',
    4: 'Jumat',
    5: 'Sabtu',
    6: 'Minggu',
  };

  @override
  void initState() {
    super.initState();
    // Memuat data awal
    _loadSchedules();
    // Memuat data filter di background
    _futureAreas = apiService.getAreas();

    // Listener untuk search bar
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel(); // Batalkan timer jika ada
    super.dispose();
  }

  /// Memuat ulang data jadwal dari API berdasarkan filter saat ini
  void _loadSchedules() {
    setState(() {
      _futureSchedules = apiService.getPublicSchedules(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        areaId: _selectedAreaId,
        dayOfWeek: _selectedDayOfWeek,
      );
    });
  }

  /// Debouncer: Menunda pencarian 500ms setelah pengguna berhenti mengetik
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
        });
        _loadSchedules();
      }
    });
  }

  /// Menampilkan dialog filter (Bottom Sheet)
  void _showFilterDialog() {
    // Simpan nilai filter sementara
    int? tempAreaId = _selectedAreaId;
    int? tempDayOfWeek = _selectedDayOfWeek;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // StatefulBuilder diperlukan agar state di dalam dialog bisa di-update
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filter Jadwal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                    // --- Filter Area ---
                    const Text('Berdasarkan Area', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    FutureBuilder<List<dynamic>>(
                      future: _futureAreas,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return const Text('Gagal memuat area');
                        }
                        final areas = snapshot.data!;
                        
                        return DropdownButtonFormField<int>(
                          value: tempAreaId,
                          hint: const Text('Pilih Area Masjid'),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: [
                            // Pilihan "Semua Area"
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text('Semua Area'),
                            ),
                            // Map dari daftar area
                            ...areas.map((area) {
                              return DropdownMenuItem<int>(
                                value: area['id'] as int,
                                child: Text(area['name'].toString()),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setModalState(() {
                              tempAreaId = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // --- Filter Hari ---
                    const Text('Berdasarkan Hari', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    DropdownButtonFormField<int>(
                      value: tempDayOfWeek,
                      hint: const Text('Pilih Hari'),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: [
                        // Pilihan "Semua Hari"
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Semua Hari'),
                        ),
                        // Map dari daftar hari
                        ..._daysOfWeek.entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          tempDayOfWeek = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // --- Tombol Aksi ---
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Reset filter
                              setModalState(() {
                                tempAreaId = null;
                                tempDayOfWeek = null;
                              });
                            },
                            child: const Text('Hapus Filter'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Terapkan filter ke state utama
                              setState(() {
                                _selectedAreaId = tempAreaId;
                                _selectedDayOfWeek = tempDayOfWeek;
                                
                                // Update UI nama filter (jika diperlukan)
                                // ...
                              });
                              _loadSchedules(); // Muat ulang data
                              Navigator.pop(context); // Tutup dialog
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Terapkan'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari topik atau nama pendakwah...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              // onSubmitted: (value) => _loadSchedules(), // Dihandle oleh listener
            ),
          ),
          
          // --- Tombol Filter ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jadwal Akan Datang',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_list, color: Colors.blue, size: 20),
                  label: const Text('Filter', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
          
          // --- Daftar Jadwal ---
          Expanded(
            child: FutureBuilder<List<PublicSchedule>>(
              future: _futureSchedules,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada jadwal ditemukan.'));
                }
                
                final schedules = snapshot.data!;
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
                    return _buildScheduleCard(schedule);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// Widget untuk menampilkan satu kartu jadwal
  Widget _buildScheduleCard(PublicSchedule schedule) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          if (schedule.mosqueId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MosqueDetailScreen(mosqueId: schedule.mosqueId!),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Bagian Kiri: Tanggal
              Container(
                width: 65, // Beri lebar tetap
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      schedule.formattedDayAbbr, // "SEN"
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      schedule.formattedDateNum, // "10"
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
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
                    // Waktu
                    Row(
                      children: [
                        Icon(Icons.access_time_outlined, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 6),
                        Text(
                          // "Senin, 10 Nov 2025 | 10:00 WIB"
                          '${schedule.formattedFullDate} | ${schedule.formattedTime}',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Pendakwah
                    Row(
                      children: [
                        Icon(Icons.person_outline, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 6),
                        Text(
                          schedule.preacherName,
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Masjid
                    Row(
                      children: [
                        Icon(Icons.mosque_outlined, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            schedule.mosqueName,
                            style: TextStyle(color: Colors.grey[700], fontSize: 13),
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
      ),
    );
  }
}