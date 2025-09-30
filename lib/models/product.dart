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
}
