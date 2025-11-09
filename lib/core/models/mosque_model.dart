import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

// Class untuk merepresentasikan satu jadwal (milik masjid)
class Schedule {
  final int id;
  final String topic;
  final String startTime;
  final String preacherName;

  Schedule({
    required this.id,
    required this.topic,
    required this.startTime,
    required this.preacherName,
  });

  // Helper getter untuk memformat tanggal agar lebih mudah dibaca
  String get formattedDate {
    if (startTime.isEmpty) {
      return 'Tanggal tidak valid';
    }
    try {
      // Menggunakan DateTime.parse()
      // Odoo mengirimkan format ISO 8601 (2025-11-05 15:00:00)
      // yang dapat diparsing langsung oleh Dart.
      final dateTime = DateTime.parse(startTime);
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      debugPrint("Error parsing date '$startTime': $e");
      return 'Tanggal tidak valid';
    }
  }

  String get formattedTime {
    if (startTime.isEmpty) {
      return '--:--';
    }
     try {
      final dateTime = DateTime.parse(startTime);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      debugPrint("Error parsing time '$startTime': $e");
      return '--:--';
    }
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? 0,
      topic: json['topic']?.toString() ?? 'Topik tidak tersedia',
      startTime: json['start_time']?.toString() ?? '',
      preacherName: json['preacher_name']?.toString() ?? 'N/A',
    );
  }
}

// Class utama untuk model Masjid
class Mosque {
  final int id;
  final String name;
  final String? code;
  final String area; // Ini adalah 'area.name' dari Odoo
  final String? description;
  final String? imageUrl;
  final List<Schedule>? schedules;
  
  // --- FIELD BARU UNTUK GOOGLE MAPS & ALAMAT ---
  final String? fullAddress; // Alamat lengkap
  final double? latitude;     // Koordinat
  final double? longitude;    // Koordinat
  // ------------------------------------------

  Mosque({
    required this.id,
    required this.name,
    this.code,
    required this.area,
    this.description,
    this.imageUrl,
    this.schedules,
    // --- TAMBAHKAN DI CONSTRUCTOR ---
    this.fullAddress,
    this.latitude,
    this.longitude,
  });

  // Factory untuk data dari DAFTAR masjid (API: /api/v1/mosques)
  // Data ini minimal, tidak termasuk jadwal atau lat/lon
  factory Mosque.fromJson(Map<String, dynamic> json) {
    return Mosque(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      code: json['code']?.toString(),
      area: json['area']?.toString() ?? 'No Area',
      imageUrl: json['image_url']?.toString(),
    );
  }

  // Factory untuk data dari DETAIL masjid (API: /api/v1/mosques/<id>)
  // Data ini lengkap, termasuk jadwal dan data Google Maps
  factory Mosque.fromDetailJson(Map<String, dynamic> json) {
    var scheduleList = <Schedule>[];
    if (json['schedules'] != null) {
      scheduleList = (json['schedules'] as List)
          .map((item) => Schedule.fromJson(item))
          .toList();
    }

    return Mosque(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      code: json['code']?.toString(),
      area: json['area']?.toString() ?? 'No Area',
      description: json['description']?.toString() ?? 'Tidak ada deskripsi',
      imageUrl: json['image_url']?.toString(),
      schedules: scheduleList,
      
      // --- TAMBAHAN PARSING BARU ---
      fullAddress: json['full_address']?.toString(),
      // Konversi 'num' (bisa int atau double) dari JSON ke 'double'
      latitude: (json['latitude'] is num) 
          ? (json['latitude'] as num).toDouble() 
          : null,
      longitude: (json['longitude'] is num) 
          ? (json['longitude'] as num).toDouble() 
          : null,
      // ----------------------------
    );
  }
}