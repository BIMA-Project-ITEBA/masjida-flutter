class Mosque {
  final int id;
  final String name;
  final String? fullAddress;
  final String? description;
  final String? imageUrl;

  Mosque({
    required this.id,
    required this.name,
    this.fullAddress,
    this.description,
    this.imageUrl,
  });

  // Fungsi ini untuk data dari DAFTAR masjid
  factory Mosque.fromJson(Map<String, dynamic> json) {
    return Mosque(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      // Di daftar, namanya 'address' bukan 'full_address'
      fullAddress: json['address'] ?? 'No Address',
      imageUrl: json['image_url'],
    );
  }

  // Fungsi BARU, khusus untuk data dari DETAIL masjid
  factory Mosque.fromDetailJson(Map<String, dynamic> json) {
    return Mosque(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      fullAddress: json['full_address'] ?? 'No Address',
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }
}

