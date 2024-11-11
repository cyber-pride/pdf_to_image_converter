import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf_to_image_converter/pdf_to_image_converter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF to Image Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PdfToImageScreen(),
    );
  }
}

class PdfToImageScreen extends StatefulWidget {
  const PdfToImageScreen({super.key});

  @override
  State<PdfToImageScreen> createState() => _PdfToImageScreenState();
}

class _PdfToImageScreenState extends State<PdfToImageScreen> {
  final PdfImageConverter _converter = PdfImageConverter();
  Uint8List? _image;

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF to Image Converter'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ElevatedButton(
                child: const Text('Select PDF'),
                onPressed: () async {
                  final path = await PdfPicker.pickPdf();
                  if (path != null) {
                    await _converter.openPdf(path);
                    _image = await _converter.renderPage(0);
                    setState(() {});
                  }
                },
              ),
              if (_converter.isOpen)
                ElevatedButton(
                  child: const Text('Close PDF'),
                  onPressed: () async {
                    await _converter.closePdf();
                    setState(() {});
                  },
                ),
              if (_image != null) ...[
                const Text('Image area:'),
                Image(image: MemoryImage(_image!)),
                ElevatedButton(
                  child: const Text('Save Image'),
                  onPressed: () async {
                    if (_image != null) {
                      await _converter.saveImage(_image!, (bool isSuccess) {
                        _showSnackbar(
                          isSuccess
                              ? 'Image successfully saved to gallery.'
                              : 'Failed to save image.',
                        );
                      });
                    }
                  },
                ),
              ],
              if (_converter.isOpen) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton.icon(
                      onPressed: _converter.currentPage > 0
                          ? () async {
                              _image = await _converter.renderPage(
                                  _converter.currentPage - 1);
                              setState(() {});
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Previous'),
                    ),
                    TextButton.icon(
                      onPressed: _converter.currentPage < (_converter.pageCount - 1)
                          ? () async {
                              _image = await _converter.renderPage(
                                  _converter.currentPage + 1);
                              setState(() {});
                            }
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
