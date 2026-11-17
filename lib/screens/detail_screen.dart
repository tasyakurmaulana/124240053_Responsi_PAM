import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class DetailScreen extends StatefulWidget {
  final int productId;

  const DetailScreen({super.key, required this.productId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isWishlist = false;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProductDetail();
  }

  Future<void> _loadProductDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Mengambil detail produk dari API berdasarkan ID produk
      final detail = await ApiService.getProductDetail(widget.productId);
      final inWishlist = await DatabaseHelper.instance.isWishlist(widget.productId);

      if (!mounted) return;
      setState(() {
        _product = detail;
        _isWishlist = inWishlist;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // Sesuai ketentuan:
  // Ketika produk ditambahkan ke wishlist -> icon berubah warna & SnackBar HIJAU
  // Ketika produk dihapus dari wishlist -> icon kembali seperti semula & SnackBar MERAH
  Future<void> _toggleWishlist() async {
    if (_product == null) return;

    final added = await DatabaseHelper.instance.toggleWishlist(_product!);
    setState(() {
      _isWishlist = added;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${_product!.title} berhasil ditambahkan ke Wishlist!'
              : '${_product!.title} dihapus dari Wishlist.',
        ),
        // HIJAU saat ditambahkan, MERAH saat dihapus
        backgroundColor: added ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildInfoCard({
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          _product?.title ?? 'Detail Produk',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_product != null)
            IconButton(
              icon: Icon(
                _isWishlist ? Icons.favorite : Icons.favorite_border,
                color: _isWishlist ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                size: 26,
              ),
              tooltip: _isWishlist ? 'Hapus dari Wishlist' : 'Tambah ke Wishlist',
              onPressed: _toggleWishlist,
            ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF7C3AED)),
            SizedBox(height: 14),
            Text(
              'Mengambil data detail produk...',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null || _product == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Color(0xFFEF4444)),
              const SizedBox(height: 14),
              const Text(
                'Gagal Memuat Detail',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Produk tidak ditemukan',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProductDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final p = _product!;
    final List<String> displayImages = p.images.isNotEmpty
        ? p.images
        : (p.thumbnail.isNotEmpty ? [p.thumbnail] : []);

    final currentImageUrl = displayImages.isNotEmpty &&
            _selectedImageIndex < displayImages.length
        ? displayImages[_selectedImageIndex]
        : p.thumbnail;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk Utama
          Center(
            child: Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  currentImageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Thumbnails jika gambar > 1
          if (displayImages.length > 1) ...[
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: displayImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedImageIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedImageIndex = index),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          displayImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Nama Produk
          Text(
            p.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          // Kategori Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              p.category.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF7C3AED),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Harga & Diskon
          Row(
            children: [
              Text(
                '\$${p.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 12),
              if (p.discountPercentage > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Text(
                    'Diskon ${p.discountPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Detail Attributes
          _buildInfoCard(
            icon: Icons.store_outlined,
            label: 'Brand',
            value: p.brand.isNotEmpty ? p.brand : '-',
            iconColor: const Color(0xFF7C3AED),
          ),
          _buildInfoCard(
            icon: Icons.star_rate_rounded,
            label: 'Rating',
            value: '${p.rating.toStringAsFixed(1)} / 5.0',
            iconColor: const Color(0xFFF59E0B),
          ),
          _buildInfoCard(
            icon: Icons.inventory_2_outlined,
            label: 'Informasi Stok',
            value: '${p.stock} unit tersedia',
            iconColor: const Color(0xFF059669),
          ),
          _buildInfoCard(
            icon: Icons.percent_rounded,
            label: 'Persentase Diskon',
            value: '${p.discountPercentage.toStringAsFixed(2)}%',
            iconColor: const Color(0xFFEF4444),
          ),

          const SizedBox(height: 8),
          const Text(
            'Deskripsi Produk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              p.description.isNotEmpty ? p.description : 'Tidak ada deskripsi.',
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tombol Wishlist di Bagian Bawah
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggleWishlist,
              icon: Icon(
                _isWishlist ? Icons.favorite : Icons.favorite_border,
                color: _isWishlist ? const Color(0xFFDC2626) : Colors.white,
              ),
              label: Text(
                _isWishlist ? 'Hapus dari Wishlist' : 'Tambah ke Wishlist',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isWishlist ? Colors.white : const Color(0xFF7C3AED),
                foregroundColor:
                    _isWishlist ? const Color(0xFF0F172A) : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: _isWishlist
                    ? const BorderSide(color: Color(0xFFDC2626), width: 1.5)
                    : BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: _isWishlist ? 0 : 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
