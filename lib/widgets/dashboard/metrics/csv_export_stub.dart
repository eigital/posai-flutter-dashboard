import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void downloadCsv(String csvContent, String filename) {
  if (kIsWeb) return;
  Clipboard.setData(ClipboardData(text: csvContent));
}
