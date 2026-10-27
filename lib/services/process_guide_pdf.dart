/// Generates a downloadable PDF rendering of a [ProcessGuide].
library;

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/process_guide.dart';

Future<Uint8List> buildProcessGuidePdf(ProcessGuide guide) async {
  final doc = pw.Document();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Text(
          guide.title,
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 14),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.amber50,
            border: pw.Border.all(color: PdfColors.amber200),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text(
            guide.disclaimer,
            style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
          ),
        ),
        pw.SizedBox(height: 22),
        ...guide.steps.expand(
          (step) => [
            pw.Text(
              'Step ${step.number}: ${step.title}',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              step.description,
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 16),
          ],
        ),
      ],
    ),
  );

  return doc.save();
}
