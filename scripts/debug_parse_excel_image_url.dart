import 'dart:io';

import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

String _dynamicToString(dynamic v) {
  if (v == null) return '';
  if (v is String) return v.trim();
  if (v is int) return v.toString();
  if (v is double) {
    if (v.isFinite && v == v.roundToDouble()) return v.round().toString();
    return v.toString();
  }
  if (v is DateTime) {
    return '${v.day.toString().padLeft(2, '0')}/${v.month.toString().padLeft(2, '0')}/${v.year}';
  }
  if (v is bool) return v.toString();
  return v.toString().trim();
}

String _normHeader(String raw) {
  var s = raw.toLowerCase().trim();
  s = s.replaceAll('_', ' ');
  s = s.replaceAll(
    RegExp(
      r'[()\[\]{}<>.,:;!?/\\|`"'
      '“”‘’]',
    ),
    ' ',
  );
  s = s.replaceAll(RegExp(r'\s+'), ' ');
  return s.trim();
}

String? _extractFirstHttpUrl(String raw) {
  var s = raw.trim();
  if (s.isEmpty) return null;
  if (s.startsWith("'")) s = s.substring(1).trim();
  final mHyper = RegExp(
    r'HYPERLINK\(\"(https?://[^\"]+)\"',
    caseSensitive: false,
  ).firstMatch(s);
  if (mHyper != null) return mHyper.group(1)?.trim();
  final m = RegExp(r'(https?://\S+)', caseSensitive: false).firstMatch(s);
  if (m == null) return null;
  var url = (m.group(1) ?? '').trim();
  url = url.replaceAll(RegExp(r'[\"\),;]+$'), '');
  return url.isEmpty ? null : url;
}

SpreadsheetTable? _firstTableWithRows(SpreadsheetDecoder dec) {
  if (dec.tables.isEmpty) return null;
  for (final t in dec.tables.values) {
    if (t.rows.isNotEmpty) return t;
  }
  return null;
}

Future<void> main(List<String> args) async {
  final path = args.isNotEmpty ? args.first : '15_cuon_sach_anh.xlsx';
  final f = File(path);
  if (!f.existsSync()) {
    stderr.writeln('File not found: ${f.absolute.path}');
    exitCode = 2;
    return;
  }

  final bytes = await f.readAsBytes();
  final dec = SpreadsheetDecoder.decodeBytes(bytes);
  final table = _firstTableWithRows(dec);
  if (table == null) {
    stderr.writeln('No sheet/table rows found.');
    exitCode = 3;
    return;
  }

  final rows = table.rows;
  if (rows.isEmpty) {
    stderr.writeln('Empty sheet.');
    exitCode = 3;
    return;
  }

  final header = rows.first.map(_dynamicToString).toList();
  final colField = <int, String>{};
  for (var c = 0; c < header.length; c++) {
    final h = _normHeader(header[c]);
    stdout.writeln('Header[$c] raw="${header[c]}" norm="$h"');
    if (h.isEmpty) continue;
    if (h == 'ảnh bìa url' ||
        h == 'anh bia url' ||
        h == 'image url' ||
        h == 'imageurl' ||
        h == 'image_url') {
      colField[c] = 'imageUrl';
    }
    if (h == 'ảnh bìa' ||
        h == 'anh bia' ||
        h == 'image url' ||
        h == 'imageurl' ||
        h == 'image') {
      colField.putIfAbsent(c, () => 'imageUrl');
    }
  }
  final imageCol = colField.entries
      .where((e) => e.value == 'imageUrl')
      .map((e) => e.key)
      .toList();
  stdout.writeln('Detected imageUrl columns: $imageCol');
  stdout.writeln('Header row: $header');
  stdout.writeln('');

  for (var r = 1; r < rows.length; r++) {
    final row = rows[r];
    final cells = row.map(_dynamicToString).toList();
    if (cells.every((e) => e.trim().isEmpty)) continue;
    final raw = imageCol.isEmpty || imageCol.first >= cells.length
        ? ''
        : cells[imageCol.first];
    final extracted = _extractFirstHttpUrl(raw) ?? '';
    stdout.writeln('Row ${r + 1}: raw="$raw" => extracted="$extracted"');
  }
}
