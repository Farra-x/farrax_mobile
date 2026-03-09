import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/scanner_service.dart';

part 'scanner_provider.g.dart';

// ─── Singleton ScannerService ─────────────────────────────────────────────────

@Riverpod(keepAlive: true)
ScannerService scannerService(ScannerServiceRef ref) {
  final ScannerService svc = ScannerService();
  ref.onDispose(svc.dispose);
  return svc;
}

// ─── BLE Tag Stream ───────────────────────────────────────────────────────────
// keepAlive so it never misses a tag notification, even off the home screen.

@Riverpod(keepAlive: true)
Stream<String> bleTagStream(BleTagStreamRef ref) {
  return ref.watch(scannerServiceProvider).tagStream;
}

// ─── Connected Device Stream ──────────────────────────────────────────────────
// keepAlive so it stays subscribed even when HomeShell is not in the tree
// (e.g. while the user is on the BLE connect screen).

@Riverpod(keepAlive: true)
Stream<BluetoothDevice?> connectedDevice(ConnectedDeviceRef ref) {
  return ref.watch(scannerServiceProvider).connectionStream;
}

// ─── BLE Connection State ─────────────────────────────────────────────────────

@riverpod
Stream<BluetoothConnectionState> bleConnectionState(BleConnectionStateRef ref) {
  final BluetoothDevice? device =
      ref.watch(connectedDeviceProvider).valueOrNull;
  if (device == null) {
    return Stream.value(BluetoothConnectionState.disconnected);
  }
  return device.connectionState;
}

// ─── Connected Device Name ────────────────────────────────────────────────────

@riverpod
String? connectedDeviceName(ConnectedDeviceNameRef ref) {
  final BluetoothDevice? device =
      ref.watch(connectedDeviceProvider).valueOrNull;
  if (device == null) return null;
  final String name = device.platformName;
  return name.isNotEmpty ? name : device.remoteId.str;
}

// ─── Batch Scan List ──────────────────────────────────────────────────────────

@riverpod
class BatchScanList extends _$BatchScanList {
  @override
  List<String> build() => [];

  void add(String tag) {
    if (!state.contains(tag)) {
      state = [...state, tag];
    }
  }

  void remove(String tag) {
    state = state.where((t) => t != tag).toList();
  }

  void clear() => state = [];
}

// ─── Batch Mode Toggle ────────────────────────────────────────────────────────

@riverpod
class IsBatchMode extends _$IsBatchMode {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}
