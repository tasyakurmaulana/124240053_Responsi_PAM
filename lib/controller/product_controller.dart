import 'package:get/get.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductController extends GetxController {
  final RxList<Product> _products = <Product>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _selectedCategory = 'All'.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _errorMessage = ''.obs;

  List<Product> get products => _products;
  bool get isLoading => _isLoading.value;
  String get selectedCategory => _selectedCategory.value;
  String get errorMessage => _errorMessage.value;

  final List<String> categories = const [
    'All',
    'Beauty',
    'Fragrances',
    'Furniture',
    'Groceries',
  ];

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  Future<void> fetchProducts() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final data = await ApiService.getProducts(
        category: _selectedCategory.value == 'All'
            ? null
            : _selectedCategory.value.toLowerCase(),
        search: _searchQuery.value.trim().isNotEmpty
            ? _searchQuery.value.trim()
            : null,
      );

      _products.assignAll(data);
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading.value = false;
    }
  }

  void changeCategory(String category) {
    if (_selectedCategory.value == category) return;
    _selectedCategory.value = category;
    fetchProducts();
  }

  void searchProducts(String query) {
    _searchQuery.value = query;
    fetchProducts();
  }

  void resetFilter() {
    _selectedCategory.value = 'All';
    _searchQuery.value = '';
    fetchProducts();
  }
}
