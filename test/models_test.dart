import 'package:flutter_test/flutter_test.dart';
import 'package:front_end_test_vista/models/company.dart';

void main() {
  test('Company.fromJson parses nested services', () {
    final company = Company.fromJson({
      'id': 3,
      'name': 'Juara Inovasi Sdn Bhd',
      'registrationNumber': '2040000120',
      'services': [
        {
          'id': 1,
          'companyId': 3,
          'name': 'Cleaning',
          'description': 'Office cleaning',
          'price': 150,
        },
        {
          'id': 2,
          'companyId': 3,
          'name': 'Gardening',
          'description': 'Weekly garden care',
          'price': 99.5,
        },
      ],
    });

    expect(company.name, 'Juara Inovasi Sdn Bhd');
    expect(company.services, hasLength(2));
    expect(company.services.first.price, 150.0);
    expect(company.services.last.price, 99.5);
  });

  test('Company.fromJson treats missing services as empty', () {
    final company = Company.fromJson({
      'id': 1,
      'name': 'Acme',
      'registrationNumber': 'X1',
    });

    expect(company.services, isEmpty);
  });
}
