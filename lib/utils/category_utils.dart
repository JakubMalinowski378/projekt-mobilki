import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

String getLocalizedCategoryName(BuildContext context, String dbName) {
  final l10n = AppLocalizations.of(context)!;
  switch (dbName) {
    case 'Salary': return l10n.catSalary;
    case 'Business': return l10n.catBusiness;
    case 'Investments': return l10n.catInvestments;
    case 'Food & Dining': return l10n.catFoodDining;
    case 'Transportation': return l10n.catTransportation;
    case 'Shopping': return l10n.catShopping;
    case 'Entertainment': return l10n.catEntertainment;
    case 'Bills & Utilities': return l10n.catBillsUtilities;
    case 'Healthcare': return l10n.catHealthcare;
    default: return dbName;
  }
}
