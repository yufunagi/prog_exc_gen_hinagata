import 'package:flutter/services.dart';

/// クリップボード操作を管理するサービス
class ClipboardService {
  /// テキストをクリップボードにコピー
  static Future<ClipboardResult> copyToClipboard(String text) async {
    if (text.isEmpty) {
      return ClipboardResult(success: false, message: 'コピーするテキストがありません');
    }

    try {
      await Clipboard.setData(ClipboardData(text: text));
      return ClipboardResult(
        success: true,
        message: 'コードをクリップボードにコピーしました (${text.length}文字)',
      );
    } catch (e) {
      return ClipboardResult(
        success: false,
        message: '自動コピーに失敗しました',
        needsManualCopy: true,
      );
    }
  }

  /// クリップボードからテキストを取得
  static Future<String?> getFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      return clipboardData?.text;
    } catch (e) {
      return null;
    }
  }

  /// クリップボードが利用可能かチェック
  static Future<bool> isClipboardAvailable() async {
    try {
      await Clipboard.getData(Clipboard.kTextPlain);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// クリップボード操作の結果を格納するクラス
class ClipboardResult {
  final bool success;
  final String message;
  final bool needsManualCopy;

  ClipboardResult({
    required this.success,
    required this.message,
    this.needsManualCopy = false,
  });
}
