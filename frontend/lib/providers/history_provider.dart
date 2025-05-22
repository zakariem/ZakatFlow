import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/constant/api_constants.dart';
import '../services/history_service.dart';
import '../viewmodels/history_viewmodel.dart';

final historyServiceProvider = Provider<HistoryService>((ref) {
  // Replace with your actual base URL
  const baseUrl = ApiConstants.baseUrl;
  return HistoryService(baseUrl: baseUrl);
});

final historyViewModelProvider = ChangeNotifierProvider<HistoryViewModel>((
  ref,
) {
  final service = ref.read(historyServiceProvider);
  return HistoryViewModel(service: service);
});
