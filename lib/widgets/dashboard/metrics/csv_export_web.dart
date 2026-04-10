// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void downloadCsv(String csvContent, String filename) {
  final blob = html.Blob([csvContent], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)..download = filename;
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
