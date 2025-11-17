import 'package:equatable/equatable.dart';

class Rating extends Equatable {
  final double rate;
  final int count;

  const Rating({
    required this.rate,
    required this.count,
  });

  @override
  List<Object?> get props => [rate, count];
}

class Product extends Equatable {
  final String id;
  final String title;
  final String name;
  final String image;
  final String imageUrl;
  final double price;
  final String description;
  final String category;
  final Rating? rating;

  const Product({
    required this.id,
    required this.title,
    required this.name,
    required this.image,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.category,
    this.rating,
  });

  @override
  List<Object?> get props => [id, title, name, image, imageUrl, price, description, category, rating];

  /// Convert Product to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'name': name,
      'image': image,
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
      'category': category,
      'rating': rating != null ? {
        'rate': rating!.rate,
        'count': rating!.count,
      } : null,
    };
  }

  /// Create Product from Map (Firestore data)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      rating: map['rating'] != null ? Rating(
        rate: (map['rating']['rate'] ?? 0).toDouble(),
        count: map['rating']['count'] ?? 0,
      ) : null,
    );
  }
}
