import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes.dart';
import '../services/plan_tier_service.dart';
import '../state/language_controller.dart';
import 'design/design_system.dart';

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
      _showMessage(
        tr('Lütfen bir kod girin.', 'Please enter a code.'),
        isError: true,
      );
      return;
    }
    if (_busy) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage(
        tr('Lütfen önce giriş yapın.', 'Please sign in first.'),
        isError: true,
      );
      return;
    }

    final db = FirebaseFirestore.instance;
    setState(() => _busy = true);
    try {
      await db.runTransaction((transaction) async {
        final codeSnap =
            await transaction.get(db.collection('promoCodes').doc(code));
        if (!codeSnap.exists) {
          throw _RedeemException(
            tr(
              'Geçersiz kod. Kontrol edip tekrar deneyin.',
              'Invalid code. Please check and try again.',
            ),
          );
        }
        final data = codeSnap.data()!;

        if (data['active'] != true) {
          throw _RedeemException(
            tr('Bu kod şu anda aktif değil.', 'This code is not active.'),
          );
        }

        final expiresAtValue = data['expiresAt'];
        final expiresAt = expiresAtValue is Timestamp
            ? expiresAtValue.toDate()
            : expiresAtValue is DateTime
                ? expiresAtValue
                : null;
        if (expiresAt != null && !expiresAt.isAfter(DateTime.now().toUtc())) {
          throw _RedeemException(
            tr('Bu kodun süresi dolmuş.', 'This code has expired.'),
          );
        }

        final maxUses = data['maxUses'] as int?;
        final usedCount = (data['usedCount'] as int?) ?? 0;
        if (maxUses != null && usedCount >= maxUses) {
          throw _RedeemException(
            tr(
              'Bu kodun kullanım limiti doldu.',
              'This code has reached its usage limit.',
            ),
          );
        }

        final targetUid = data['targetUid'] as String?;
        if (targetUid != null &&
            targetUid.isNotEmpty &&
            targetUid != user.uid) {
          throw _RedeemException(
            tr(
              'Bu kod başka bir kullanıcıya özeldir.',
              'This code is reserved for another user.',
            ),
          );
        }

        final grantsTier = data['grantsTier'] as String? ?? '';
        final userSnap =
            await transaction.get(db.collection('users').doc(user.uid));
        final currentTier = (userSnap.data()?['tier'] as String?) ?? 'free';
        if (!PlanTierService.isSupportedPromoGrant(grantsTier)) {
          throw _RedeemException(
            tr(
              'Bu kod güncel Plus planıyla uyumlu değil.',
              'This code is not compatible with the current Plus plan.',
            ),
          );
        }
        if (!PlanTierService.canRedeemPlus(
          grantsTier: grantsTier,
          currentTier: currentTier,
        )) {
          throw _RedeemException(
            tr('Zaten Plus planındasınız.', 'You are already on the Plus plan.'),
          );
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
      _showMessage(
        tr(
          'Kod başarıyla kullanıldı, planınız güncellendi!',
          'Code redeemed successfully, your plan has been updated!',
        ),
        isError: false,
      );
    } on _RedeemException catch (e) {
      _showMessage(e.message, isError: true);
    } catch (e) {
      _showMessage(
        '${tr('Kod kullanılamadı', 'Could not redeem code')}: $e',
        isError: true,
      );
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

    return Title(
      title: '${tr('Kod Kullan', 'Redeem Code')} – Sutols',
      color: colors.accent,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: Text(tr('Kod Kullan', 'Redeem Code')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: tr('Geri', 'Back'),
            onPressed: () => AppRoutes.handleAppBack(context),
          ),
        ),
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
                      tr('Promosyon Kodunuzu Girin', 'Enter Your Promo Code'),
                      textAlign: TextAlign.center,
                      style: AppTypography.titleLarge.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      tr(
                        'Kod doğrulanır ve planınız anında güncellenir.',
                        'Your code will be verified and plan updated instantly.',
                      ),
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
                      decoration: InputDecoration(
                        hintText: tr('KOD1234', 'CODE1234'),
                        prefixIcon: const Icon(Icons.redeem_outlined),
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
                      label: Text(
                        _busy
                            ? tr('Kullanılıyor...', 'Redeeming...')
                            : tr('Kodu Kullan', 'Redeem Code'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
