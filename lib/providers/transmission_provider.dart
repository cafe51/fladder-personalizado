import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fladder/services/transmission_service.dart';
import 'package:fladder/providers/user_provider.dart';
import 'package:fladder/util/fladder_config.dart';

final transmissionProvider = StateNotifierProvider<TransmissionNotifier, List<dynamic>>((ref) {
  final creds = ref.watch(userProvider.select((u) => u?.seerrCredentials));
  final serverUrl = (FladderConfig.seerrBaseUrl ?? creds?.serverUrl)?.trim();
  final service = TransmissionService(serverUrl);
  return TransmissionNotifier(service);
});

class TransmissionNotifier extends StateNotifier<List<dynamic>> {
  final TransmissionService service;
  Timer? _timer;

  TransmissionNotifier(this.service) : super([]) {
    _startPolling();
  }

  void _startPolling() {
    _fetch();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetch();
    });
  }

  Future<void> _fetch() async {
    final data = await service.fetchTransmissionStats();
    if (data != null && data['transmission'] != null) {
      final torrents = data['transmission']['torrents'] as List<dynamic>?;
      if (torrents != null) {
        state = torrents;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
