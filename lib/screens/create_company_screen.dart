import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/company_provider.dart';
import '../services/api_service.dart';
import '../widgets/common.dart';
import 'navigation.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _registrationController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Please enter the $label';
    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final company = await context.read<CompanyProvider>().createCompany(
            name: _nameController.text.trim(),
            registrationNumber: _registrationController.text.trim(),
          );
      if (!mounted) return;
      showCuteSnackBar(context, '${company.name} was added');
      Navigator.of(context).pop(company);
    } on ApiException catch (e) {
      if (!mounted) return;
      showCuteSnackBar(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      current: NavItem.newCompany,
      onNavigate: (item) => navigateFromForm(context, NavItem.newCompany, item),
      eyebrow: 'New company',
      heading: 'add a\ncompany',
      description: 'Every company needs a name and its own registration number. '
          'No two companies can share the same number.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Company name',
                hintText: 'e.g. Juara Inovasi Sdn Bhd',
              ),
              validator: (v) => _required(v, 'company name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registrationController,
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Registration number',
                hintText: 'e.g. 202401000123',
              ),
              validator: (v) => _required(v, 'registration number'),
            ),
            const SizedBox(height: 32),
            PillButton(
              label: 'Save company',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
