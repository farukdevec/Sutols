import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'design/design_system.dart';

/// Kullanıcının promosyon kodu talebi oluşturduğu sayfa.
///
/// Kod doğrulaması istemcide yapılmaz: "Talep Et -> Admin Onayla" akışıyla
/// promoRequests koleksiyonuna "pending" kayıt atılır; tier güncellemesi
/// admin onayı sonrası uygulanır.
class RedeemCodePage extends StatefulWidget {
  const RedeemCodePage({super.key});

  @override
  State<RedeemCodePage> createState() => _RedeemCodePageState();
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

    setState(() => _busy = true);
    try {
      final pending = await FirebaseFirestore.instance
          .collection('promoRequests')
          .where('uid', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (pending.docs.isNotEmpty) {
        _showMessage('Bu kod için zaten bekleyen bir talebiniz var.',
            isError: true);
        return;
      }

      await FirebaseFirestore.instance.collection('promoRequests').add({
        'uid': user.uid,
        'email': user.email ?? '',
        'code': code,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _codeController.clear();
      _showMessage(
        'Talebiniz alındı, onaylandıktan sonra hesabınıza tanımlanacaktır.',
        isError: false,
      );
    } catch (e) {
      _showMessage('Talep oluşturulamadı: $e', isError: true);
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

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Kod Kullan')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s32),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s32),
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
                      'Kodunuz onay için gönderilir; onaylandıktan sonra planınız güncellenir.',
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
                          : const Icon(Icons.send_rounded),
                      label: Text(_busy ? 'Gönderiliyor...' : 'Kod Gönder'),
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