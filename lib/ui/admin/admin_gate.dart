import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_rest_helper.dart';
import '../design/design_system.dart';
import 'admin_access_denied_page.dart';
import 'admin_page.dart';

/// /admin route'unu korur: admins/{uid} dokümanı varsa [AdminPage],
/// değilse [AdminAccessDeniedPage] gösterir.
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

    try {
      final doc = await FirestoreRestHelper.getDocument('admins/$uid');
      return doc != null;
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
