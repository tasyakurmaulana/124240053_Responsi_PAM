import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/api_service.dart';
import '../services/preference_service.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<Character> _characters = [];
  bool _isLoading = true;
  String? _errorMessage;
  // ==========================================================================
  // 📌 TIPS RESPONSI: FILTER & PENCARIAN API
  // ==========================================================================
  // Jika API baru memiliki kategori atau filter yang berbeda, ganti list di bawah ini:
  // Contoh: final List<String> _statusFilters = ['All', 'Electronics', 'Jewelery', "Men's Clothing"];
  // ==========================================================================
  String _selectedStatus = 'All';
  final List<String> _statusFilters = [
    'All',
    'Beauty',
    'Fragrances',
    'Furniture',
    'Groceries',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCharacters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Fungsi pemanggilan API ke ApiService
  // --------------------------------------------------------------------------
  Future<void> _fetchCharacters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 👉 Panggil fungsi ApiService yang sesuai dengan parameter filter/search API baru
      final results = await ApiService.getCharacters(
        category: _selectedStatus == 'All' ? null : _selectedStatus,
        title: _searchController.text.trim().isNotEmpty
            ? _searchController.text.trim()
            : null,
      );

      if (!mounted) return;
      setState(() {
        _characters = results;
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return const Color(0xFF10B981); // Hijau segar
      case 'dead':
        return const Color(0xFFEF4444); // Merah
      default:
        return const Color(0xFFF59E0B); // Amber / Kuning
    }
  }

  Future<void> _toggleFavorite(Character character) async {
    final added = await PreferenceService.instance.toggleFavorite(character);
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${character.title} ditambahkan ke favorit!'
              : '${character.title} dihapus dari favorit.',
        ),
        backgroundColor: added
            ? const Color(0xFF7C3AED)
            : const Color(0xFFEF4444),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search & Filter Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input (Bonus)
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Color(0xFF0F172A)),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _fetchCharacters(),
                decoration: InputDecoration(
                  hintText: 'Cari Title (contoh: Mascara, Eyeshadow)...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF7C3AED),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF94A3B8),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _fetchCharacters();
                          },
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF7C3AED),
                          ),
                          onPressed: _fetchCharacters,
                        ),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF7C3AED),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Filter Status Chips (All, Alive, Dead, Unknown)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statusFilters.map((status) {
                    final isSelected =
                        _selectedStatus.toLowerCase() == status.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        selected: isSelected,
                        label: Text(status),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF7C3AED), // Ungu
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFFE2E8F0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedStatus = status);
                            _fetchCharacters();
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

        // Body Content
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF7C3AED)),
            SizedBox(height: 14),
            Text(
              'Memuat data product...',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 60,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 14),
              const Text(
                'Gagal Mengambil Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchCharacters,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_characters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 60,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            const Text(
              'Produk tidak ditemukan',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coba kata kunci atau filter status yang lain.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _selectedStatus = 'All');
                _fetchCharacters();
              },
              child: const Text(
                'Reset Pencarian',
                style: TextStyle(
                  color: Color(0xFF7C3AED),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ValueListenableBuilder<List<Character>>(
      valueListenable: PreferenceService.instance.favoriteCharactersNotifier,
      builder: (context, favorites, _) {
        final favoriteIds = favorites.map((f) => f.id).toSet();

        return RefreshIndicator(
          color: const Color(0xFF7C3AED),
          onRefresh: _fetchCharacters,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _characters.length,
            itemBuilder: (context, index) {
              final character = _characters[index];
              final isFav = favoriteIds.contains(character.id);
              final statusColor = _getStatusColor(character.category);

              return Card(
                color: Colors.white,
                elevation: 1.5,
                shadowColor: Colors.black.withOpacity(0.08),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isFav
                        ? const Color(0xFFF59E0B).withOpacity(0.5)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailScreen(character: character),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Foto Karakter
                        Hero(
                          tag: 'char-${character.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              character.images,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 64,
                                    height: 64,
                                    color: const Color(0xFFF1F5F9),
                                    child: const Icon(
                                      Icons.person,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Info Karakter
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                character.title,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 3.5,
                                          backgroundColor: statusColor,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          character.category,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      character.brand,
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Tombol Favorit
                        IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF94A3B8),
                            size: 26,
                          ),
                          tooltip: isFav ? 'Hapus favorit' : 'Tambah favorit',
                          onPressed: () => _toggleFavorite(character),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
