class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String thumbnail;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.thumbnail,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List)
          .map((item) => item.toString())
          .toList();
    } else if (json['images'] is String && json['images'].isNotEmpty) {
      parsedImages = [json['images'].toString()];
    }

    final thumb = json['thumbnail']?.toString() ??
        (parsedImages.isNotEmpty ? parsedImages.first : '');

    return Product(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: json['brand']?.toString() ?? '',
      thumbnail: thumb,
      images: parsedImages.isNotEmpty ? parsedImages : (thumb.isNotEmpty ? [thumb] : []),
    );
  }

  Map<String, dynamic> toMap() {
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
      'thumbnail': thumbnail,
      'images': images.join(','),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    final imagesStr = map['images']?.toString() ?? '';
    final List<String> parsedImages = imagesStr.isNotEmpty
        ? imagesStr.split(',').where((s) => s.isNotEmpty).toList()
        : [];
    final thumb = map['thumbnail']?.toString() ??
        (parsedImages.isNotEmpty ? parsedImages.first : '');

    return Product(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (map['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      brand: map['brand']?.toString() ?? '',
      thumbnail: thumb,
      images: parsedImages.isNotEmpty ? parsedImages : (thumb.isNotEmpty ? [thumb] : []),
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
