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
          return Center(
            child: Text(
              'ファイル名を入力してコードを生成してください',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        final screenHeight = MediaQuery.of(context).size.height;
        final codeAreaHeight = screenHeight > 600 ? 200.0 : screenHeight * 0.4;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー部分
                Text(
                  '生成されたコード (${state.currentIndex + 1}/${state.totalFiles})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '現在のファイル: ${state.currentFileName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // コード表示エリア
                Container(
                  width: double.infinity,
                  height: codeAreaHeight, // レスポンシブな高さを設定
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      // コード表示エリア（下層）
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          12,
                          48,
                          12,
                          12,
                        ), // 上部にボタン用のスペースを確保
                        child: SingleChildScrollView(
                          child: SelectableText(
                            state.generatedCode,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              height: 1.4,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      // ボタンエリア（上層）
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.shadow.withValues(alpha: 0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // コピーボタン
                              IconButton(
                                onPressed: () => copyToClipboard(
                                  context,
                                  state.generatedCode,
                                ),
                                icon: const Icon(Icons.content_copy, size: 18),
                                tooltip: 'コピー',
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                              // ナビゲーションボタン
                              IconButton(
                                onPressed: state.canGoPrevious
                                    ? () => state.previousCode()
                                    : null,
                                icon: const Icon(Icons.arrow_back, size: 18),
                                tooltip: '前へ',
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                              IconButton(
                                onPressed: state.canGoNext
                                    ? () => state.nextCode()
                                    : null,
                                icon: const Icon(Icons.arrow_forward, size: 18),
                                tooltip: '次へ',
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
