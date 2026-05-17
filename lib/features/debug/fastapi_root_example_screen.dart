import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/library_config_service.dart';

/// Màn ví dụ: GET `/` từ FastAPI, in JSON ra console, hiển thị lỗi rõ ràng.
///
/// Mở bằng: `Navigator.pushNamed(context, AppRoutes.fastApiRootExample);`
class FastApiRootExampleScreen extends StatefulWidget {
  const FastApiRootExampleScreen({super.key});

  @override
  State<FastApiRootExampleScreen> createState() =>
      _FastApiRootExampleScreenState();
}

class _FastApiRootExampleScreenState extends State<FastApiRootExampleScreen> {
  late final TextEditingController _baseUrlCtrl;
  String? _resultText;
  String? _errorText;
  bool _loading = false;

  static const String _defaultBase = 'http://10.10.10.113:8000';

  @override
  void initState() {
    super.initState();
    // Bước 1: ô nhập base URL (có thể ghi đè sau khi load Firestore).
    _baseUrlCtrl = TextEditingController(text: _defaultBase);
    // Bước 2: ưu tiên URL đã lưu trong library_settings/config.
    _loadConfiguredBaseUrl();
  }

  Future<void> _loadConfiguredBaseUrl() async {
    try {
      final fromConfig = await LibraryConfigService.fastApiBaseUrl();
      if (!mounted) return;
      if (fromConfig != null) {
        _baseUrlCtrl.text = fromConfig;
      }
    } catch (_) {
      // Giữ mặc định _defaultBase.
    }
  }

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    super.dispose();
  }

  /// Bước 3: tạo [ApiService], gọi GET `/`, parse JSON object, in console.
  Future<void> _callRoot() async {
    setState(() {
      _loading = true;
      _errorText = null;
      _resultText = null;
    });

    final base = _baseUrlCtrl.text.trim();
    final api = ApiService(baseUrl: base.isEmpty ? _defaultBase : base);

    try {
      // GET / → path rỗng hoặc '' đều resolve về root của base.
      final jsonMap = await api.getJsonObject('');
      api.dispose();

      // Bước 4: in ra console (debug / logcat).
      debugPrint('[FastAPI GET /] ${jsonEncode(jsonMap)}');

      if (!mounted) return;
      setState(() {
        _resultText = const JsonEncoder.withIndent('  ').convert(jsonMap);
        _loading = false;
      });
    } on ApiTimeoutException catch (e) {
      api.dispose();
      debugPrint('[FastAPI] timeout: $e');
      if (!mounted) return;
      setState(() {
        _errorText = e.toString();
        _loading = false;
      });
    } on ApiHttpException catch (e) {
      api.dispose();
      debugPrint('[FastAPI] HTTP: $e');
      if (!mounted) return;
      setState(() {
        _errorText = e.toString();
        _loading = false;
      });
    } on ApiParseException catch (e) {
      api.dispose();
      debugPrint('[FastAPI] parse: $e');
      if (!mounted) return;
      setState(() {
        _errorText = e.toString();
        _loading = false;
      });
    } catch (e, st) {
      api.dispose();
      debugPrint('[FastAPI] unexpected: $e\n$st');
      if (!mounted) return;
      setState(() {
        _errorText = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FastAPI — GET /')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _baseUrlCtrl,
            decoration: const InputDecoration(
              labelText: 'Base URL',
              hintText: _defaultBase,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            autocorrect: false,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _callRoot,
            child: Text(_loading ? 'Đang gọi…' : 'Gọi GET /'),
          ),
          const SizedBox(height: 24),
          if (_errorText != null) ...[
            Text('Lỗi', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(
              _errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_resultText != null) ...[
            Text('Phản hồi', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(_resultText!),
          ],
        ],
      ),
    );
  }
}
