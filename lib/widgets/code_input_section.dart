import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/code_generator_state.dart';

class CodeInputSection extends StatefulWidget {
  const CodeInputSection({super.key});

  @override
  State<CodeInputSection> createState() => _CodeInputSectionState();
}

class _CodeInputSectionState extends State<CodeInputSection> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CodeGeneratorState>(
      builder: (context, state, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー（常に表示）
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ファイル名入力',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (state.hasFiles)
                      IconButton(
                        onPressed: () => state.toggleInputCollapse(),
                        icon: Icon(
                          state.isInputCollapsed
                              ? Icons.expand_more
                              : Icons.expand_less,
                        ),
                        tooltip: state.isInputCollapsed ? '展開' : '折りたたむ',
                      ),
                  ],
                ),

                // 折りたたまれている場合の簡潔な表示
                if (state.isInputCollapsed && state.hasFiles) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${state.totalFiles}個のファイルを生成済み',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                // 折りたたみ可能なコンテンツ
                if (!state.isInputCollapsed) ...[
                  const SizedBox(height: 8),
                  Text(
                    'ファイル名を入力してください（1行に1つ）:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'List1-1\nList1-2\n演習1-3',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    enabled: !state.isLoading,
                  ),
                  const SizedBox(height: 16),

                  // エラーメッセージ表示
                  if (state.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => state.clearError(),
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // 生成ボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => _generateCode(state),
                      child: state.isLoading
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('処理中...'),
                              ],
                            )
                          : const Text('生成'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _generateCode(CodeGeneratorState state) async {
    await state.parseInput(_inputController.text);
  }
}
