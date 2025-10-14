import 'package:intl/intl.dart';

class PreacherSchedule {
  final int id;
  final String topic;
  final String startTime;
  final String mosqueName;

  PreacherSchedule({
    required this.id,
    required this.topic,
    required this.startTime,
    required this.mosqueName,
  });

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

  factory PreacherSchedule.fromJson(Map<String, dynamic> json) {
    return PreacherSchedule(
      id: json['id'] ?? 0,
      topic: json['topic'] ?? 'Topik tidak tersedia',
      startTime: json['start_time'] ?? '',
      mosqueName: json['mosque_name'] ?? 'N/A',
    );
  }
}

class Preacher {
  final int id;
  final String name;
  final String? code;
  final String specialization;
  final String? area;
  final String? bio; // <-- Field baru untuk biografi
  final String? imageUrl;
  final List<PreacherSchedule>? schedules; // <-- Field baru untuk jadwal

  Preacher({
    required this.id,
    required this.name,
    this.code,
    required this.specialization,
    this.area,
    this.bio,
    this.imageUrl,
    this.schedules,
  });

  factory Preacher.fromJson(Map<String, dynamic> json) {
    return Preacher(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      code: json['code']?.toString(),
      specialization: json['specialization'] ?? 'N/A',
      area: json['area']?.toString() ?? 'N/A',
      imageUrl: json['image_url']?.toString(),
    );
  }
   factory Preacher.fromDetailJson(Map<String, dynamic> json) {
    var scheduleList = <PreacherSchedule>[];
    if (json['schedules'] != null) {
      scheduleList = (json['schedules'] as List)
          .map((item) => PreacherSchedule.fromJson(item))
          .toList();
    }

    return Preacher(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      code: json['code']?.toString(),
      specialization: json['specialization']?.toString() ?? 'N/A',
      area: json['area']?.toString() ?? 'No area',
      bio: json['bio']?.toString(),
      imageUrl: json['image_url']?.toString(),
      schedules: scheduleList,
    );
  }
  
}