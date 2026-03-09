import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/database/database.dart';

class ReportGenerator {
  // ── CSV ────────────────────────────────────────────────────────────────────

  static String generateAnimalsCsv(List<Animal> animals) {
    final List<List<dynamic>> rows = [
      ['Tag Number', 'Breed', 'Sex', 'Date of Birth', 'Dam Tag', 'Sire Tag', 'Active'],
      ...animals.map((Animal a) => [
            a.tagNumber,
            a.breed,
            a.sex,
            DateFormat('dd/MM/yyyy').format(a.dateOfBirth),
            a.damTagNumber ?? '',
            a.sireTagNumber ?? '',
            a.isActive ? 'Yes' : 'No',
          ]),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  static String generateMovementsCsv(List<MovementEvent> events) {
    final List<List<dynamic>> rows = [
      ['Animal Tag', 'Date', 'Type', 'Origin', 'Destination', 'Reason'],
      ...events.map((MovementEvent e) => [
            e.animalId,
            DateFormat('dd/MM/yyyy').format(e.eventDate),
            e.movementType,
            e.originFarmName ?? '',
            e.destinationFarmName ?? '',
            e.notes ?? '',
          ]),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  static String generateMedicineCsv(List<MedicineEvent> events) {
    final List<List<dynamic>> rows = [
      [
        'Animal Tag', 'Drug Name', 'Date', 'Dose', 'Unit',
        'Route', 'Meat WD Days', 'Milk WD Days',
        'Meat Clear Date', 'Milk Clear Date', 'Treated By',
      ],
      ...events.map((MedicineEvent e) => [
            e.animalId,
            e.drugName,
            DateFormat('dd/MM/yyyy').format(e.eventDate),
            e.doseGiven?.toString() ?? '',
            e.doseUnit,
            e.route,
            e.withdrawalMeatDays?.toString() ?? '',
            e.withdrawalMilkDays?.toString() ?? '',
            e.meatClearDate != null
                ? DateFormat('dd/MM/yyyy').format(e.meatClearDate!)
                : '',
            e.milkClearDate != null
                ? DateFormat('dd/MM/yyyy').format(e.milkClearDate!)
                : '',
            e.treatedBy,
          ]),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  static String generateTbTestsCsv(List<TbTestEvent> tests) {
    final List<List<dynamic>> rows = [
      ['Animal Tag', 'Test Date', 'Test Type', 'Result', 'Vet Name', 'Next Due Date', 'Restricted'],
      ...tests.map((TbTestEvent t) => [
            t.animalId,
            DateFormat('dd/MM/yyyy').format(t.testDate),
            t.testType,
            t.result,
            t.vetName ?? '',
            t.nextTestDueDate != null
                ? DateFormat('dd/MM/yyyy').format(t.nextTestDueDate!)
                : '',
            t.isRestricted ? 'Yes' : 'No',
          ]),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  // ── PDF ────────────────────────────────────────────────────────────────────

  static Future<Uint8List> generateHerdRegisterPdf({
    required List<Animal> animals,
    required String farmName,
    required String herdNumber,
  }) async {
    final pw.Document doc = pw.Document();
    const PdfPageFormat format = PdfPageFormat.a4;

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => _pdfHeader(farmName, herdNumber, 'Herd Register'),
        footer: (_) => _pdfFooter(),
        build: (pw.Context ctx) => [
          pw.TableHelper.fromTextArray(
            headers: [
              'Tag Number', 'Breed', 'Sex', 'Date of Birth',
              'Dam Tag', 'Active',
            ],
            data: animals.map((Animal a) => [
                  a.tagNumber,
                  a.breed,
                  a.sex,
                  DateFormat('dd/MM/yyyy').format(a.dateOfBirth),
                  a.damTagNumber ?? '-',
                  a.isActive ? 'Yes' : 'No',
                ]).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1A7A3C),
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.centerLeft,
              5: pw.Alignment.center,
            },
          ),
        ],
      ),
    );

    return doc.save();
  }

  static Future<Uint8List> generateMedicineRegisterPdf({
    required List<MedicineEvent> events,
    required String farmName,
    required String herdNumber,
  }) async {
    final pw.Document doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (_) => _pdfHeader(farmName, herdNumber, 'Medicine Register'),
        footer: (_) => _pdfFooter(),
        build: (pw.Context ctx) => [
          pw.TableHelper.fromTextArray(
            headers: [
              'Animal', 'Drug', 'Date', 'Dose', 'Route',
              'Meat Clear', 'Milk Clear', 'By',
            ],
            data: events.map((MedicineEvent e) => [
                  e.animalId,
                  e.drugName,
                  DateFormat('dd/MM/yy').format(e.eventDate),
                  e.doseGiven != null
                      ? '${e.doseGiven} ${e.doseUnit}'
                      : '-',
                  e.route,
                  e.meatClearDate != null
                      ? DateFormat('dd/MM/yy').format(e.meatClearDate!)
                      : '-',
                  e.milkClearDate != null
                      ? DateFormat('dd/MM/yy').format(e.milkClearDate!)
                      : '-',
                  e.treatedBy,
                ]).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 8,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1A7A3C),
            ),
            cellStyle: const pw.TextStyle(fontSize: 7),
          ),
        ],
      ),
    );

    return doc.save();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static pw.Widget _pdfHeader(
      String farmName, String herdNumber, String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF1A7A3C),
                  ),
                ),
                pw.Text(
                  '$farmName · $herdNumber',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Text(
              'Generated ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
              style: const pw.TextStyle(
                  fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: const PdfColor.fromInt(0xFF1A7A3C), thickness: 1),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _pdfFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300, thickness: 0.5),
        pw.SizedBox(height: 4),
        pw.Text(
          'Farrax — Herd Management · farrax.com',
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  /// Print a PDF directly (opens system print dialog)
  static Future<void> printPdf(Uint8List bytes, String title) async {
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: title,
    );
  }
}
