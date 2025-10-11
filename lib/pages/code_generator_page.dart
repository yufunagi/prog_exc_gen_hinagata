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
    return ChangeNotifierProvider(
      create: (context) => CodeGeneratorState(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 入力セクション
              CodeInputSection(),
              SizedBox(height: 16),
              // コード表示セクション
              Expanded(child: CodeDisplaySection()),
            ],
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
          backgroundColor: Colors.green,
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
          backgroundColor: Colors.orange,
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
