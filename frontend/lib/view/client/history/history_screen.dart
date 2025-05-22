import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/widgets/loader.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/zakat_providers.dart';
import '../../../viewmodels/history_viewmodel.dart';
import '../../../providers/auth_providers.dart';
import '../../../utils/widgets/snackbar/error_scanckbar.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final String? successMessage;

  const HistoryScreen({super.key, this.successMessage});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      resetZakatProviders(ref);
      _fetchHistory();
      _initialized = true;

      // Show success message after build
      if (widget.successMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      }
    }
  }

  Future<void> _fetchHistory() async {
    final token = ref.read(authViewModelProvider).user?.token;
    if (token != null) {
      await ref
          .read(historyViewModelProvider)
          .loadHistory(token, HistoryRole.user);
      final error = ref.read(historyViewModelProvider).error;
      if (error != null && mounted) {
        ErrorScanckbar.showSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyVm = ref.watch(historyViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: historyVm.isLoading ? null : _fetchHistory,
          ),
        ],
      ),
      body:
          historyVm.isLoading
              ? Loader()
              : historyVm.history.isEmpty
              ? const Center(child: Text('No payment history found.'))
              : ListView.builder(
                itemCount: historyVm.history.length,
                itemBuilder: (context, index) {
                  final payment = historyVm.history[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text('Paid to: ${payment.agentName}'),
                      subtitle: Text(
                        'Amount: ${payment.amount} ${payment.currency}\nDate: ${payment.paidAt.toLocal()}',
                      ),
                      trailing: Text(payment.paymentMethod),
                    ),
                  );
                },
              ),
    );
  }
}
