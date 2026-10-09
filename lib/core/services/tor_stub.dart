// Stub pour le package `tor` — permet de compiler sans Rust/Arti.
// En production, remplacer par le vrai package `tor`.
import 'dart:async';

class Tor {
  int? port;
  bool bootstrapped = false;

  static Future<Tor> init({required bool enabled}) async => Tor();
  Future<void> start() async {}
  Future<void> isReady() async {}
  Future<void> stop() async {}
  void disable() {}
}

class SOCKSSocket {
  static Future<SOCKSSocket> create({
    required String proxyHost,
    required int proxyPort,
  }) async => SOCKSSocket();

  final _controller = StreamController<List<int>>.broadcast();

  Future<void> connect() async {}
  Future<void> connectTo(String host, int port) async {}
  void write(dynamic data) {}

  StreamSubscription<List<int>> listen(
    void Function(List<int>) onData, {
    Function? onError,
    Function? onDone,
  }) {
    return _controller.stream.listen(
      onData,
      onError: onError != null ? (e) => onError(e) : null,
      onDone: onDone != null ? () => onDone() : null,
    );
  }

  dynamic get sink => _StubSink();

  Future<void> close() async {
    await _controller.close();
  }
}

class _StubSink {
  void add(dynamic data) {}
  Future<void> close() async {}
}
