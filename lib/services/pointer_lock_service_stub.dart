import 'package:flutter/widgets.dart';

Stream<Offset> get pointerLockMovements => const Stream<Offset>.empty();

Stream<bool> get pointerLockChanges => const Stream<bool>.empty();

bool get isPointerLocked => false;

void requestPointerLock() {}

void exitPointerLock() {}
