import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Firebase'in ilk oturum sonucunu bekler ve korunan sayfayı yalnızca
/// doğrulanmış bir kullanıcı varken oluşturur.
class AuthenticatedRouteGuard extends StatefulWidget {
  const AuthenticatedRouteGuard({
    super.key,
    required this.builder,
    this.redirectRoute = '/',
    this.authStateStream,
  });

  final WidgetBuilder builder;
  final String redirectRoute;

  /// Testlerde Firebase kurulumuna ihtiyaç duymadan oturum durumunu sürmek
  /// için kullanılabilir. Üretimde Firebase Auth akışı kullanılır.
  final Stream<bool>? authStateStream;

  @override
  State<AuthenticatedRouteGuard> createState() =>
      _AuthenticatedRouteGuardState();
}

class _AuthenticatedRouteGuardState extends State<AuthenticatedRouteGuard> {
  late final Stream<bool> _authStateStream;
  bool _redirectScheduled = false;

  @override
  void initState() {
    super.initState();
    _authStateStream = widget.authStateStream ??
        FirebaseAuth.instance.authStateChanges().map((user) => user != null);
  }

  void _redirectToPublicHome() {
    if (_redirectScheduled) return;
    _redirectScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        widget.redirectRoute,
        (_) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _authStateStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != true) {
          _redirectToPublicHome();
          return const Scaffold(backgroundColor: Colors.white);
        }

        _redirectScheduled = false;
        return widget.builder(context);
      },
    );
  }
}
