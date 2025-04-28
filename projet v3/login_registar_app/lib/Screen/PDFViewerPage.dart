import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewerPage extends StatelessWidget {
  final String cvUrl;

  const PDFViewerPage({Key? key, required this.cvUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon CV'),
      ),
      body: SfPdfViewer.network(
        cvUrl,
        canShowPaginationDialog: true,
        canShowScrollHead: true,
      ),
    );
  }
}
