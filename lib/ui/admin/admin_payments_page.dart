import 'package:flutter/material.dart';

import '../design/design_system.dart';

class AdminPaymentsPage extends StatelessWidget {
  const AdminPaymentsPage({super.key});

  static const List<_PaymentRow> _payments = [];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Payments'),
      ),
      body: _payments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 56,
                    color: colors.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    'Henüz ödeme bulunamadı',
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s32),
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll(
                  colors.surfaceElevated,
                ),
                dataRowColor: WidgetStatePropertyAll(colors.surface),
                columns: const [
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Package')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Currency')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('CreatedAt')),
                  DataColumn(label: Text('Refund')),
                ],
                rows: _payments.map((p) {
                  return DataRow(
                    cells: [
                      DataCell(Text(p.user)),
                      DataCell(Text(p.package)),
                      DataCell(Text(p.amount)),
                      DataCell(Text(p.currency)),
                      DataCell(Text(p.status)),
                      DataCell(Text(p.createdAt)),
                      DataCell(Text(p.refund)),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}

class _PaymentRow {
  const _PaymentRow({
    required this.user,
    required this.package,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.refund,
  });

  final String user;
  final String package;
  final String amount;
  final String currency;
  final String status;
  final String createdAt;
  final String refund;
}
