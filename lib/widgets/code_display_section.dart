import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/code_generator_state.dart';
import '../pages/code_generator_page.dart';

class CodeDisplaySection extends StatelessWidget with CopyFunctionality {
  const CodeDisplaySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CodeGeneratorState>(
      builder: (context, state, child) {
        if (!state.hasFiles) {
          return const Center(
            child: Text(
              'ファイル名を入力してコードを生成してください',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー部分
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '生成されたコード (${state.currentIndex + 1}/${state.totalFiles})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        // コピーボタン
                        IconButton(
                          onPressed: () =>
                              copyToClipboard(context, state.generatedCode),
                          icon: const Icon(Icons.content_copy),
                          tooltip: 'コピー',
                        ),
                        const SizedBox(width: 8),
                        // ナビゲーションボタン
                        IconButton(
                          onPressed: state.canGoPrevious
                              ? () => state.previousCode()
                              : null,
                          icon: const Icon(Icons.arrow_back),
                          tooltip: '前へ',
                        ),
                        IconButton(
                          onPressed: state.canGoNext
                              ? () => state.nextCode()
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                          tooltip: '次へ',
                        ),
                      ],
                    ),
                  ],
                ),

                // ファイル名表示
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '現在のファイル: ${state.currentFileName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // コード表示エリア
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        state.generatedCode,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
