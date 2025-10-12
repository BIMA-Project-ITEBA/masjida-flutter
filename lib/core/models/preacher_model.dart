class Preacher {
  final int id;
  final String name;
  final String specialization;
  final String? imageUrl; // Dibuat bisa null karena data dari API bisa null

  Preacher({
    required this.id,
    required this.name,
    required this.specialization,
    this.imageUrl,
  });

  // Fungsi ini akan mengubah data JSON dari API menjadi objek Preacher
  factory Preacher.fromJson(Map<String, dynamic> json) {
    return Preacher(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      specialization: json['specialization'] ?? 'N/A',
      imageUrl: json['image_url'], 
    );
  }
}
