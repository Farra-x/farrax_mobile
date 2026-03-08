import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';

// Nordic UART Service UUIDs
const String _nuartServiceUuid = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
const String _nuartTxCharUuid  = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';

// Known reader device name fragments
const List<String> _knownDeviceNames = ['Farrax', 'XRS2', 'HR5', 'AWR300'];

class ScannerService {
  final StreamController<String> _tagController =
      StreamController<String>.broadcast();

  Stream<String> get tagStream => _tagController.stream;

  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<int>>? _txSubscription;

  BluetoothDevice? get connectedDevice => _connectedDevice;

  // ─── Tag Validation ────────────────────────────────────────────────────────

  /// Returns a normalised tag string if valid, null otherwise.
  /// Accepts:
  ///   • 15-digit ISO: 372141123456789
  ///   • Visual IE/UK format: IE141123456789 / UK123456789012
  String? validateTag(String raw) {
    final String tag = raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (tag.isEmpty) return null;

    // 15-digit ISO number
    if (RegExp(r'^\d{15}$').hasMatch(tag)) return tag;

    // IE + 12 digits
    if (RegExp(r'^IE\d{12}$').hasMatch(tag)) return tag;

    // UK + 12 digits
    if (RegExp(r'^UK\d{12}$').hasMatch(tag)) return tag;

    return null;
  }

  // ─── BLE ───────────────────────────────────────────────────────────────────

  bool isKnownDevice(BluetoothDevice device) {
    final String name = device.platformName.toUpperCase();
    return _knownDeviceNames.any((n) => name.contains(n.toUpperCase()));
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await disconnectDevice();
    await device.connect(timeout: const Duration(seconds: 10));
    _connectedDevice = device;
    await _subscribeToNuart(device);
  }

  Future<void> disconnectDevice() async {
    await _txSubscription?.cancel();
    _txSubscription = null;
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
  }

  Future<void> _subscribeToNuart(BluetoothDevice device) async {
    final List<BluetoothService> services = await device.discoverServices();
    for (final BluetoothService service in services) {
      if (service.uuid.str128.toLowerCase() == _nuartServiceUuid) {
        for (final BluetoothCharacteristic char in service.characteristics) {
          if (char.uuid.str128.toLowerCase() == _nuartTxCharUuid) {
            await char.setNotifyValue(true);
            _txSubscription = char.onValueReceived.listen((List<int> value) {
              final String raw = utf8.decode(value);
              final String? tag = validateTag(raw);
              if (tag != null) _tagController.add(tag);
            });
            return;
          }
        }
      }
    }
  }

  // ─── Camera / Barcode ──────────────────────────────────────────────────────

  Future<String?> scanWithCamera(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CameraScanSheet(),
    );
  }

  // ─── Manual Entry ──────────────────────────────────────────────────────────

  Future<String?> manualEntry(BuildContext context) async {
    final TextEditingController ctrl = TextEditingController();
    String? error;

    return showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx2, StateSetter setState) {
            return AlertDialog(
              title: const Text('Enter Tag Number'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ctrl,
                    autofocus: true,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'IE141123456789 or 372141123456789',
                      errorText: error,
                    ),
                    onChanged: (_) {
                      if (error != null) setState(() => error = null);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx2),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A7A3C),
                  ),
                  onPressed: () {
                    final String? tag = validateTag(ctrl.text);
                    if (tag != null) {
                      _tagController.add(tag);
                      Navigator.pop(ctx2, tag);
                    } else {
                      setState(() => error =
                          'Invalid format. Use IE/UK + 12 digits or 15-digit ISO.');
                    }
                  },
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void dispose() {
    disconnectDevice();
    _tagController.close();
  }
}

// ─── Camera Scan Bottom Sheet ────────────────────────────────────────────────

class _CameraScanSheet extends StatefulWidget {
  const _CameraScanSheet();

  @override
  State<_CameraScanSheet> createState() => _CameraScanSheetState();
}

class _CameraScanSheetState extends State<_CameraScanSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final MobileScannerController _barcodeCtrl = MobileScannerController();
  bool _ocrProcessing = false;
  String? _ocrResult;

  // Latest frame captured by the OCR camera view
  Uint8List? _lastFrame;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _barcodeCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    // Save latest frame for OCR use
    if (capture.image != null) _lastFrame = capture.image;

    // Only auto-pop on barcode tab
    if (_tabs.index != 0) return;
    if (capture.barcodes.isEmpty) return;
    final String? raw = capture.barcodes.first.rawValue;
    if (raw == null) return;
    final String? tag = ScannerService().validateTag(raw);
    if (tag != null && mounted) Navigator.pop(context, tag);
  }

  Future<void> _captureOcr() async {
    final Uint8List? frame = _lastFrame;
    if (frame == null) {
      setState(() => _ocrResult = 'Point camera at tag, then tap Read Tag');
      return;
    }
    setState(() { _ocrProcessing = true; _ocrResult = null; });
    try {
      // Save JPEG bytes from BarcodeCapture.image to a temp file for MLKit
      final Directory tmp = await getTemporaryDirectory();
      final File file = File('${tmp.path}/farrax_ocr.jpg');
      await file.writeAsBytes(frame);

      final InputImage inputImage = InputImage.fromFilePath(file.path);
      final TextRecognizer recognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText result = await recognizer.processImage(inputImage);
      await recognizer.close();

      final ScannerService svc = ScannerService();
      for (final TextBlock block in result.blocks) {
        final String? tag = svc.validateTag(block.text);
        if (tag != null && mounted) {
          Navigator.pop(context, tag);
          return;
        }
      }
      setState(() => _ocrResult = 'No valid tag found — try again');
    } finally {
      if (mounted) setState(() => _ocrProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ScrollController scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabs,
                labelColor: const Color(0xFF1A7A3C),
                indicatorColor: const Color(0xFF1A7A3C),
                tabs: const [
                  Tab(text: 'Barcode / QR'),
                  Tab(text: 'OCR — Read Text'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    // Tab 1: Barcode
                    MobileScanner(
                      controller: _barcodeCtrl,
                      onDetect: _onDetect,
                    ),
                    // Tab 2: OCR — same controller feeds _lastFrame
                    Stack(
                      children: [
                        MobileScanner(
                          controller: _barcodeCtrl,
                          onDetect: _onDetect,
                        ),
                        Positioned(
                          bottom: 32,
                          left: 0, right: 0,
                          child: Column(
                            children: [
                              if (_ocrResult != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    _ocrResult!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: _ocrProcessing ? null : _captureOcr,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A7A3C),
                                    minimumSize: const Size(180, 52),
                                  ),
                                  icon: _ocrProcessing
                                      ? const SizedBox(
                                          width: 18, height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.text_fields_rounded,
                                          color: Colors.white),
                                  label: const Text('Read Tag',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
