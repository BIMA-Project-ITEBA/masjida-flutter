import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/preacher_model.dart';
import '../models/mosque_model.dart';

class ApiService {
  final String _baseUrl = "http://103.13.206.132:8069";
  String? _sessionCookie;

  Future<void> _authenticate() async {
    // ... (kode autentikasi tidak diubah, sudah benar)
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/web/session/authenticate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "jsonrpc": "2.0",
          "params": {"db": "masjida", "login": "admin", "password": "admin"}
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

  // === HEADER CONTENT-TYPE DIHAPUS DARI GET REQUEST ===
  Future<List<Mosque>> getMosques() async {
    if (_sessionCookie == null) await _authenticate();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/mosques'),
      headers: {
        // 'Content-Type' tidak diperlukan untuk GET!
        'Cookie': _sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['result']['data'];
      return data.map((json) => Mosque.fromJson(json)).toList();
    } else {
      print('Gagal memuat masjid. Status: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('Gagal memuat daftar masjid dari API.');
    }
  }

  // === HEADER CONTENT-TYPE DIHAPUS DARI GET REQUEST ===
  Future<Mosque> getMosqueDetail(int id) async {
    if (_sessionCookie == null) await _authenticate();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/mosques/$id'),
      headers: {
        'Cookie': _sessionCookie!,
      },
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final Map<String, dynamic> data = jsonResponse['result']['data'];
      return Mosque.fromDetailJson(data);
    } else {
      throw Exception(
          'Gagal memuat detail masjid. Status: ${response.statusCode}');
    }
  }

  // === HEADER CONTENT-TYPE DIHAPUS DARI GET REQUEST ===
  Future<List<Preacher>> getPreachers() async {
    if (_sessionCookie == null) await _authenticate();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/preachers'),
      headers: {
        'Cookie': _sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['result']['data'];
      return data.map((json) => Preacher.fromJson(json)).toList();
    } else {
      throw Exception(
          'Gagal memuat daftar Da\'i dari API. Status: ${response.statusCode}');
    }
  }
}

