import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../services/database_helper.dart';

class WishlistController extends GetxController {
  final RxList<Product> _wishlist = <Product>[].obs;
  final RxBool _isLoading = false.obs;

  List<Product> get wishlist => _wishlist;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    loadWishlist();
    super.onInit();
  }

  Future<void> loadWishlist() async {
    _isLoading.value = true;
    final items = await DatabaseHelper.instance.getWishlist();
    _wishlist.assignAll(items);
    _isLoading.value = false;
  }

  bool isWishlist(int productId) {
    return _wishlist.any((p) => p.id == productId);
  }

  Future<void> toggleWishlist(Product product, BuildContext context) async {
    final alreadyInWishlist = isWishlist(product.id);

    if (alreadyInWishlist) {
      await DatabaseHelper.instance.removeFromWishlist(product.id);
      _wishlist.removeWhere((p) => p.id == product.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.title} dihapus dari Wishlist.'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      await DatabaseHelper.instance.addToWishlist(product);
      _wishlist.insert(0, product);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.title} berhasil ditambahkan ke Wishlist!'),
            backgroundColor: const Color(0xFF16A34A),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> removeFromWishlist(Product product, BuildContext context) async {
    await DatabaseHelper.instance.removeFromWishlist(product.id);
    _wishlist.removeWhere((p) => p.id == product.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.title} dihapus dari Wishlist.'),
          backgroundColor: const Color(0xFFDC2626),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
