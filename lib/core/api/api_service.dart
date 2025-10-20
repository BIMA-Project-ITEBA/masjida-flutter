import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mosque_model.dart';
import '../models/preacher_model.dart';
import '../models/invitation_model.dart'; // <-- Pastikan import ini ada

class ApiService {
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
      print("Login berhasil!");
      String? rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        int index = rawCookie.indexOf(';');
        _sessionCookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
        return true;
      }
    }
    return false;
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? dateOfBirth,
    String? gender,
    required String userType,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/register_user'), // <-- PASTIKAN ENDPOINT INI BENAR!
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
          "user_type": "preacher"
        }
      }),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['result']?['status'] == 'success') {
        print("Registrasi berhasil!");
        return true;
      } else {
        throw Exception(jsonResponse['result']?['message'] ?? 'Registrasi gagal.');
      }
    } else {
      throw Exception('Gagal mendaftar. Server error.');
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
      throw Exception('Anda harus login untuk melihat undangan.');
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
      throw Exception('Anda harus login untuk melihat undangan.');
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