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
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  // State untuk data
  late Future<bool> _loadDataFuture;
  List<Preacher> _allPreachers = [];
  List<Preacher> _filteredPreachers = [];
  List<Map<String, dynamic>> _specializations = [];
  List<Map<String, dynamic>> _areas = [];

  // State untuk filter yang dipilih
  int? _selectedSpecializationId;
  int? _selectedAreaId;

  // State untuk UI
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadInitialData();
    _searchController.addListener(_filterPreachers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPreachers);
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Mengambil semua data secara paralel
      final results = await Future.wait([
        apiService.getPreachers(),
        apiService.getSpecializations(),
        apiService.getAreas(),
      ]);

      _allPreachers = results[0] as List<Preacher>;
      _specializations = results[1] as List<Map<String, dynamic>>;
      _areas = results[2] as List<Map<String, dynamic>>;

      _filteredPreachers = _allPreachers;
      setState(() => _isLoading = false);
      return true;
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
      return false;
    }
  }

  void _filterPreachers() {
    List<Preacher> results = _allPreachers;
    final String query = _searchController.text.toLowerCase();

    // 1. Filter berdasarkan pencarian nama
    if (query.isNotEmpty) {
      results = results
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    }

    // 2. Filter berdasarkan spesialisasi
    if (_selectedSpecializationId != null) {
      results = results
          .where((p) => p.specializationId == _selectedSpecializationId)
          .toList();
    }

    // 3. Filter berdasarkan area
    if (_selectedAreaId != null) {
      results = results.where((p) => p.areaId == _selectedAreaId).toList();
    }

    setState(() {
      _filteredPreachers = results;
    });
  }

  void _showFilterSheet() {
    // Simpan nilai filter sementara
    int? tempSpecId = _selectedSpecializationId;
    int? tempAreaId = _selectedAreaId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter sheetSetState) {
            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter Da\'i',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  // Dropdown Spesialisasi
                  DropdownButtonFormField<int>(
                    value: tempSpecId,
                    decoration: InputDecoration(
                      labelText: 'Spesialisasi',
                      prefixIcon: Icon(Icons.school_outlined, color: Colors.blue[700]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _specializations.map((spec) {
                      return DropdownMenuItem<int>(
                        value: spec['id'],
                        child: Text(spec['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      sheetSetState(() => tempSpecId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Dropdown Area
                  DropdownButtonFormField<int>(
                    value: tempAreaId,
                    decoration: InputDecoration(
                      labelText: 'Area',
                      prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _areas.map((area) {
                      return DropdownMenuItem<int>(
                        value: area['id'],
                        child: Text(area['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      sheetSetState(() => tempAreaId = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Tombol Aksi
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            sheetSetState(() {
                              tempSpecId = null;
                              tempAreaId = null;
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Terapkan filter ke state utama
                            setState(() {
                              _selectedSpecializationId = tempSpecId;
                              _selectedAreaId = tempAreaId;
                            });
                            _filterPreachers(); // Terapkan filter
                            Navigator.pop(context); // Tutup sheet
                          },
                          child: const Text('Terapkan'),
                        ),
                      ),
                    ],
                  )
                ],
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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildSearchAndFilter(),
            const SizedBox(height: 16),
            Expanded(child: _buildBodyContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        // Search Bar
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama da\'i...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Tombol Filter
        IconButton(
          onPressed: _showFilterSheet,
          icon: const Icon(Icons.filter_list),
          color: Colors.blue,
          tooltip: 'Filter',
        ),
      ],
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Gagal memuat data: $_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                onPressed: () {
                  _loadInitialData();
                },
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredPreachers.isEmpty) {
      return Center(
        child: Text(
          _allPreachers.isEmpty
              ? "Tidak ada data Da'i ditemukan."
              : "Tidak ada hasil untuk filter Anda.",
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0), // Beri sedikit jarak dari search bar
      itemCount: _filteredPreachers.length,
      itemBuilder: (context, index) {
        final preacher = _filteredPreachers[index];
        return _buildDaiCard(context, preacher);
      },
    );
  }

  // Widget _buildDaiCard tidak berubah dari kode asli Anda
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
                            preacher.specialization, // Ini sudah nama
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
                          preacher.area ?? 'N/A', // Ini sudah nama
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