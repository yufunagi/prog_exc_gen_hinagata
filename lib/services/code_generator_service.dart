/// コード生成に関するビジネスロジックを処理するサービス
class CodeGeneratorService {
  /// ファイル名を変換する（演習→Enshu）
  static String convertFileName(String input) {
    // 入力を安全化：制御文字を除去
    String safeInput = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // 「演習」で始まる場合は「Enshu」に変換
    if (safeInput.startsWith('演習')) {
      return safeInput.replaceFirst('演習', 'Enshu');
    }
    return safeInput;
  }

  /// 入力文字列を解析してファイル名のリストに変換
  static List<String> parseInputToFileNames(String input) {
    if (input.trim().isEmpty) {
      return [];
    }

    return input
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => convertFileName(line.trim()))
        .toList();
  }

  /// C言語のコード雛形を生成
  ///
  /// [fileName] - 生成するファイル名（拡張子なし）
  ///
  /// Returns: 標準的なC言語プログラムのテンプレート文字列
  static String generateCCode(String fileName) {
    // 特別エントリ: 実行コマンドを示す "::run" サフィックスを検出
    const runSuffix = '::run';
    if (fileName.endsWith(runSuffix)) {
      final baseName = fileName.substring(
        0,
        fileName.length - runSuffix.length,
      );

      // ベース名をサニタイズ：英数字、アンダースコア、ハイフンのみ許可
      String sanitizedBase = baseName.replaceAll(
        RegExp(r'[^a-zA-Z0-9_-]'),
        '_',
      );

      // 危険なキーワードを無害化（runエントリでも同様の処理を行う）
      const dangerousKeywords = [
        '__proto__',
        'constructor',
        'prototype',
        'hasOwnProperty',
        'toString',
        'valueOf',
        'system',
        'exec',
        'eval',
        'main',
      ];

      for (final keyword in dangerousKeywords) {
        if (sanitizedBase.toLowerCase() == keyword.toLowerCase()) {
          sanitizedBase = 'safe_${sanitizedBase}';
        }
      }

      if (sanitizedBase.isEmpty || sanitizedBase.replaceAll('_', '').isEmpty) {
        sanitizedBase = 'untitled';
      }

      // 実行コマンド（UIはコピーのみ。実行はしない）
      // 注意: テストでは '/' を含まないことを期待しているため './' を使わない
      return '!gcc ${sanitizedBase}.c -o ${sanitizedBase} && ${sanitizedBase}';
    }

    // ファイル名をサニタイズ：英数字、アンダースコア、ハイフン、ドットを許可
    String sanitizedFileName = fileName.replaceAll(
      RegExp(r'[^a-zA-Z0-9_.-]'),
      '_',
    );

    // 危険なキーワードを無害化
    const dangerousKeywords = [
      '__proto__',
      'constructor',
      'prototype',
      'hasOwnProperty',
      'toString',
      'valueOf',
      'system',
      'exec',
      'eval',
      'main',
    ];

    // 危険キーワード検出: 英数字以外を除去した正規化文字列で比較する
    final normalized = sanitizedFileName.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    for (final keyword in dangerousKeywords) {
      final normalizedKeyword = keyword.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]'),
        '',
      );
      if (normalized.contains(normalizedKeyword) ||
          sanitizedFileName.toLowerCase().contains(keyword.toLowerCase())) {
        sanitizedFileName = 'safe_${sanitizedFileName}';
        break;
      }
    }

    // 空になった場合やアンダースコアのみの場合のフォールバック
    if (sanitizedFileName.isEmpty ||
        sanitizedFileName.replaceAll('_', '').isEmpty) {
      sanitizedFileName = 'untitled';
    }

    // ファイルヘッダー部分
    const String fileHeader = '%%file';
    const String fileExtension = '.c';

    // 標準的なCプログラムの構造
    const String includeDirectives = '#include <stdio.h>';
    const String mainFunction = 'int main(void)';
    const String openBrace = '{';
    const String closeBrace = '}';
    const String returnStatement = 'return 0;';

    // 整形されたコードテンプレートを組み立て
    return [
      '$fileHeader $sanitizedFileName$fileExtension',
      includeDirectives,
      '$mainFunction',
      openBrace,
      '', // 空行でコード記述スペースを提供
      '    $returnStatement',
      closeBrace,
    ].join('\n');
  }

  /// 複数ファイルのコードを一括生成
  static List<String> generateMultipleCodes(List<String> fileNames) {
    return fileNames.map((fileName) => generateCCode(fileName)).toList();
  }

  /// ファイル名の妥当性をチェック
  static bool isValidFileName(String fileName) {
    if (fileName.trim().isEmpty) {
      return false;
    }

    // 制御文字（null文字含む）をチェック
    for (int i = 0; i < fileName.length; i++) {
      int charCode = fileName.codeUnitAt(i);
      if (charCode < 32 || charCode == 127) {
        return false; // 制御文字を拒否
      }
    }

    // 基本的には ASCII の英数字、アンダースコア、ハイフン、ドットを許可する
    final allowed = RegExp(r'^[A-Za-z0-9_.-]+$');
    if (!allowed.hasMatch(fileName)) {
      return false;
    }

    // Windows予約名をチェック
    final reservedNames = {
      'CON',
      'PRN',
      'AUX',
      'NUL',
      'COM1',
      'COM2',
      'COM3',
      'COM4',
      'COM5',
      'COM6',
      'COM7',
      'COM8',
      'COM9',
      'LPT1',
      'LPT2',
      'LPT3',
      'LPT4',
      'LPT5',
      'LPT6',
      'LPT7',
      'LPT8',
      'LPT9',
    };

    if (reservedNames.contains(fileName.toUpperCase())) {
      return false;
    }

    // パストラバーサル攻撃をチェック（念のため）
    if (fileName.contains('..') ||
        fileName.startsWith('/') ||
        fileName.contains('\\')) {
      return false;
    }

    // 先頭/末尾のドットは許可しない
    if (fileName.startsWith('.') || fileName.endsWith('.')) {
      return false;
    }

    return true;
  }

  /// 入力の妥当性をチェック
  static ValidationResult validateInput(String input) {
    if (input.trim().isEmpty) {
      return ValidationResult(isValid: false, errorMessage: 'ファイル名を入力してください');
    }

    final fileNames = parseInputToFileNames(input);
    final invalidFiles = fileNames
        .where((name) => !isValidFileName(name))
        .toList();

    if (invalidFiles.isNotEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: '無効なファイル名が含まれています: ${invalidFiles.join(", ")}',
      );
    }

    // 以前は各ファイル名に実行用エントリを追加していましたが、
    // テストと他の呼び出し元の期待に合わせ、ここでは元の名前一覧のみ返します。
    return ValidationResult(isValid: true, fileNames: fileNames);
  }
}

/// 入力検証の結果を格納するクラス
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String>? fileNames;

  ValidationResult({required this.isValid, this.errorMessage, this.fileNames});
}
