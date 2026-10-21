import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/company_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/common.dart';
import 'navigation.dart';

class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key, this.initialCompanyId});

  final int? initialCompanyId;

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  // Ikut column DECIMAL(10,2) kat backend, lebih dari ni rejected
  static const _maxPrice = 99999999.99;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  late int? _companyId = widget.initialCompanyId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _navigate(NavItem item) => navigateFromForm(context, NavItem.newService, item);

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Please enter the $label';
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter the price';
    final price = double.tryParse(value.trim());
    if (price == null) return 'Price must be a number, e.g. 150.50';
    if (price <= 0) return 'Price must be more than 0';
    if (price > _maxPrice) return 'Price is too large';
    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final provider = context.read<CompanyProvider>();
      final service = await provider.createService(
        companyId: _companyId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
      );
      if (!mounted) return;
      final companyName = provider.companies.firstWhere((c) => c.id == _companyId).name;
      showCuteSnackBar(context, '${service.name} was added to $companyName');
      Navigator.of(context).pop(service);
    } on ApiException catch (e) {
      if (!mounted) return;
      showCuteSnackBar(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompanyProvider>();
    final companies = provider.companies;

    if (companies.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              TopBar(current: NavItem.newService, onNavigate: _navigate),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: SphereLoader(label: 'Loading companies'))
                    : MessageView(
                        title: 'No companies yet',
                        message: 'A service has to belong to a company, so add a company first.',
                        actionLabel: 'Add company',
                        onAction: () => _navigate(NavItem.newCompany),
                      ),
              ),
            ],
          ),
        ),
      );
    }

    return FormPage(
      current: NavItem.newService,
      onNavigate: _navigate,
      eyebrow: 'New service',
      heading: 'add a\nservice',
      description: 'Choose the company that offers it, then describe the service '
          'and set its price in ringgit.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _companyId,
              isExpanded: true,
              borderRadius: BorderRadius.circular(24),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.pinkDeep),
              style: AppFonts.body(),
              decoration: const InputDecoration(labelText: 'Company'),
              items: [
                for (final c in companies)
                  DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: _isSubmitting ? null : (id) => setState(() => _companyId = id),
              validator: (id) => id == null ? 'Please choose a company' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Service name',
                hintText: 'e.g. Office cleaning',
              ),
              validator: (v) => _required(v, 'service name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              enabled: !_isSubmitting,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What does this service include?',
                alignLabelWithHint: true,
              ),
              validator: (v) => _required(v, 'description'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              enabled: !_isSubmitting,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Price',
                hintText: '150.00',
                prefixText: 'RM  ',
              ),
              validator: _validatePrice,
            ),
            const SizedBox(height: 32),
            PillButton(
              label: 'Save service',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
