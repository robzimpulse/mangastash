import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef Channels =
    Map<MethodChannel, Future<Object?>? Function(MethodCall message)?>;

class FakeMethodChannel {
  Channels _channels;
  final ValueSetter<Channels> _onChannelsChanged;
  final Future<void> Function(MethodChannel, MethodCall) _onChannelTriggered;

  FakeMethodChannel({
    required this._onChannelsChanged,
    required this._onChannelTriggered,
  }) : _channels = const {};

  void addChannel({
    required MethodChannel channel,
    required Future<Object?> Function(MethodCall message)? handler,
  }) {
    _channels = {..._channels, channel: handler};
    _onChannelsChanged(_channels);
  }

  Future<void> triggerChannel({
    required MethodChannel channel,
    required MethodCall method,
  }) async {
    await _onChannelTriggered.call(channel, method);
  }
}
