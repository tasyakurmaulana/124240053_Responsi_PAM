import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/preference_service.dart';

class DetailScreen extends StatefulWidget {
  final Character character;

  const DetailScreen({super.key, required this.character});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = PreferenceService.instance.isFavorite(widget.character.id);
  }

  Future<void> _toggleFavorite() async {
    final added = await PreferenceService.instance.toggleFavorite(widget.character);
    setState(() {
      _isFavorite = added;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${widget.character.title} ditambahkan ke favorit!'
              : '${widget.character.title} dihapus dari favorit.',
        ),
        backgroundColor: added ? const Color(0xFF7C3AED) : const Color(0xFFEF4444),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return const Color(0xFF10B981); // Hijau
      case 'dead':
        return const Color(0xFFEF4444); // Merah
      default:
        return const Color(0xFFF59E0B); // Amber / Kuning
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = const Color(0xFF7C3AED),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.character;
    final statusColor = _getStatusColor(c.category);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          c.title,
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? const Color(0xFFEF4444) : const Color(0xFF64748B),
              size: 28,
            ),
            tooltip: _isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Gambar Karakter
            Center(
              child: Hero(
                tag: 'char-${c.id}',
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withOpacity(0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      c.title,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Nama & Status Badge
            Text(
              c.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(radius: 4, backgroundColor: statusColor),
                  const SizedBox(width: 8),
                  Text(
                    c.category.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detail Attributes
            _buildInfoRow(
              icon: Icons.category_outlined,
              label: 'Spesies',
              value: c.brand.isNotEmpty ? c.brand : 'Unknown',
              iconColor: const Color(0xFF7C3AED), // Ungu
            ),
            _buildInfoRow(
              icon: Icons.transgender_outlined,
              label: 'Gender',
              value: c.brand.isNotEmpty ? c.brand : 'Unknown',
              iconColor: const Color(0xFFF59E0B), // Kuning
            ),
            _buildInfoRow(
              icon: Icons.public_outlined,
              label: 'Origin',
              value: c.description.isNotEmpty ? c.description : 'Unknown',
              iconColor: const Color(0xFF10B981), // Hijau
            ),
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Location',
              value: c.description.isNotEmpty ? c.description : 'Unknown',
              iconColor: const Color(0xFF3B82F6), // Biru
            ),
            const SizedBox(height: 20),

            // Tombol Favorite
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? const Color(0xFFEF4444) : Colors.white,
                ),
                label: Text(
                  _isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFavorite ? Colors.white : const Color(0xFF7C3AED),
                  foregroundColor: _isFavorite ? const Color(0xFF0F172A) : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: _isFavorite ? const BorderSide(color: Color(0xFFEF4444), width: 1.5) : BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: _isFavorite ? 0 : 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
