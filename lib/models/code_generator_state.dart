import 'package:flutter/material.dart';
import '../services/code_generator_service.dart';

/// コード生成画面の状態を管理するクラス
class CodeGeneratorState extends ChangeNotifier {
  List<String> _fileNames = [];
  int _currentIndex = 0;
  String _generatedCode = '';
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<String> get fileNames => List.unmodifiable(_fileNames);
  int get currentIndex => _currentIndex;
  String get generatedCode => _generatedCode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasFiles => _fileNames.isNotEmpty;
  bool get canGoNext => _currentIndex < _fileNames.length - 1;
  bool get canGoPrevious => _currentIndex > 0;
  String get currentFileName => hasFiles ? _fileNames[_currentIndex] : '';
  int get totalFiles => _fileNames.length;

  /// 入力を解析してファイルリストを生成
  Future<void> parseInput(String input) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 100)); // UI応答性のための短い遅延

      final validationResult = CodeGeneratorService.validateInput(input);

      if (!validationResult.isValid) {
        _setError(validationResult.errorMessage ?? '不明なエラーが発生しました');
        return;
      }

      _fileNames = validationResult.fileNames ?? [];
      _currentIndex = 0;

      if (_fileNames.isNotEmpty) {
        await _generateCurrentCode();
      } else {
        _generatedCode = '';
      }
    } catch (e) {
      _setError('処理中にエラーが発生しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 次のコードに移動
  Future<void> nextCode() async {
    if (canGoNext) {
      _currentIndex++;
      await _generateCurrentCode();
    }
  }

  /// 前のコードに移動
  Future<void> previousCode() async {
    if (canGoPrevious) {
      _currentIndex--;
      await _generateCurrentCode();
    }
  }

  /// 現在のファイルのコードを生成
  Future<void> _generateCurrentCode() async {
    if (_fileNames.isEmpty) return;

    try {
      final fileName = _fileNames[_currentIndex];
      _generatedCode = CodeGeneratorService.generateCCode(fileName);
      notifyListeners();
    } catch (e) {
      _setError('コード生成中にエラーが発生しました: $e');
    }
  }

  /// 状態をリセット
  void reset() {
    _fileNames.clear();
    _currentIndex = 0;
    _generatedCode = '';
    _clearError();
    notifyListeners();
  }

  /// ローディング状態を設定
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// エラーメッセージを設定
  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  /// エラーをクリア
  void _clearError() {
    _errorMessage = null;
  }

  /// エラーを手動でクリア
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
