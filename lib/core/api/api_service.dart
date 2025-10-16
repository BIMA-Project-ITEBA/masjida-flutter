import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mosque_model.dart';
import '../models/preacher_model.dart';
import '../models/invitation_model.dart'; // <-- Pastikan import ini ada

class ApiService {
  final String _baseUrl = "http://localhost:8069";
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

  Future<void> _authenticate() async {
    // Fungsi ini akan dijalankan secara otomatis jika belum ada sesi.
    // Pastikan db, login, dan password sesuai dengan server Odoo Anda.
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/web/session/authenticate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "jsonrpc": "2.0",
          "params": {"db": "admin", "login": "admin", "password": "admin"}
        }),
      );

      if (response.statusCode == 200) {
        print("Autentikasi berhasil!");
        String? rawCookie = response.headers['set-cookie'];
        if (rawCookie != null) {
          int index = rawCookie.indexOf(';');
          _sessionCookie =
              (index == -1) ? rawCookie : rawCookie.substring(0, index);
        } else {
          throw Exception('Header set-cookie tidak ditemukan.');
        }
      } else {
        throw Exception('Gagal melakukan autentikasi ke server.');
      }
    } catch (e) {
      print("ERROR di _authenticate: $e");
      throw Exception('Gagal terhubung ke server untuk autentikasi.');
    }
  }

  Future<List<Mosque>> getMosques() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/mosques'),
      );

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
      throw Exception('Gagal terhubung ke server. Periksa koneksi internet Anda.');
    }
  }

  Future<Mosque> getMosqueDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/mosques/$id'),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final Map<String, dynamic> data = jsonResponse['data'];
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

  // === METODE BARU UNTUK NOTIFIKASI ===

  Future<List<Invitation>> getPendingInvitations() async {
    // Membutuhkan login, jadi kita panggil authenticate
    if (_sessionCookie == null) await _authenticate();

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
    if (_sessionCookie == null) await _authenticate();

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
    if (_sessionCookie == null) await _authenticate();

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

