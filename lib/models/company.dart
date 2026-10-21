import 'service.dart';

class Company {
  final int id;
  final String name;
  final String registrationNumber;
  final List<Service> services;

  Company({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.services,
  });

  Company copyWith({List<Service>? services}) {
    return Company(
      id: id,
      name: name,
      registrationNumber: registrationNumber,
      services: services ?? this.services,
    );
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int,
      name: json['name'] as String,
      registrationNumber: json['registrationNumber'] as String,
      services: (json['services'] as List? ?? [])
          .map((s) => Service.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
