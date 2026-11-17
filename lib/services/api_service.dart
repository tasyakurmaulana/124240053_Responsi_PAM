import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';

  /// 1. Mengambil Daftar Produk (dengan Filter Kategori & Fitur Pencarian)
  /// Minimal 10 produk dari API
  static Future<List<Product>> getProducts({
    String? category,
    String? search,
  }) async {
    Uri uri;

    if (search != null && search.trim().isNotEmpty) {
      // Endpoint pencarian DummyJSON: /products/search?q=...
      uri = Uri.parse('$baseUrl/products/search').replace(
        queryParameters: {'q': search.trim()},
      );
    } else if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all') {
      // Endpoint filter kategori DummyJSON: /products/category/{category}
      uri = Uri.parse('$baseUrl/products/category/${category.toLowerCase()}');
    } else {
      // Endpoint semua produk: /products
      uri = Uri.parse('$baseUrl/products');
    }

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['products'] ?? [];
        return results.map((item) => Product.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Gagal memuat data produk (HTTP ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

  /// 2. Mengambil Detail Satu Produk Berdasarkan ID
  /// Endpoint: /products/{id}
  static Future<Product> getProductDetail(int id) async {
    final uri = Uri.parse('$baseUrl/products/$id');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Produk tidak ditemukan (HTTP ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal memuat detail produk: $e');
    }
  }

  /// 3. Mengambil Seluruh Kategori
  /// Endpoint: /products/category-list sesuai ketentuan soal responsi
  static Future<List<String>> getCategories() async {
    final uri = Uri.parse('$baseUrl/products/category-list');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // API DummyJSON /products/category-list mengembalikan List<dynamic> (string)
        if (data is List) {
          return data.map((item) {
            if (item is Map) {
              return (item['slug'] ?? item['name'] ?? '').toString();
            }
            return item.toString();
          }).toList();
        }
        return [];
      } else {
        // Fallback jika category-list gagal
        return ['beauty', 'fragrances', 'furniture', 'groceries'];
      }
    } catch (e) {
      // Fallback kategori dasar jika offline
      return ['beauty', 'fragrances', 'furniture', 'groceries'];
    }
  }
}
