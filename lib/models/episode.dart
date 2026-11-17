/// ============================================================================
/// 📌 CHEATSHEET RESPONSI: MODEL KEDUA (EPISODE / KATEGORI / REVIEWS)
/// ============================================================================
/// Model sekunder untuk endpoint kedua di aplikasi.
/// Sesuaikan atribut dan [fromJson] dengan respons JSON endpoint kedua.
/// ============================================================================

class Episode {
  final int id;
  final String name;
  final String airDate;
  final String episodeCode;

  Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episodeCode,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as int,
      name: json['name'] ?? '',
      airDate: json['air_date'] ?? '', // Di API lain mungkin 'release_date' atau 'created_at'
      episodeCode: json['episode'] ?? '',
    );
  }
}
