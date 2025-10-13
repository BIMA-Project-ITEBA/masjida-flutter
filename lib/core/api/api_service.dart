import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/preacher_model.dart';
import '../models/mosque_model.dart';

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

  Future<void> _authenticate() async {
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

  Future<List<Mosque>> getMosques() async {
    try {
      print("FINAL URL: $_baseUrl/api/v1/mosques");
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/mosques'),
      );

      if (response.statusCode == 200) {
        print("RESPONSE BODY: ${response.body}"); 
        final jsonResponse = json.decode(response.body);
        print("RESPONSE DATA: $jsonResponse");
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => Mosque.fromJson(json)).toList();
        } else {
          // Menangani error yang dikirim oleh API Odoo
          throw Exception(jsonResponse['message'] ?? 'Unknown API error');
        }
      } else {
        // Menangani error level HTTP (404, 500, dll.)
        print('Gagal memuat masjid. Status: ${response.statusCode}');
        print('Body: ${response.body}');
        throw Exception(
            'Server merespons dengan error. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Menangani error koneksi (tidak ada internet, server down, CORS, dll.)
      print('TERJADI ERROR KONEKSI (getMosques): $e');
      throw Exception('Gagal terhubung ke server. Periksa koneksi internet dan konfigurasi server Anda.');
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
      print('TERJADI ERROR KONEKSI (getMosqueDetail): $e');
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
       print('TERJADI ERROR KONEKSI (getPreachers): $e');
      throw Exception('Gagal terhubung ke server. Periksa koneksi internet Anda.');
    }
  }
}