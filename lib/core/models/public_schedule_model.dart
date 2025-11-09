import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:intl/intl.dart';

/// Model ini merepresentasikan data jadwal yang ditampilkan
/// di tab "Jadwal" publik (pengganti Notifikasi).
/// Datanya berasal dari endpoint /api/v1/schedules/public
class PublicSchedule {
  final int id;
  final String topic;
  final String startTime; // ISO 8601 string, e.g., "2025-11-10T10:00:00"
  final String preacherName;
  final String mosqueName;
  final int? mosqueId;

  PublicSchedule({
    required this.id,
    required this.topic,
    required this.startTime,
    required this.preacherName,
    required this.mosqueName,
    this.mosqueId,
  });

  /// Factory untuk mem-parsing JSON dari Odoo API
  factory PublicSchedule.fromJson(Map<String, dynamic> json) {
    return PublicSchedule(
      id: json['id'] ?? 0,
      topic: json['topic'] ?? 'Topik Belum Ada',
      startTime: json['start_time'] ?? '',
      preacherName: json['preacher_name'] ?? 'N/A',
      mosqueName: json['mosque_name'] ?? 'N/A',
      mosqueId: json['mosque_id'] as int?,
    );
  }

  // --- Helper Getters untuk Format Waktu ---
  // Menggunakan 'id_ID' untuk format Bahasa Indonesia

  /// Mengkonversi string ISO 8601 ke objek DateTime
  DateTime? get _dateTime {
    try {
      // Pastikan string tidak kosong
      if (startTime.isEmpty) return null;
      return DateTime.parse(startTime);
    } catch (e) {
      debugPrint("Error parsing date '$startTime': $e");
      return null;
    }
  }

  /// Mengembalikan tanggal lengkap
  /// Contoh: "Senin, 10 Nov 2025"
  String get formattedFullDate {
    final dt = _dateTime;
    if (dt == null) return 'Tanggal Belum Dikonfirmasi';
    // Pastikan locale 'id_ID' terdaftar di main.dart
    return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(dt);
  }

  /// Mengembalikan waktu
  /// Contoh: "10:00 WIB"
  String get formattedTime {
    final dt = _dateTime;
    if (dt == null) return '--:--';
    // 'z' akan otomatis mengambil zona waktu (e.g., WIB)
    // Pastikan locale 'id_ID' terdaftar di main.dart
    return DateFormat('HH:mm z', 'id_ID').format(dt);
  }
  
  /// Mengembalikan singkatan hari
  /// Contoh: "SEN"
  String get formattedDayAbbr {
     final dt = _dateTime;
     if (dt == null) return 'N/A';
     return DateFormat('E', 'id_ID').format(dt).toUpperCase();
  }

  /// Mengembalikan angka tanggal
  /// Contoh: "10"
  String get formattedDateNum {
     final dt = _dateTime;
     if (dt == null) return '?';
     return DateFormat('d').format(dt);
  }
}