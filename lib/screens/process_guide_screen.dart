/// Full-page view for an illustrative process/implementation guide.
/// Lets the customer read the numbered steps and download a PDF copy.
library;

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models/process_guide.dart';
import '../services/process_guide_pdf.dart';

class ProcessGuideScreen extends StatefulWidget {
  final ProcessGuide guide;

  const ProcessGuideScreen({super.key, required this.guide});

  @override
  State<ProcessGuideScreen> createState() => _ProcessGuideScreenState();
}

class _ProcessGuideScreenState extends State<ProcessGuideScreen> {
  bool _isGenerating = false;

  Future<void> _downloadPdf() async {
    setState(() => _isGenerating = true);
    try {
      final bytes = await buildProcessGuidePdf(widget.guide);
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: '${widget.guide.title}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final guide = widget.guide;
    return Scaffold(
      appBar: AppBar(
        title: Text(guide.title),
        actions: [
          IconButton(
            icon: _isGenerating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download),
            tooltip: 'Download PDF',
            onPressed: _isGenerating ? null : _downloadPdf,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              border: Border.all(color: Colors.amber[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    guide.disclaimer,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...guide.steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1F4788),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${step.number}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          step.description,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _downloadPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Download PDF'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
