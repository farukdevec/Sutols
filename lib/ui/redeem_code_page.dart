import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'design/design_system.dart';
import '../services/plan_tier_service.dart';

/// Kullanıcının promosyon kodunu anında kullandığı sayfa.
///
/// Kod `promoCodes` dokümanından okunur, geçerliliği doğrulanır ve tier
/// güncellemesi + `usedCount` artışı tek transaction'da atomik yapılır.
/// Kurallar (firestore.rules) bu işlemi bağımsız olarak da doğrular
/// (`isRedeemableCode`); istemci yalnızca deneyim katmanıdır.
class RedeemCodePage extends StatefulWidget {
  const RedeemCodePage({super.key});

  @override
  State<RedeemCodePage> createState() => _RedeemCodePageState();
}

class _RedeemException implements Exception {
  const _RedeemException(this.message);

  final String message;
}

class _RedeemCodePageState extends State<RedeemCodePage> {
  final TextEditingController _codeController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      _showMessage('Lütfen bir kod girin.', isError: true);
      return;
    }
    if (_busy) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('Lütfen önce giriş yapın.', isError: true);
      return;
    }

    final db = FirebaseFirestore.instance;
    setState(() => _busy = true);
    try {
      await db.runTransaction((transaction) async {
        final codeSnap =
            await transaction.get(db.collection('promoCodes').doc(code));
        if (!codeSnap.exists) {
          throw const _RedeemException(
              'Geçersiz kod. Kontrol edip tekrar deneyin.');
        }
        final data = codeSnap.data()!;

        if (data['active'] != true) {
          throw const _RedeemException('Bu kod şu anda aktif değil.');
        }

        final expiresAtValue = data['expiresAt'];
        final expiresAt = expiresAtValue is Timestamp
            ? expiresAtValue.toDate()
            : expiresAtValue is DateTime
                ? expiresAtValue
                : null;
        if (expiresAt != null && !expiresAt.isAfter(DateTime.now().toUtc())) {
          throw const _RedeemException('Bu kodun süresi dolmuş.');
        }

        final maxUses = data['maxUses'] as int?;
        final usedCount = (data['usedCount'] as int?) ?? 0;
        if (maxUses != null && usedCount >= maxUses) {
          throw const _RedeemException('Bu kodun kullanım limiti doldu.');
        }

        final targetUid = data['targetUid'] as String?;
        if (targetUid != null &&
            targetUid.isNotEmpty &&
            targetUid != user.uid) {
          throw const _RedeemException('Bu kod başka bir kullanıcıya özeldir.');
        }

        final grantsTier = data['grantsTier'] as String? ?? '';
        final userSnap =
            await transaction.get(db.collection('users').doc(user.uid));
        final currentTier = (userSnap.data()?['tier'] as String?) ?? 'free';
        if (!PlanTierService.isSupportedPromoGrant(grantsTier)) {
          throw const _RedeemException(
            'Bu kod güncel Plus planıyla uyumlu değil.',
          );
        }
        if (!PlanTierService.canRedeemPlus(
          grantsTier: grantsTier,
          currentTier: currentTier,
        )) {
          throw const _RedeemException('Zaten Plus planındasınız.');
        }

        transaction.set(
          db.collection('users').doc(user.uid),
          {
            'tier': PlanTierService.plus,
            'redeemedCode': code,
            'redeemedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        transaction.update(db.collection('promoCodes').doc(code), {
          'usedCount': FieldValue.increment(1),
        });
      });

      if (!mounted) return;
      _codeController.clear();
      _showMessage('Kod başarıyla kullanıldı, planınız güncellendi!',
          isError: false);
    } on _RedeemException catch (e) {
      _showMessage(e.message, isError: true);
    } catch (e) {
      _showMessage('Kod kullanılamadı: $e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;
    final colors = context.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.danger : colors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final narrow = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Kod Kullan')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: EdgeInsets.all(narrow ? AppSpacing.s16 : AppSpacing.s32),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(
                  narrow ? AppSpacing.s24 : AppSpacing.s32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Promosyon Kodunuzu Girin',
                      textAlign: TextAlign.center,
                      style: AppTypography.titleLarge.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      'Kod doğrulanır ve planınız anında güncellenir.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    TextField(
                      controller: _codeController,
                      enabled: !_busy,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: 'KOD1234',
                        prefixIcon: Icon(Icons.redeem_outlined),
                      ),
                      onSubmitted: (_) => _redeem(),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    FilledButton.icon(
                      onPressed: _busy ? null : _redeem,
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(_busy ? 'Kullanılıyor...' : 'Kodu Kullan'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
