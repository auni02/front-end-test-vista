import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/company_provider.dart';
import 'screens/company_list_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CompanyProvider(ApiService())..fetchCompanies(),
      child: const VistaApp(),
    ),
  );
}

class VistaApp extends StatelessWidget {
  const VistaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vista',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const CompanyListScreen(),
    );
  }
}
