library pdf_to_image_converter;

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class PdfImageConverter {
  PdfImageRendererPdf? _pdf;
  bool _open = false;
  int? _pageCount;
  PdfImageRendererPageSize? _size;
  int _pageIndex = 0;

  bool get isOpen => _open;
  int get pageCount => _pageCount ?? 0;
  int get currentPage => _pageIndex;

  Future<void> openPdf(String path) async {
    if (_pdf != null) {
      await _pdf!.close();
    }
    _pdf = PdfImageRendererPdf(path: path);
    await _pdf!.open();
    _open = true;
    _pageCount = await _pdf!.getPageCount();
  }

  Future<void> closePdf() async {
    if (_pdf != null) {
      await _pdf!.close();
      _pdf = null;
      _open = false;
    }
  }

  Future<Uint8List?> renderPage(int pageIndex) async {
    _size = await _pdf!.getPageSize(pageIndex: pageIndex);
    final renderedImage = await _pdf!.renderPage(
      pageIndex: pageIndex,
      background: Colors.white,
      scale: 3,
      x: 0,
      y: 0,
      width: _size!.width,
      height: _size!.height,
    );
    _pageIndex = pageIndex;
    return renderedImage;
  }

  Future<void> saveImage(Uint8List imageBytes, Function(bool) onSave) async {
    final result = await ImageGallerySaverPlus.saveImage(imageBytes);
    onSave(result['isSuccess']);
  }
}

class PdfPicker {
  static Future<String?> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    return result?.files.first.path;
  }
}
