import 'dart:ffi';

/// ============================================================================
/// 📌 CHEATSHEET RESPONSI: PANDUAN MODEL JIKA API DIGANTI
/// ============================================================================
/// Model ini merepresentasikan satu item data dari API.
/// Jika API diganti (misal: Produk, Berita, Buku, Film):
/// 1. Ubah/tambah atribut sesuai kunci (keys) JSON di API baru.
/// 2. Sesuaikan factory constructor [fromJson] dengan key JSON dari API.
/// 3. Gunakan operator fallback `?? ''` atau `?? 0` untuk menghindari error `Null check operator used on a null value`.
/// ============================================================================

class Character {
  // --------------------------------------------------------------------------
  // 1. ATRIBUT DATA
  // 👉 Sesuaikan tipe data dan nama variabel dengan kebutuhan soal/API baru.
  // Contoh jika API Produk:
  // final int id;
  // final String title;
  // final double price;
  // final String description;
  // final String category;
  // final String image;
  // --------------------------------------------------------------------------
  final int id;
  final String title;
  final String description;
  final String category;
  final Double price;
  final Double discountPercentage;
  final Double rating;
  final Double stock;
  final String brand;
  final String images;

  Character({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.images,
  });

  // --------------------------------------------------------------------------
  // 2. FROM JSON (Desirialisasi dari Response API ke Object Dart)
  // 👉 Ganti string kunci di json['...'] sesuai struktur JSON dari API baru!
  // --------------------------------------------------------------------------
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      title: json['title'] ?? '', // Berikan default value jika null
      description: json['description'] ?? 'unknown',
      category: json['category'] ?? '',
      price: json['price'] ?? '',
      brand: json['brand'] ?? '',
      images: json['images'] ?? '',
      discountPercentage: json['discountPercentage'] ?? '', // URL foto/gambar
      // Contoh mengambil data nested object di JSON:
      // Di Rick & Morty: "origin": { "name": "Earth", "url": "..." }
      rating: json['rating'] != null
          ? (json['origin']['name'] ?? 'unknown')
          : 'unknown',
      stock: json['stock'] != null
          ? (json['location']['name'] ?? 'unknown')
          : 'unknown',
    );
  }

  // --------------------------------------------------------------------------
  // 3. TO JSON (Untuk Disimpan ke Shared Preferences sebagai Favorit)
  // 👉 Pastikan method ini menyimpan semua atribut yang ingin disimpan di favorit!
  // --------------------------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'images': images,
    };
  }
}
