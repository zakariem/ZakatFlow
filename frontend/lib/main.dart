import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/view/app.dart';

void main() {
  runApp(ProviderScope(child: App()));
}
