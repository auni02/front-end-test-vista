import 'package:flutter/foundation.dart';

import '../models/company.dart';
import '../models/service.dart';
import '../services/api_service.dart';

// screen share list . Screen panggil method, tak boleh call API terus 
class CompanyProvider extends ChangeNotifier {
  CompanyProvider(this._api);

  final ApiService _api;

  List<Company> _companies = [];
  bool _isLoading = false;
  String? _error;

  List<Company> get companies => List.unmodifiable(_companies);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCompanies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _companies = await _api.getCompanies();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Company> createCompany({
    required String name,
    required String registrationNumber,
  }) async {
    final company = await _api.createCompany(
      name: name,
      registrationNumber: registrationNumber,
    );
    _companies = [company, ..._companies]; // paling baru dulu, sama macam API
    notifyListeners();
    return company;
  }

  Future<Service> createService({
    required int companyId,
    required String name,
    required String description,
    required double price,
  }) async {
    final service = await _api.createService(
      companyId: companyId,
      name: name,
      description: description,
      price: price,
    );
    _companies = [
      for (final c in _companies)
        c.id == companyId ? c.copyWith(services: [...c.services, service]) : c,
    ];
    notifyListeners();
    return service;
  }
}
