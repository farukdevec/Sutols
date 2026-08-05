import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_rest_helper.dart';
import '../design/design_system.dart';

/// Bekleyen promosyon kodu taleplerinin listelendiği ve onaylandığı/reddedildiği
/// admin sayfası. Tier güncellemesi + durum değişikliği tek transaction'da
/// atomik olarak yapılır.
class AdminPromoRequestsPage extends StatefulWidget {
  const AdminPromoRequestsPage({super.key});

  @override
  State<AdminPromoRequestsPage> createState() => _AdminPromoRequestsPageState();
}

class _PromoRequestItem {
  const _PromoRequestItem({
    required this.id,
    required this.uid,
    required this.email,
    required this.code,
    this.createdAt,
  });

  final String id;
  final String uid;
  final String email;
  final String code;
  final DateTime? createdAt;
}

class _AdminPromoRequestsPageState extends State<AdminPromoRequestsPage> {
  bool _loading = true;
  bool _busy = false;
  String? _error;
  List<_PromoRequestItem> _requests = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('promoRequests')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      final requests = snapshot.docs.map((doc) {
        final data = doc.data();
        return _PromoRequestItem(
          id: doc.id,
          uid: data['uid'] as String? ?? '',
          email: data['email'] as String? ?? '',
          code: data['code'] as String? ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _requests = requests;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Talepler yüklenemedi: $e';
        _loading = false;
      });
    }
  }

  Future<void> _approve(_PromoRequestItem request) async {
    if (_busy) return;
    setState(() => _busy = true);

    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) {
      _showMessage('Oturum bulunamadı.', isError: true);
      setState(() => _busy = false);
      return;
    }

    try {
      var grantsTier = '';
      try {
        final promo =
            await FirestoreRestHelper.getDocument('promoCodes/${request.code}');
        final fields = promo?['fields'] as Map<String, dynamic>? ?? {};
        grantsTier = FirestoreRestHelper.stringField(fields, 'grantsTier');
      } catch (_) {
        grantsTier = '';
      }

      if (grantsTier != 'plus' && grantsTier != 'premium') {
        if (!mounted) return;
        final picked = await _pickTier();
        if (picked == null) {
          setState(() => _busy = false);
          return;
        }
        grantsTier = picked;
      }

      var userTier = '';
      try {
        final userDoc =
            await FirestoreRestHelper.getDocument('users/${request.uid}');
        final fields = userDoc?['fields'] as Map<String, dynamic>? ?? {};
        userTier = FirestoreRestHelper.stringField(fields, 'tier');
      } catch (_) {
        userTier = '';
      }

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(request.uid);
      final requestRef = FirebaseFirestore.instance
          .collection('promoRequests')
          .doc(request.id);

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snapshot = await tx.get(requestRef);
        if (!snapshot.exists) {
          throw Exception('Talep bulunamadı.');
        }

        final currentTier = userTier.isEmpty ? 'free' : userTier;
        if (_tierRank(grantsTier) > _tierRank(currentTier)) {
          tx.update(userRef, {'tier': grantsTier});
        }

        tx.update(requestRef, {
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
          'approvedBy': adminUid,
        });
      });

      if (!mounted) return;
      _showMessage('Talep onaylandı, tier güncellendi.', isError: false);
      await _load();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Onaylama başarısız: $e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject(_PromoRequestItem request) async {
    if (_busy) return;
    setState(() => _busy = true);

    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) {
      _showMessage('Oturum bulunamadı.', isError: true);
      setState(() => _busy = false);
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('promoRequests')
          .doc(request.id)
          .update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': adminUid,
      });

      if (!mounted) return;
      _showMessage('Talep reddedildi.', isError: false);
      await _load();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Reddetme başarısız: $e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _pickTier() {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Tier seçin'),
        children: [
          for (final tier in const ['premium', 'plus'])
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(tier),
              child: Text(tier == 'premium' ? 'Premium' : 'Plus'),
            ),
        ],
      ),
    );
  }

  int _tierRank(String tier) {
    return switch (tier) {
      'premium' => 2,
      'plus' => 1,
      _ => 0,
    };
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
      appBar: AppBar(
        title: const Text('Promosyon Talepleri'),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _busy ? null : _load,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.colors;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      );
    }

    if (_requests.isEmpty) {
      return Center(
        child: Text(
          'Bekleyen talep yok.',
          style: AppTypography.bodyLarge.copyWith(
            color: colors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s32),
      itemCount: _requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
      itemBuilder: (context, index) {
        final request = _requests[index];
        return _RequestTile(
          request: request,
          busy: _busy,
          onApprove: () => _approve(request),
          onReject: () => _reject(request),
        );
      },
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.request,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  final _PromoRequestItem request;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.email.isNotEmpty ? request.email : request.uid,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      Chip(
                        label: Text('Kod: ${request.code}'),
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        label: Text(_formatDate(request.createdAt)),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            FilledButton.tonalIcon(
              onPressed: busy ? null : onApprove,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Onayla'),
              style: FilledButton.styleFrom(
                backgroundColor: colors.success,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            OutlinedButton.icon(
              onPressed: busy ? null : onReject,
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Reddet'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day.$month.${local.year} $hour:$minute';
  }
}