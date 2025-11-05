class UserProfile {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? imageUrl;
  // Tambahkan field lain jika Anda membutuhkannya dari API
  // final String? gender;
  // final String? dateOfBirth;

  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.imageUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      email: json['email']?.toString() ?? 'No email',
      phone: json['phone']?.toString() ?? 'No phone',
      imageUrl: json['image_url']?.toString(),
    );
  }
}