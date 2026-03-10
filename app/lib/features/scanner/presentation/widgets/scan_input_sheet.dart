import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/scanner_service.dart';
import '../../../../core/services/tag_handler.dart';
import '../providers/scanner_provider.dart';

/// A bottom sheet that lets the user choose how to input an EID tag:
///   • BLE Reader  • Camera Scan (barcode/QR + OCR)  • Manual Entry
///
/// Shows a live "Connected: <name>" badge when a BLE device is linked.
///
/// Usage:
///   showModalBottomSheet(context: context, builder: (_) => const ScanInputSheet());
class ScanInputSheet extends ConsumerWidget {
  final TagHandler tagHandler;

  /// The BuildContext of the page that opened this sheet (HomeShell /
  /// DashboardScreen). Must remain mounted after the sheet is dismissed so we
  /// can show the tag-result sheets on top of the correct navigator.
  final BuildContext outerContext;

  const ScanInputSheet({
    super.key,
    required this.tagHandler,
    required this.outerContext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? connectedName = ref.watch(connectedDeviceNameProvider);
    final bool isBatch = ref.watch(isBatchModeProvider);
    final List<String> batchList = ref.watch(batchScanListProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Scan EID Tag',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D1F14),
                  ),
                ),
                const Spacer(),
                if (connectedName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A7A3C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bluetooth_connected_rounded,
                            size: 13, color: Color(0xFF1A7A3C)),
                        const SizedBox(width: 4),
                        Text(
                          connectedName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A7A3C),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Input method buttons (2×2 grid)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _MethodButton(
                    icon: Icons.bluetooth_rounded,
                    label: 'BLE Reader',
                    sublabel: connectedName != null ? 'Connected' : 'Pair device',
                    color: const Color(0xFF1A7A3C),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/scanner/ble');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MethodButton(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'Camera Scan',
                    sublabel: 'Barcode / OCR',
                    color: const Color(0xFF0D6EAF),
                    onTap: () async {
                      Navigator.pop(context);
                      final ScannerService svc = ref.read(scannerServiceProvider);
                      final String? tag = await svc.scanWithCamera(outerContext);
                      if (tag != null && outerContext.mounted) {
                        await tagHandler.handleTag(tag, outerContext);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _MethodButton(
                    icon: Icons.keyboard_rounded,
                    label: 'Manual Entry',
                    sublabel: 'Type tag number',
                    color: const Color(0xFF6B5EA8),
                    onTap: () async {
                      Navigator.pop(context);
                      final ScannerService svc = ref.read(scannerServiceProvider);
                      final String? tag = await svc.manualEntry(outerContext);
                      if (tag != null && outerContext.mounted) {
                        await tagHandler.handleTag(tag, outerContext);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MethodButton(
                    icon: isBatch
                        ? Icons.playlist_add_check_rounded
                        : Icons.playlist_add_rounded,
                    label: 'Batch Mode',
                    sublabel: isBatch
                        ? '${batchList.length} tag${batchList.length == 1 ? '' : 's'}'
                        : 'Scan multiple',
                    color: const Color(0xFFF0A500),
                    onTap: () {
                      ref.read(isBatchModeProvider.notifier).toggle();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Batch list preview
          if (isBatch && batchList.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Batch (${batchList.length})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D1F14),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => ref.read(batchScanListProvider.notifier).clear(),
                    child: const Text(
                      'Clear all',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: batchList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, int i) => _BatchTagChip(
                  tag: batchList[i],
                  onRemove: () =>
                      ref.read(batchScanListProvider.notifier).remove(batchList[i]),
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Method Button ────────────────────────────────────────────────────────────

class _MethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _MethodButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Batch Tag Chip ───────────────────────────────────────────────────────────

class _BatchTagChip extends StatelessWidget {
  final String tag;
  final VoidCallback onRemove;

  const _BatchTagChip({required this.tag, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E4E0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: Color(0xFF0D1F14),
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Text(
              'Remove',
              style: TextStyle(
                fontSize: 10,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
