import 'package:intl/intl.dart';

// Class baru untuk merepresentasikan satu jadwal
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
    print("DEBUG START_TIME: $startTime");
    // Tambahkan pengecekan jika startTime kosong
    if (startTime.isEmpty) {
      return 'Tanggal tidak valid';
    }
    try {
      // KEMBALI MENGGUNAKAN DateTime.parse()
      // Fungsi ini secara default bisa membaca format ISO 8601 (dengan 'T')
      final dateTime = DateTime.parse(startTime);
      print('✅ Berhasil parse: $dateTime');
      return DateFormat('EEEE, d MMMM yyyy').format(dateTime);
    } catch (e) {
      print("Error parsing date '$startTime': $e");
      return 'Tanggal tidak valid';
    }
  }

  String get formattedTime {
    // Tambahkan pengecekan jika startTime kosong
    if (startTime.isEmpty) {
      return '--:--';
    }
     try {
      // KEMBALI MENGGUNAKAN DateTime.parse()
      final dateTime = DateTime.parse(startTime);
      print('✅ Berhasil parse: $dateTime');
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      print("Error parsing time '$startTime': $e");
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

class Mosque {
  final int id;
  final String name;
  final String? code;
  final String area; // Ganti ini dari fullAddress
  final String? description;
  final String? imageUrl;
  final List<Schedule>? schedules;
  
  Mosque({
    required this.id,
    required this.name,
    this.code,
    required this.area, // Tambahkan di constructor
    this.description,
    this.imageUrl,
    this.schedules,
  });

  // Fungsi ini untuk data dari DAFTAR masjid
  // Untuk DAFTAR masjid
  factory Mosque.fromJson(Map<String, dynamic> json) {
  return Mosque(
    id: json['id'] ?? 0,
    name: json['name'] ?? 'No Name',
    code: json['code']?.toString(),  // Ubah ke String?
    area: json['area']?.toString() ?? 'No Area',  // Pastikan String
    imageUrl: json['image_url']?.toString(),      // Pastikan String?
  );
}

  // Untuk DETAIL masjid
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
     code: json['code']?.toString(),  // Ubah ke String?
      area: json['area']?.toString() ?? 'No Area',  // Pastikan String
      description: json['description']?.toString() ?? 'tidak ada diskripsi',  // Pastikan String,
      imageUrl: json['image_url']?.toString(),      // Pastikan String?
      schedules: scheduleList, // <-- Masukkan daftar jadwal
    );
  }
}