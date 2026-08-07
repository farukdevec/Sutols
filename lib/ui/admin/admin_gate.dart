import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_rest_helper.dart';
import '../design/design_system.dart';
import 'admin_access_denied_page.dart';
import 'admin_page.dart';

/// /admin route'unu korur. Yetki iki yoldan biriyle doğrulanır:
/// 1) admins/{uid} dokümanı mevcutsa (güncel yöntem),
/// 2) users/{uid}.role == 'admin' ise (eski yöntem).
/// İkisi de geçerli değilse [AdminAccessDeniedPage] gösterilir.
class AdminGate extends StatefulWidget {
  const AdminGate({super.key});

  @override
  State<AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<AdminGate> {
  late final Future<bool> _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = _checkAdmin();
  }

  Future<bool> _checkAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    // 1) Güncel yol: admins/{uid} dokümanı (rules: yalnız admin okuyabilir).
    try {
      final adminDoc = await FirestoreRestHelper.getDocument('admins/$uid');
      if (adminDoc != null) return true;
    } catch (_) {
      // Eski canlı kurallar admins okumasını reddedebilir; role yoluna düş.
    }

    // 2) Eski yol: users/{uid}.role == 'admin'.
    try {
      final userDoc = await FirestoreRestHelper.getDocument('users/$uid');
      final fields = userDoc?['fields'] as Map<String, dynamic>? ?? {};
      return FirestoreRestHelper.stringField(fields, 'role') == 'admin';
    } catch (_) {
      // Best-effort: hata durumunda erişim kapalı kalsın.
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FutureBuilder<bool>(
      future: _isAdmin,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: colors.surface,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const AdminPage();
        }

        return const AdminAccessDeniedPage();
      },
    );
  }
}
