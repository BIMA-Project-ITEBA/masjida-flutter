class UserProfile {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? imageUrl;

  // --- FIELD BARU DITAMBAHKAN ---
  final String? bio;
  final String? education;
  final double? period;
  final String? gender;
  final String? dateOfBirth;
  final int? areaId;
  final String? areaName;
  final int? specializationId;
  final String? specializationName;
  // Tambahkan field lain dari API jika perlu

  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.imageUrl,
    // --- TAMBAHKAN DI CONSTRUCTOR ---
    this.bio,
    this.education,
    this.period,
    this.gender,
    this.dateOfBirth,
    this.areaId,
    this.areaName,
    this.specializationId,
    this.specializationName,
  });

  // Factory ini hanya untuk data minimal (jika masih dipakai di tempat lain)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      email: json['email']?.toString() ?? 'No email',
      phone: json['phone']?.toString() ?? 'No phone',
      imageUrl: json['image_url']?.toString(),
      bio: json['bio']?.toString(),
      education: json['education']?.toString(),
      period: (json['period'] is num) ? (json['period'] as num).toDouble() : null,
      gender: json['gender']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      areaId: json['area_id'] as int?,
      areaName: json['area_name']?.toString(),
      specializationId: json['specialization_id'] as int?,
      specializationName: json['specialization_name']?.toString(),
    );
  }

  // --- FACTORY BARU UNTUK DATA LENGKAP DARI /api/profile ---
  
}