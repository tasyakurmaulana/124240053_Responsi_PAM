import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/episode.dart';

/// ============================================================================
/// 📌 CHEATSHEET RESPONSI: PANDUAN JIKA API DIGANTI SAAT RESPONSI
/// ============================================================================
/// Saat responsi dengan API baru (misal: PokeAPI, FakeStore, NewsAPI, dll),
/// ada 4 hal utama yang WAJIB disesuaikan di file ini:
///
/// 1. [baseUrl] : Ganti dengan domain dasar API yang diberikan dosen/asisten.
/// 2. [Endpoint & Path] : Sesuaikan path URL (misal: '/products', '/pokemon', '/articles').
/// 3. [Struktur JSON Response] :
///    - Apakah response langsung berupa List: `final List data = jsonDecode(response.body);`?
///    - Atau dibungkus object dengan key: `data['results']`, `data['data']`, `data['articles']`?
/// 4. [Query Parameters] : Sesuaikan nama parameter pencarian & filter
///    (misal: `?q=`, `?search=`, `?category=`, `?status=`).
/// ============================================================================

class ApiService {
  // --------------------------------------------------------------------------
  // 1. BASE URL
  // 👉 UBAH INI jika dosen memberikan API baru.
  // Contoh lain:
  // - https://fakestoreapi.com
  // - https://pokeapi.co/api/v2
  // - https://dummyjson.com
  // --------------------------------------------------------------------------
  static const String baseUrl = 'https://dummyjson.com/products';

  // --------------------------------------------------------------------------
  // 2. GET LIST DATA (dengan Filter & Search)
  // --------------------------------------------------------------------------
  /// Mengambil daftar data dari API.
  /// 👉 UBAH parameter jika filter soal meminta kategori/jenis lain.
  static Future<List<Character>> getCharacters({
    String? category,
    String? title,
  }) async {
    // A. Menyusun Query Parameters (?key=value)
    final Map<String, String> queryParams = {};

    // 👉 UBAH NAMA PARAMETER sesuai dokumentasi API baru.
    // Contoh di Rick & Morty: ?status=alive&title=rick
    // Contoh di DummyJSON / FakeStore: ?category=electronics&q=phone
    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      queryParams['category'] = category.toLowerCase(); // Ganti 'status' jika API lain pakai 'category', 'gender', dll
    }
    if (title != null && title.trim().isNotEmpty) {
      queryParams['title'] = title.trim(); // Ganti 'title' jika API lain pakai 'search' atau 'q'
    }

    // B. Menyusun URL lengkap endpoint
    // 👉 UBAH '/character' sesuai endpoint list data di API baru (misal: '/products', '/posts')
    final uri = Uri.parse('$baseUrl/products').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    try {
      // Melakukan HTTP GET request dengan timeout 12 detik
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      // C. Cek Status Code HTTP
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // --------------------------------------------------------------------
        // ⚠️ PENTING: CEK BENTUK RESPONSE JSON DARI API!
        // --------------------------------------------------------------------
        // Kasus 1: JSON dibungkus object dengan key (seperti Rick & Morty: {"results": [...]})
        final List results = data['results'] ?? [];

        // Kasus 2: JIKA API baru langsung mengembalikan array `[...]` (seperti FakeStoreAPI):
        // Pakai: `final List results = data;` (jika data itu sendiri adalah List)

        // Kasus 3: Key lain (misal: data['data'] atau data['articles']):
        // Pakai: `final List results = data['data'] ?? [];`
        // --------------------------------------------------------------------

        // Mapping setiap item JSON menjadi object Model (Character)
        return results.map((item) => Character.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        // Khusus Rick & Morty: return 404 jika hasil pencarian tidak ditemukan
        return [];
      } else {
        throw Exception('Gagal memuat data (HTTP ${response.statusCode})');
      }
    } catch (e) {
      // Tangkap error koneksi internet / timeout / parsing
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

  // --------------------------------------------------------------------------
  // 3. GET DETAIL DATA BY ID
  // --------------------------------------------------------------------------
  /// Mengambil detail satu item berdasarkan ID
  /// Endpoint contoh: https://rickandmortyapi.com/api/character/1
  static Future<Character> getCharacterDetail(int id) async {
    // 👉 UBAH format endpoint sesuai API baru (misal: '$baseUrl/products/$id')
    final uri = Uri.parse('$baseUrl/products/$id');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Detail biasanya mengembalikan satu Map object JSON `{...}`
        return Character.fromJson(data);
      } else {
        throw Exception('Data tidak ditemukan (HTTP ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal memuat detail data: $e');
    }
  }

  // --------------------------------------------------------------------------
  // 4. GET SECOND LIST / EPISODES
  // --------------------------------------------------------------------------
  /// Endpoint kedua (misal: /episode, /categories, /reviews, dll)
  static Future<List<Episode>> getEpisodes() async {
    //👉UBAH '/episode' sesuai endpoint fitur tambahan di API baru
    final uri = Uri.parse('$baseUrl/episode');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        //Cek apakah dibungkus 'results' atau langsung list
        final List results = data['results'] ?? [];
        return results.map((item) => Episode.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat data episode (HTTP ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}
