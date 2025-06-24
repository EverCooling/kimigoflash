// lib/http/http_response_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final httpResponseProvider = StateNotifierProvider<HttpResponseNotifier, AsyncValue<dynamic>>(
      (ref) => HttpResponseNotifier(),
);

class HttpResponseNotifier extends StateNotifier<AsyncValue<dynamic>> {
  HttpResponseNotifier() : super(const AsyncValue.data(null));

  void setLoading() {
    state = const AsyncValue.loading();
  }

  void setData(dynamic data) {
    state = AsyncValue.data(data);
  }

  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }
}
