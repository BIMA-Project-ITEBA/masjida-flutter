import 'dart:convert';
import 'package:flutter/foundation.dart'; // Diperlukan untuk debugPrint
import 'package:http/http.dart' as http;
import '../models/mosque_model.dart';
import '../models/preacher_model.dart';
import '../models/invitation_model.dart';
import '../models/profile_model.dart';
// --- IMPORT BARU UNTUK MODEL JADWAL PUBLIK ---
import '../models/public_schedule_model.dart';

class ApiService {
  // --- Singleton Pattern Implementation ---
  ApiService._privateConstructor();
  static final ApiService _instance = ApiService._privateConstructor();
  factory ApiService() {
    return _instance;
  }
  // ----------------------------------------

  // Ganti dengan IP Odoo server Anda
  final String _baseUrl = "http://103.13.206.132:8069";
  String? _sessionCookie;

  /// Helper function untuk membuat URL gambar yang lengkap.
  String getFullImageUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) {
      // Mengembalikan URL placeholder jika tidak ada gambar dari API
      return 'https://placehold.co/600x400/e2e8f0/e2e8f0?text=';
    }
    // Menggabungkan base URL dengan path relatif yang diberikan oleh Odoo
    return '$_baseUrl$relativeUrl';
  }

  /// Autentikasi pengguna dan menyimpan session cookie
  Future<bool> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/web/session/authenticate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "jsonrpc": "2.0",
        "params": {"db": "masjida", "login": email, "password": password}
      }),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['error'] != null) {
        throw Exception(jsonResponse['error']['data']['message']);
      }
      debugPrint("[ApiService] Login berhasil!");
      String? rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        int index = rawCookie.indexOf(';');
        _sessionCookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
        debugPrint("[ApiService] Session cookie disimpan: $_sessionCookie");
        return true;
      }
    }
    return false;
  }

  /// Registrasi pengguna baru (khususnya Pendakwah)
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? dateOfBirth,
    String? gender,
    required String userType, // 'preacher'
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/register_user'), 
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "jsonrpc": "2.0",
        "params": {
          "name": name,
          "email": email,
          "password": password,
          "phone": phone,
          "date_of_birth": dateOfBirth,
          "gender": gender,
          "user_type": userType 
        }
      }),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Odoo JSON-RPC response dibungkus dalam 'result'
      if (jsonResponse['result']?['status'] == 'success') {
        debugPrint("[ApiService] Registrasi berhasil!");
        return true;
      } else {
        throw Exception(jsonResponse['result']?['message'] ?? 'Registrasi gagal.');
      }
    } else {
      throw Exception('Gagal mendaftar. Server error.');
    }
  }

  /// Mengambil profil pengguna yang sedang login
  Future<UserProfile> getUserProfile() async {
    if (_sessionCookie == null) {
      throw Exception('Anda harus login untuk melihat profil.');
    }
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile'),
        headers: {'Cookie': _sessionCookie!},
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          // Pastikan UserProfile.fromJson() sudah yang versi LENGKAP
          return UserProfile.fromJson(jsonResponse['data']);
        } else {
          // Jika cookie habis, Odoo mungkin redirect ke halaman login (bukan JSON)
          if (response.body.contains('Login')) {
             throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
          }
          throw Exception(jsonResponse['message'] ?? 'Gagal memuat profil.');
        }
      } else {
        throw Exception('Gagal memuat profil. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saat mengambil profil: $e');
    }
  }

  /// Mengirim data profil yang diperbarui ke Odoo
  Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    if (_sessionCookie == null) {
      throw Exception('Anda harus login untuk memperbarui profil.');
    }

    final uri = Uri.parse('$_baseUrl/api/update_profile');
    debugPrint('[ApiService] Updating profile with data: ${profileData.keys.toList()}');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': _sessionCookie!,
        },
        // Odoo JSON-RPC mengharapkan data dibungkus dalam 'params'
        body: json.encode({
          "jsonrpc": "2.0",
          "params": profileData, // Kirim map data langsung
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Cek error di level JSON-RPC
        if (jsonResponse['error'] != null) {
           debugPrint("Error from Odoo RPC: ${jsonResponse['error']['data']['message']}");
           throw Exception(jsonResponse['error']['data']['message'] ?? 'Gagal memperbarui profil (RPC Error)');
        }

        // Cek 'result' dari controller kustom kita
        if (jsonResponse['result']?['status'] == 'success') {
          debugPrint("[ApiService] Update profil berhasil!");
          return true;
        } else {
          debugPrint("Gagal update profil: ${jsonResponse['result']?['message']}");
          throw Exception(jsonResponse['result']?['message'] ?? 'Gagal memperbarui profil (Controller Error).');
        }
      } else {
        debugPrint("Server error: ${response.statusCode}, Body: ${response.body}");
        throw Exception('Gagal memperbarui profil. Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Exception during update: $e");
      throw Exception('Error saat memperbarui profil: $e');
    }
  }
  
  /// Logout pengguna
  Future<void> signOut() async {
    _sessionCookie = null;
    debugPrint("[ApiService] User signed out.");
  }

  /// Mengambil daftar masjid dengan filter pencarian dan area
  Future<List<Mosque>> getMosques({String? search, int? areaId}) async {
    try {
      // Siapkan Query Parameters
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (areaId != null) {
        queryParams['area_id'] = areaId.toString();
      }

      final uri = Uri.parse('$_baseUrl/api/v1/mosques').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      debugPrint('[ApiService] Fetching mosques from: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => Mosque.fromJson(json)).toList();
        } else {
          throw Exception(jsonResponse['message'] ?? 'Unknown API error');
        }
      } else {
        throw Exception(
            'Server merespons dengan error. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server. Periksa koneksi Anda. Error: $e');
    }
  }

  /// Mengambil detail satu masjid
  Future<Mosque> getMosqueDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/mosques/$id'),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final Map<String, dynamic> data = jsonResponse['data'];
          // Pastikan Mosque.fromDetailJson() sudah terbaru
          return Mosque.fromDetailJson(data);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Unknown API error');
        }
      } else {
        throw Exception(
            'Gagal memuat detail masjid. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server. Periksa koneksi internet Anda.');
    }
  }

  /// Mengambil daftar semua Da'i
  Future<List<Preacher>> getPreachers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/preachers'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => Preacher.fromJson(json)).toList();
        } else {
          throw Exception(jsonResponse['message'] ?? 'Unknown API error');
        }
      } else {
        throw Exception(
            'Gagal memuat daftar Da\'i dari API. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server. Periksa koneksi internet Anda.');
    }
  }

  /// Mengambil detail satu Da'i
  Future<Preacher> getPreacherDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/preachers/$id'),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final Map<String, dynamic> data = jsonResponse['data'];
          return Preacher.fromDetailJson(data);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Unknown API error');
        }
      } else {
        throw Exception(
            'Gagal memuat detail Da\'i. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server. Periksa koneksi internet Anda.');
    }
  }
  
  Future<List<Map<String, dynamic>>> getAreas() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/areas'),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          // Kita kembalikan sebagai List<Map> agar mudah dipakai di dropdown
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Unknown API error');
        }
      } else {
        throw Exception(
            'Gagal memuat daftar area. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSpecializations() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/specializations'),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Unknown API error');
        }
      } else {
        throw Exception(
            'Gagal memuat daftar spesialisasi. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  /// Mengambil daftar semua Area untuk filter
  // Future<List<dynamic>> getAreas() async {
  //   final uri = Uri.parse('$_baseUrl/api/v1/areas');
  //   debugPrint('[ApiService] Fetching areas: $uri');

  //   try {
  //     final response = await http.get(uri);

  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       if (jsonResponse['status'] == 'success') {
  //         return jsonResponse['data'] as List<dynamic>;
  //       } else {
  //         throw Exception(jsonResponse['message'] ?? 'Unknown API error');
  //       }
  //     } else {
  //       throw Exception('Gagal memuat area. Status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Gagal terhubung ke server: $e');
  //   }
  // }

  // /// Mengambil daftar semua Specialization untuk filter
  // Future<List<dynamic>> getSpecializations() async {
  //   final uri = Uri.parse('$_baseUrl/api/v1/specializations');
  //   debugPrint('[ApiService] Fetching specializations: $uri');

  //   try {
  //     final response = await http.get(uri);

  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       if (jsonResponse['status'] == 'success') {
  //         return jsonResponse['data'] as List<dynamic>;
  //       } else {
  //         throw Exception(jsonResponse['message'] ?? 'Unknown API error');
  //       }
  //     } else {
  //       throw Exception('Gagal memuat specializations. Status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Gagal terhubung ke server: $e');
  //   }
  // }

  // --- FUNGSI BARU UNTUK HALAMAN JADWAL PUBLIK ---
  /// Mengambil daftar jadwal publik (mendatang & confirmed)
  /// Mendukung filter search, areaId, dan dayOfWeek
  Future<List<PublicSchedule>> getPublicSchedules({
    String? search,
    int? areaId,
    int? dayOfWeek,
  }) async {
    try {
      // 1. Siapkan Query Parameters
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (areaId != null) {
        queryParams['area_id'] = areaId.toString();
      }
      if (dayOfWeek != null) {
        queryParams['day_of_week'] = dayOfWeek.toString();
      }

      // 2. Buat URI
      final uri = Uri.parse('$_baseUrl/api/v1/schedules/public').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      debugPrint('[ApiService] Fetching public schedules from: $uri');

      // 3. Panggil API (auth public, tidak perlu cookie)
      final response = await http.get(uri);

      // 4. Proses Respon
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'];
          // 5. Parsing menggunakan model baru
          return data.map((json) => PublicSchedule.fromJson(json)).toList();
        } else {
          throw Exception(jsonResponse['message'] ?? 'Unknown API error');
        }
      } else {
        throw Exception(
            'Server merespons dengan error. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server. Error: $e');
    }
  }
  // --------------------------------------------------


  // --- METODE UNTUK NOTIFIKASI UNDANGAN (Preacher) ---

  Future<List<Invitation>> getPendingInvitations() async {
    if (_sessionCookie == null) {
      throw Exception('Anda harus login untuk melihat undangan.');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/schedules/pending'),
        headers: {'Cookie': _sessionCookie!},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => Invitation.fromJson(json)).toList();
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception('Gagal memuat undangan. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saat mengambil undangan: $e');
    }
  }

  Future<bool> confirmInvitation(int scheduleId) async {
    if (_sessionCookie == null) {
      throw Exception('Anda harus login untuk aksi ini.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/schedules/$scheduleId/confirm'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': _sessionCookie!,
      },
      body: json.encode({"jsonrpc": "2.0", "params": {}}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Odoo JSON-RPC membungkusnya dalam 'result'
      return jsonResponse['result']?['status'] == 'success';
    }
    return false;
  }

  Future<bool> rejectInvitation(int scheduleId) async {
    if (_sessionCookie == null) {
      throw Exception('Anda harus login untuk aksi ini.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/schedules/$scheduleId/reject'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': _sessionCookie!,
      },
      body: json.encode({"jsonrpc": "2.0", "params": {}}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['result']?['status'] == 'success';
    }
    return false;
  }
}