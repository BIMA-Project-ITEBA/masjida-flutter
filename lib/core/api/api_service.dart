import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mosque_model.dart';
import '../models/preacher_model.dart';
import '../models/invitation_model.dart';

class ApiService {
  final String _baseUrl = "http://103.13.206.132:8069";
  String? _sessionCookie;

  String getFullImageUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) {
      return 'https://placehold.co/600x400/e2e8f0/e2e8f0?text=';
    }
    return '$_baseUrl$relativeUrl';
  }

  // === FUNGSI SIGN IN BARU YANG SEHARUSNYA KAMU PAKAI ===
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

  // === FUNGSI SIGN UP BARU YANG SEHARUSNYA KAMU PAKAI ===
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
      Uri.parse('$_baseUrl/api/v1/signup'), // <-- PASTIKAN ENDPOINT INI BENAR!
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
          "user_type": userType,
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

  // Helper untuk memastikan user sudah login
  Future<void> _ensureAuthenticated() async {
    if (_sessionCookie == null) {
      // Di sini kita tidak lagi auto-login sebagai admin
      // Kita lempar error agar UI bisa mengarahkan ke halaman login
      throw Exception('Sesi tidak valid. Silakan login kembali.');
    }
  }

  // --- SEMUA FUNGSI LAMA SEKARANG PAKAI _ensureAuthenticated ---

  Future<List<Mosque>> getMosques() async {
    await _ensureAuthenticated(); // Membutuhkan login
    // ... sisa kodenya sama seperti milikmu
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/mosques'),
        headers: { 'Cookie': _sessionCookie! },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['result']?['status'] == 'success') {
          final List<dynamic> data = jsonResponse['result']['data'];
          return data.map((json) => Mosque.fromJson(json)).toList();
        } else {
          throw Exception(jsonResponse['result']?['message'] ?? 'Unknown API error');
        }
      } else {
        throw Exception('Server error. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung. Periksa koneksi Anda.');
    }
  }

  Future<Mosque> getMosqueDetail(int id) async {
    await _ensureAuthenticated(); // Membutuhkan login
    // ... sisa kodenya sama seperti milikmu
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/mosques/$id'),
        headers: { 'Cookie': _sessionCookie! },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['result']?['status'] == 'success') {
          final Map<String, dynamic> data = jsonResponse['result']['data'];
          return Mosque.fromDetailJson(data);
        } else {
          throw Exception(jsonResponse['result']?['message'] ?? 'Unknown API error');
        }
      } else {
        throw Exception('Gagal memuat detail. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung. Periksa koneksi Anda.');
    }
  }

  Future<List<Preacher>> getPreachers() async {
    await _ensureAuthenticated(); // Membutuhkan login
    // ... sisa kodenya sama seperti milikmu
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/preachers'),
        headers: { 'Cookie': _sessionCookie! },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['result']?['status'] == 'success') {
          final List<dynamic> data = jsonResponse['result']['data'];
          return data.map((json) => Preacher.fromJson(json)).toList();
        } else {
          throw Exception(jsonResponse['result']?['message'] ?? 'Unknown API error');
        }
      } else {
        throw Exception('Gagal memuat Da\'i. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung. Periksa koneksi Anda.');
    }
  }

  Future<Preacher> getPreacherDetail(int id) async {
    await _ensureAuthenticated(); // Membutuhkan login
    // ... sisa kodenya sama seperti milikmu
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/preachers/$id'),
        headers: { 'Cookie': _sessionCookie! },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['result']?['status'] == 'success') {
          final Map<String, dynamic> data = jsonResponse['result']['data'];
          return Preacher.fromDetailJson(data);
        } else {
          throw Exception(jsonResponse['result']?['message'] ?? 'Unknown API error');
        }
      } else {
        throw Exception('Gagal memuat detail Da\'i. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung. Periksa koneksi Anda.');
    }
  }

  // Fungsi notifikasi tidak diubah sama sekali
  Future<List<Invitation>> getPendingInvitations() async {
    await _ensureAuthenticated();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/schedules/pending'),
        headers: {'Cookie': _sessionCookie!},
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['result']?['status'] == 'success') {
          final List<dynamic> data = jsonResponse['result']['data'];
          return data.map((json) => Invitation.fromJson(json)).toList();
        } else {
          throw Exception(jsonResponse['result']?['message']);
        }
      } else {
        throw Exception('Gagal memuat undangan. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saat mengambil undangan: $e');
    }
  }

  Future<bool> confirmInvitation(int scheduleId) async {
    await _ensureAuthenticated();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/schedules/$scheduleId/confirm'),
      headers: {'Cookie': _sessionCookie!},
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['result']?['status'] == 'success';
    }
    return false;
  }

  Future<bool> rejectInvitation(int scheduleId) async {
    await _ensureAuthenticated();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/schedules/$scheduleId/reject'),
      headers: {'Cookie': _sessionCookie!},
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['result']?['status'] == 'success';
    }
    return false;
  }
}

