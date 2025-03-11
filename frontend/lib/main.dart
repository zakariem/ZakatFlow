import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/view/home.dart';

void main() {
  runApp(ProviderScope(child: Home()));
}
