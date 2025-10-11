import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/code_generator_state.dart';
import '../services/clipboard_service.dart';
import '../widgets/code_input_section.dart';
import '../widgets/code_display_section.dart';
import '../widgets/copy_dialog.dart';

class CodeGeneratorPage extends StatelessWidget {
  const CodeGeneratorPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 32.0 : 16.0;

    return ChangeNotifierProvider(
      create: (context) => CodeGeneratorState(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 入力セクション
                  const CodeInputSection(),
                  const SizedBox(height: 16),
                  // コード表示セクション（最小高さを設定）
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: const CodeDisplaySection(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// コピーボタンのMixin
mixin CopyFunctionality {
  Future<void> copyToClipboard(BuildContext context, String code) async {
    final result = await ClipboardService.copyToClipboard(code);

    if (!context.mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
    } else {
      if (result.needsManualCopy) {
        _showCopyDialog(context, code);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  void _showCopyDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CopyDialog(code: code),
    );
  }
}
