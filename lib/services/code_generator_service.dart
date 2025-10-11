/// コード生成に関するビジネスロジックを処理するサービス
class CodeGeneratorService {
  /// ファイル名を変換する（演習→Enshu）
  static String convertFileName(String input) {
    // 「演習」で始まる場合は「Enshu」に変換
    if (input.startsWith('演習')) {
      return input.replaceFirst('演習', 'Enshu');
    }
    return input;
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
      '$fileHeader $fileName$fileExtension',
      includeDirectives,
      '$mainFunction',
      openBrace,
      '',  // 空行でコード記述スペースを提供
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

    // 無効な文字をチェック（Windows/Mac/Linux共通の制限文字）
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    return !invalidChars.hasMatch(fileName);
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
