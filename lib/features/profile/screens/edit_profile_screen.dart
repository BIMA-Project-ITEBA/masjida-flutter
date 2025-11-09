import 'dart:convert'; // Untuk Base64
import 'dart:typed_data'; // Untuk Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Impor image_picker
import 'package:masjida/core/api/api_service.dart';
import 'package:masjida/core/models/profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  // Controllers untuk TextFields
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _educationController;
  late TextEditingController _periodController;

  // State untuk Dropdowns
  int? _selectedAreaId;
  int? _selectedSpecializationId;

  // State untuk data Dropdowns
  late Future<List<dynamic>> _areasFuture;
  late Future<List<dynamic>> _specializationsFuture;

  // State untuk Image Picker
  XFile? _pickedImage;
  String? _imageBase64; // Untuk dikirim ke API
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi controllers dengan data profil saat ini
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _bioController = TextEditingController(text: widget.user.bio);
    _educationController = TextEditingController(text: widget.user.education);
    _periodController = TextEditingController(text: widget.user.period?.toString() ?? '');

    // Set nilai awal dropdown
    _selectedAreaId = widget.user.areaId;
    _selectedSpecializationId = widget.user.specializationId;

    // Ambil data untuk dropdowns
    _areasFuture = apiService.getAreas();
    _specializationsFuture = apiService.getSpecializations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _educationController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  // --- LOGIKA UNTUK GAMBAR ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Konversi gambar ke base64
        Uint8List imageBytes = await image.readAsBytes();
        String base64String = base64Encode(imageBytes);
        
        setState(() {
          _pickedImage = image;
          _imageBase64 = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- LOGIKA UNTUK SIMPAN ---
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Jangan lakukan apa-apa jika form tidak valid
    }

    setState(() => _isLoading = true);

    // Siapkan data untuk dikirim
    Map<String, dynamic> dataToUpdate = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'bio': _bioController.text,
      'education': _educationController.text,
      'period': _periodController.text.isNotEmpty ? double.tryParse(_periodController.text) : null,
      'area_id': _selectedAreaId,
      'specialization_id': _selectedSpecializationId,
      // Tambahkan field lain jika ada (gender, date_of_birth)
    };
    
    // Hanya tambahkan gambar jika ada gambar baru yang dipilih
    if (_imageBase64 != null) {
      dataToUpdate['image'] = _imageBase64;
    }

    try {
      final bool success = await apiService.updateUserProfile(dataToUpdate);
      if (success && mounted) {
        // Kembali ke halaman profil dengan hasil 'true'
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  // --- TAMPILAN UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 24),
                    _buildTextField(_nameController, 'Nama Lengkap', Icons.person_outline, isRequired: true),
                    _buildTextField(_phoneController, 'Nomor Telepon', Icons.phone_outlined),
                    _buildTextField(_educationController, 'Pendidikan', Icons.school_outlined),
                    _buildTextField(
                      _periodController, 
                      'Periode Dakwah (Tahun)', 
                      Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(_bioController, 'Biografi', Icons.text_snippet_outlined, maxLines: 5),
                    const SizedBox(height: 16),
                    _buildDropdownAreas(),
                    const SizedBox(height: 16),
                    _buildDropdownSpecializations(),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Simpan Perubahan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: _pickedImage != null
                ? MemoryImage(base64Decode(_imageBase64!)) // Tampilkan gambar baru (dari memory)
                : NetworkImage(apiService.getFullImageUrl(widget.user.imageUrl)) as ImageProvider, // Tampilkan gambar lama
            child: (_pickedImage == null && widget.user.imageUrl == null)
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _pickImage,
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue,
                child: Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return '$label tidak boleh kosong';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildDropdownAreas() {
    return FutureBuilder<List<dynamic>>(
      future: _areasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Gagal memuat area');
        }
        
        final areas = snapshot.data!;
        
        return DropdownButtonFormField<int>(
          value: _selectedAreaId,
          decoration: InputDecoration(
            labelText: 'Area',
            prefixIcon: Icon(Icons.location_city_outlined, color: Colors.grey[600]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: areas.map((area) {
            return DropdownMenuItem<int>(
              value: area['id'] as int,
              child: Text(area['name'].toString()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAreaId = value;
            });
          },
        );
      },
    );
  }

  Widget _buildDropdownSpecializations() {
     return FutureBuilder<List<dynamic>>(
      future: _specializationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Gagal memuat spesialisasi');
        }
        
        final specializations = snapshot.data!;
        
        return DropdownButtonFormField<int>(
          value: _selectedSpecializationId,
          decoration: InputDecoration(
            labelText: 'Spesialisasi',
            prefixIcon: Icon(Icons.star_border_outlined, color: Colors.grey[600]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: specializations.map((spec) {
            return DropdownMenuItem<int>(
              value: spec['id'] as int,
              child: Text(spec['name'].toString()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSpecializationId = value;
            });
          },
        );
      },
    );
  }
}