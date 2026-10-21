import 'package:flutter/material.dart';

import '../widgets/animations.dart';
import '../widgets/common.dart';
import 'create_company_screen.dart';
import 'create_service_screen.dart';

// Form ganti form (replace), so tekan back confirm balik ke list, bukan stuck dalam form lain
void navigateFromForm(BuildContext context, NavItem current, NavItem target) {
  if (target == current) return;

  final navigator = Navigator.of(context);
  switch (target) {
    case NavItem.companies:
      navigator.popUntil((route) => route.isFirst);
    case NavItem.newCompany:
      navigator.pushReplacement(softRoute(const CreateCompanyScreen()));
    case NavItem.newService:
      navigator.pushReplacement(softRoute(const CreateServiceScreen()));
  }
}
