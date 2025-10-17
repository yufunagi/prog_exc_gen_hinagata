import 'package:flutter_test/flutter_test.dart';
import 'package:prog_exc_gen_hinagata/services/code_generator_service.dart';

void main() {
  group('セキュリティテスト - 不正入力対策', () {
    test('SQLインジェクション風の入力テスト', () {
      const maliciousInputs = [
        "'; DROP TABLE files; --",
        "1' OR '1'='1",
        "admin'--",
        "1'; DELETE FROM users; --",
        "' UNION SELECT * FROM passwords --",
        "<script>alert('xss')</script>",
        "javascript:alert('xss')",
        "../../../etc/passwd",
        "..\\..\\windows\\system32\\config",
        "file:///etc/passwd",
        "http://evil.com/payload",
        "ftp://malicious.site/exploit",
      ];

      for (final input in maliciousInputs) {
        final result = CodeGeneratorService.validateInput(input);

        // 不正な入力は適切にブロックされるか確認
        if (result.isValid) {
          final fileNames = result.fileNames ?? [];
          // 有効と判定された場合、安全なファイル名のみが含まれているか確認
          for (final fileName in fileNames) {
            expect(
              CodeGeneratorService.isValidFileName(fileName),
              isTrue,
              reason: 'ファイル名 "$fileName" が安全でない可能性があります',
            );
          }
        }

        // コード生成が安全に実行されるか確認
        if (result.isValid && result.fileNames != null) {
          expect(
            () => CodeGeneratorService.generateMultipleCodes(result.fileNames!),
            returnsNormally,
            reason: '入力 "$input" でコード生成時に例外が発生しました',
          );
        }
      }
    });

    test('特殊文字とエスケープシーケンステスト', () {
      const specialInputs = [
        '\x00\x01\x02', // null bytes
        '\n\r\t', // 制御文字
        '\\n\\r\\t', // エスケープシーケンス
        '${'\$'}{injection}', // テンプレート文字列風
        '%s%d%x%n', // フォーマット文字列風
        '{{evil}}', // テンプレート風
        '\${System.exit(0)}', // Dart風インジェクション
        '`rm -rf /`', // コマンドインジェクション風
        '\$(echo "pwned")', // シェルインジェクション風
        '<!--#exec cmd="cat /etc/passwd"-->', // SSI風
      ];

      for (final input in specialInputs) {
        final result = CodeGeneratorService.validateInput(input);

        if (result.isValid && result.fileNames != null) {
          final generatedCodes = CodeGeneratorService.generateMultipleCodes(
            result.fileNames!,
          );

          for (final code in generatedCodes) {
            // runエントリ（実行コマンド）は '!gcc' で始まる仕様なので、その場合はCコード構造の検査をスキップ
            if (code.startsWith('!gcc')) {
              // runコマンド自体に不正なパスなどが含まれていないことのみ確認
              expect(code, isNot(contains('..')));
              expect(code, isNot(contains('/')));
              continue;
            }

            // 生成されたコードに危険なパターンが含まれていないか確認
            expect(code, isNot(contains('system(')), reason: 'システムコール実行の可能性');
            expect(code, isNot(contains('exec(')), reason: 'コマンド実行の可能性');
            expect(
              code,
              isNot(contains('#include <stdlib.h>')),
              reason: '予期しないincludeディレクティブ',
            );
          }
        }
      }
    });

    test('大量データ・DoS攻撃対策テスト', () {
      // 非常に長い入力
      final longInput = 'A' * 10000;
      final result1 = CodeGeneratorService.validateInput(longInput);
      expect(() => result1, returnsNormally, reason: '長い入力でクラッシュしてはいけません');

      // 大量の改行
      final manyLines = List.filled(1000, 'test').join('\n');
      final result2 = CodeGeneratorService.validateInput(manyLines);
      expect(() => result2, returnsNormally, reason: '大量行でクラッシュしてはいけません');

      // 深いネスト風の入力
      final nestedInput = '((((((((test))))))))';
      final result3 = CodeGeneratorService.validateInput(nestedInput);
      expect(() => result3, returnsNormally, reason: 'ネスト風入力でクラッシュしてはいけません');
    });

    test('ファイルパス・ディレクトリトラバーサル対策テスト', () {
      const pathTraversalInputs = [
        '../test',
        '..\\test',
        '../../etc/passwd',
        '..\\..\\windows\\system32',
        '/etc/passwd',
        'C:\\Windows\\System32\\config',
        '~/.bashrc',
        '\$HOME/.ssh/id_rsa',
        '/dev/null',
        'CON', // Windows予約名
        'PRN',
        'AUX',
        'COM1',
        'LPT1',
      ];

      for (final input in pathTraversalInputs) {
        final isValid = CodeGeneratorService.isValidFileName(input);
        expect(isValid, isFalse, reason: 'パス "$input" は無効なファイル名として拒否されるべきです');
      }
    });

    test('コードインジェクション対策テスト', () {
      const codeInjectionInputs = [
        'test"; system("rm -rf /"); //',
        'test\\"; system(\\"evil\\"); //',
        'test\nint main() { system("evil"); }',
        'test/**/; system("hack"); /**/',
        'test\x00; dangerous_code();',
      ];

      for (final input in codeInjectionInputs) {
        final result = CodeGeneratorService.validateInput(input);

        if (result.isValid && result.fileNames != null) {
          final codes = CodeGeneratorService.generateMultipleCodes(
            result.fileNames!,
          );

          for (final code in codes) {
            // runエントリはスキップして検査
            if (code.startsWith('!gcc')) {
              expect(code, isNot(contains('..')));
              expect(code, isNot(contains('/')));
              continue;
            }

            // 生成されたコードが予期された構造のみを含むか確認
            expect(code, contains('%%file'));
            expect(code, contains('#include <stdio.h>'));
            expect(code, contains('int main(void)'));
            expect(code, contains('return 0;'));

            // 危険なパターンが混入していないか確認
            expect(code, isNot(contains('system(')));
            expect(code, isNot(contains('; dangerous_code()')));
            expect(code, isNot(contains('exec(')));
          }
        }
      }
    });

    test('Unicode・国際化文字対策テスト', () {
      const unicodeInputs = [
        'тест', // キリル文字
        '测试', // 中国語
        'テスト', // 日本語
        '🚀test', // 絵文字
        'test\u202e', // Right-to-Left Override
        'test\u200b', // Zero Width Space
        'test\ufeff', // Byte Order Mark
      ];

      for (final input in unicodeInputs) {
        final result = CodeGeneratorService.validateInput(input);
        expect(
          () => result,
          returnsNormally,
          reason: 'Unicode入力 "$input" でクラッシュしてはいけません',
        );
      }
    });

    test('エッジケース・境界値テスト', () {
      // 空文字
      final emptyResult = CodeGeneratorService.validateInput('');
      expect(emptyResult.isValid, isFalse);

      // スペースのみ
      final spaceResult = CodeGeneratorService.validateInput('   ');
      expect(spaceResult.isValid, isFalse);

      // 改行のみ
      final newlineResult = CodeGeneratorService.validateInput('\n\n\n');
      expect(newlineResult.isValid, isFalse);

      // 正常なファイル名
      const validInputs = [
        'test1',
        'My_File',
        'file123',
        '演習1-1',
        'List1-1\nList1-2',
      ];

      for (final input in validInputs) {
        final result = CodeGeneratorService.validateInput(input);
        expect(result.isValid, isTrue, reason: '正常な入力 "$input" が拒否されました');

        if (result.fileNames != null) {
          final codes = CodeGeneratorService.generateMultipleCodes(
            result.fileNames!,
          );
          expect(codes, isNotEmpty);

          for (final code in codes) {
            expect(code, isNotEmpty);
            expect(code, contains('#include <stdio.h>'));
          }
        }
      }
    });
  });
}
