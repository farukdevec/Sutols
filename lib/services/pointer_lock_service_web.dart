// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

import 'package:flutter/widgets.dart';

Stream<Offset> get pointerLockMovements => html.document.onMouseMove
    .where((_) => html.document.pointerLockElement != null)
    .map(
      (event) => Offset(
        event.movement.x.toDouble(),
        event.movement.y.toDouble(),
      ),
    );

Stream<bool> get pointerLockChanges => html.document.onPointerLockChange.map(
      (_) => html.document.pointerLockElement != null,
    );

bool get isPointerLocked => html.document.pointerLockElement != null;

void requestPointerLock() {
  if (isPointerLocked) return;
  html.document.body?.requestPointerLock();
}

void exitPointerLock() {
  if (!isPointerLocked) return;
  html.document.exitPointerLock();
}
