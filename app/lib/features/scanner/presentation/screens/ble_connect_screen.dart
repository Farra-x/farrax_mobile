import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/scanner_service.dart';
import '../providers/scanner_provider.dart';

class BleConnectScreen extends ConsumerStatefulWidget {
  const BleConnectScreen({super.key});

  @override
  ConsumerState<BleConnectScreen> createState() => _BleConnectScreenState();
}

class _BleConnectScreenState extends ConsumerState<BleConnectScreen> {
  final Map<String, BluetoothDevice> _discovered = {};
  StreamSubscription<List<ScanResult>>? _scanSub;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() { _scanning = true; _discovered.clear(); });

    _scanSub = FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
      for (final ScanResult r in results) {
        final ScannerService svc = ref.read(scannerServiceProvider);
        final bool known = svc.isKnownDevice(r.device);
        final bool hasNuart = r.advertisementData.serviceUuids
            .any((guid) => guid.str128.toLowerCase().contains('6e400001'));

        if (known || hasNuart) {
          setState(() => _discovered[r.device.remoteId.str] = r.device);
        }
      }
    });

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      withServices: [Guid('6E400001-B5A3-F393-E0A9-E50E24DCCA9E')],
    );

    // Also scan without service filter to catch named devices
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 14));

    await Future<void>.delayed(const Duration(seconds: 14));
    if (mounted) setState(() => _scanning = false);
  }

  Future<void> _stopScan() async {
    await _scanSub?.cancel();
    await FlutterBluePlus.stopScan();
  }

  Future<void> _connect(BluetoothDevice device) async {
    await _stopScan();
    final ScannerService svc = ref.read(scannerServiceProvider);
    try {
      await svc.connectToDevice(device);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${device.platformName}'),
            backgroundColor: const Color(0xFF1A7A3C),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? connectedId =
        ref.watch(scannerServiceProvider).connectedDevice?.remoteId.str;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Connect EID Reader'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: const Color(0xFF1A7A3C).withValues(alpha: 0.08),
            child: Row(
              children: [
                if (_scanning)
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1A7A3C),
                    ),
                  )
                else
                  const Icon(Icons.bluetooth_searching_rounded,
                      color: Color(0xFF1A7A3C), size: 18),
                const SizedBox(width: 10),
                Text(
                  _scanning
                      ? 'Scanning for EID readers…'
                      : 'Scan complete — ${_discovered.length} device(s) found',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A7A3C),
                  ),
                ),
                if (!_scanning) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: _startScan,
                    child: const Text(
                      'Rescan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A7A3C),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Known device types hint
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              'Looking for: Farrax, XRS2, HR5, AWR300 or any Nordic UART device',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),

          // Device list
          Expanded(
            child: _discovered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bluetooth_disabled_rounded,
                            size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          _scanning
                              ? 'Searching…'
                              : 'No compatible readers found',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 15),
                        ),
                        if (!_scanning) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Make sure your reader is powered on\nand in pairing mode',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _discovered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, int i) {
                      final BluetoothDevice device =
                          _discovered.values.elementAt(i);
                      final bool isConnected =
                          connectedId == device.remoteId.str;
                      return _DeviceTile(
                        device: device,
                        isConnected: isConnected,
                        onTap: isConnected ? null : () => _connect(device),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Device Tile ─────────────────────────────────────────────────────────────

class _DeviceTile extends StatelessWidget {
  final BluetoothDevice device;
  final bool isConnected;
  final VoidCallback? onTap;

  const _DeviceTile({
    required this.device,
    required this.isConnected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String name = device.platformName.isNotEmpty
        ? device.platformName
        : 'Unknown Device';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: isConnected
                      ? const Color(0xFF1A7A3C).withValues(alpha: 0.12)
                      : Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bluetooth_rounded,
                  color: isConnected
                      ? const Color(0xFF1A7A3C)
                      : Colors.grey[400],
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Name & ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      device.remoteId.str,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              // Status / connect button
              if (isConnected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A7A3C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Connected',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A7A3C),
                    ),
                  ),
                )
              else
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFFCCCCCC)),
            ],
          ),
        ),
      ),
    );
  }
}
