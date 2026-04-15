class Book {
  final String id;
  final String title;
  final int quantity;
  final int availableQuantity;

  const Book({
    required this.id,
    required this.title,
    required this.quantity,
    required this.availableQuantity,
  });

  factory Book.fromMap(String id, Map<String, dynamic> data) {
    final quantity = (data['quantity'] ?? 0) as int;
    final available = (data['availableQuantity'] ?? data['available'] ?? quantity) as int;
    return Book(
      id: id,
      title: (data['title'] ?? '') as String,
      quantity: quantity,
      availableQuantity: available,
    );
  }
}

