import 'package:intl/intl.dart';

class Invitation {
  final int id;
  final String topic;
  final String? startTime;
  final String? endTime;
  final String? description;
  final String mosqueName;
  final String? mosqueImageUrl;

  Invitation({
    required this.id,
    required this.topic,
    this.startTime,
    this.endTime,
    this.description,
    required this.mosqueName,
    this.mosqueImageUrl,
  });

  String get formattedDate {
    if (startTime == null) return 'Tanggal tidak valid';
    try {
      final dateTime = DateTime.parse(startTime!);
      return DateFormat('EEEE, d MMMM yyyy').format(dateTime);
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

    String get formattedTime {
    if (startTime == null) return '--:--';
    try {
      final dateTime = DateTime.parse(startTime!);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '--:--';
    }
  }

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id']??0,
      topic: json['topic']?.toString() ?? 'No topic',
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      description: json['description']?.toString() ?? 'tidak ada diskripsi',
      mosqueName: json['mosque_name']?.toString() ?? 'No mosque',
      mosqueImageUrl: json['mosque_image_url']?.toString(),
    );
  }
}
