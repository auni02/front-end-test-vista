class Service {
  final int id;
  final int companyId;
  final String name;
  final String description;
  final double price;

  Service({
    required this.id,
    required this.companyId,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      companyId: json['companyId'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      // JSON boleh bagi 150 (int) or 150.5 (double), so guna num je, dua-dua lepas fr
      price: (json['price'] as num).toDouble(),
    );
  }
}
