import 'package:flutter_test/flutter_test.dart';
import 'package:prog_exc_gen_hinagata/services/code_generator_service.dart';

void main() {
  group('追加セキュリティテスト - 高度な攻撃パターン', () {
    test('バッファオーバーフロー風攻撃テスト', () {
      // 非常に長いファイル名
      final extremelyLongName = 'A' * 1000000; // 1MB

      expect(
        () {
          final result = CodeGeneratorService.validateInput(extremelyLongName);
          if (result.isValid && result.fileNames != null) {
            CodeGeneratorService.generateMultipleCodes(result.fileNames!);
          }
        },
        returnsNormally,
        reason: '極端に長い入力でクラッシュしてはいけません',
      );
    });

    test('メモリ消費攻撃テスト', () {
      // 大量のファイル名
      final manyFiles = List.generate(10000, (i) => 'file$i').join('\n');

      expect(
        () {
          final result = CodeGeneratorService.validateInput(manyFiles);
          if (result.isValid && result.fileNames != null) {
            // 生成されるファイル数を制限があるか確認
            expect(result.fileNames!.length, lessThanOrEqualTo(10000));
          }
        },
        returnsNormally,
        reason: '大量ファイル生成要求でクラッシュしてはいけません',
      );
    });

    test('正規表現DoS (ReDoS) 対策テスト', () {
      // 正規表現のバックトラッキングを悪用する可能性のあるパターン
      final redosPatterns = [
        'a' * 1000 + '!',
        '(a+)+b',
        '(a|a)*b',
        'a' * 100 + 'X',
      ];

      for (final pattern in redosPatterns) {
        final stopwatch = Stopwatch()..start();

        CodeGeneratorService.validateInput(pattern);
        CodeGeneratorService.isValidFileName(pattern);

        stopwatch.stop();

        // バリデーションが合理的な時間で完了することを確認（1秒未満）
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1000),
          reason: 'パターン "$pattern" の処理に時間がかかりすぎています',
        );
      }
    });

    test('エンコーディング攻撃テスト', () {
      const encodingAttacks = [
        'test\uFEFF', // BOM (Byte Order Mark)
        'test\u200B', // Zero Width Space
        'test\u202E', // Right-to-Left Override
        'test\u0085', // Next Line
        'test\u2028', // Line Separator
        'test\u2029', // Paragraph Separator
        '\uD83D\uDE00test', // Emoji
        'caf\u00E9', // アクセント付き文字
      ];

      for (final attack in encodingAttacks) {
        expect(
          () {
            final result = CodeGeneratorService.validateInput(attack);
            if (result.isValid && result.fileNames != null) {
              final codes = CodeGeneratorService.generateMultipleCodes(
                result.fileNames!,
              );
              for (final code in codes) {
                // 生成されたコードが標準的なC言語構文のみを含むことを確認
                expect(code, contains('%%file'));
                expect(code, contains('#include <stdio.h>'));
                expect(code, contains('int main(void)'));
                expect(code, contains('return 0;'));
              }
            }
          },
          returnsNormally,
          reason: 'エンコーディング攻撃 "$attack" でクラッシュしてはいけません',
        );
      }
    });

    test('プロトタイプ汚染風攻撃テスト', () {
      const prototypeAttacks = [
        '__proto__',
        'constructor',
        'prototype',
        'hasOwnProperty',
        'toString',
        'valueOf',
        'Object.prototype',
      ];

      for (final attack in prototypeAttacks) {
        final result = CodeGeneratorService.validateInput(attack);
        expect(
          () => result,
          returnsNormally,
          reason: 'プロトタイプ攻撃 "$attack" でクラッシュしてはいけません',
        );

        if (result.isValid && result.fileNames != null) {
          final codes = CodeGeneratorService.generateMultipleCodes(
            result.fileNames!,
          );
          for (final code in codes) {
            // 元の危険な名前がそのまま含まれていないことを確認
            // safe_プレフィックスが付いている場合は安全と判断
            if (code.contains(attack) && !code.contains('safe_$attack')) {
              fail('危険なプロパティ名 "$attack" がそのまま含まれています: $code');
            }
          }
        }
      }
    });

    test('タイミング攻撃対策テスト', () {
      const testInputs = [
        'valid_file',
        'invalid<>file',
        'another_valid',
        'CON',
        'normal123',
      ];

      final durations = <int>[];

      for (final input in testInputs) {
        final stopwatch = Stopwatch()..start();
        CodeGeneratorService.isValidFileName(input);
        stopwatch.stop();
        durations.add(stopwatch.elapsedMicroseconds);
      }

      // すべての実行時間が似たような範囲内であることを確認
      // （タイミング攻撃で内部状態を推測されないように）
      final maxDuration = durations.reduce((a, b) => a > b ? a : b);
      final minDuration = durations.reduce((a, b) => a < b ? a : b);

      // 最大と最小の差が合理的な範囲内であることを確認
      expect(
        maxDuration,
        lessThan(minDuration * 50),
        reason: 'バリデーション処理時間に大きな差があり、タイミング攻撃の可能性があります',
      );
    });

    test('リソース枯渇攻撃テスト', () {
      // 多重ネストした括弧
      final nestedBrackets = '(' * 1000 + 'test' + ')' * 1000;

      expect(
        () {
          CodeGeneratorService.validateInput(nestedBrackets);
        },
        returnsNormally,
        reason: 'ネストした括弧でスタックオーバーフローしてはいけません',
      );

      // 繰り返しパターン
      final repeatingPattern = 'AB' * 10000;

      expect(
        () {
          CodeGeneratorService.validateInput(repeatingPattern);
        },
        returnsNormally,
        reason: '繰り返しパターンで処理が止まってはいけません',
      );
    });

    test('データ完整性テスト', () {
      const inputs = ['test1', '演習1-1', 'My_File_123', 'project-final'];

      for (final input in inputs) {
        final result = CodeGeneratorService.validateInput(input);

        if (result.isValid && result.fileNames != null) {
          final originalFileNames = List<String>.from(result.fileNames!);
          final codes = CodeGeneratorService.generateMultipleCodes(
            result.fileNames!,
          );

          // 元のファイル名リストが変更されていないことを確認
          expect(
            result.fileNames,
            equals(originalFileNames),
            reason: 'ファイル名リストが予期せず変更されました',
          );

          // 生成されたコード数がファイル名数と一致することを確認
          expect(
            codes.length,
            equals(result.fileNames!.length),
            reason: '生成されたコード数がファイル名数と一致しません',
          );

          // 各コードが空でないことを確認
          for (int i = 0; i < codes.length; i++) {
            expect(codes[i], isNotEmpty, reason: 'インデックス $i のコードが空です');
          }
        }
      }
    });

    test('クロスサイトスクリプティング (XSS) 風攻撃テスト', () {
      final xssAttacks = [
        '<script>alert("xss")</script>',
        'javascript:alert(1)',
        'onload="alert(1)"',
        '"><img src=x onerror=alert(1)>',
        '\'"--></script><script>alert(1)</script>',
        '<svg onload=alert(1)>',
        r'${alert(1)}',
        r'${alert(1)}',
      ];

      for (final attack in xssAttacks) {
        final result = CodeGeneratorService.validateInput(attack);

        if (result.isValid && result.fileNames != null) {
          final codes = CodeGeneratorService.generateMultipleCodes(
            result.fileNames!,
          );

          for (final code in codes) {
            // HTMLタグや危険なパターンが除去されていることを確認
            expect(code, isNot(contains('<script')));
            expect(code, isNot(contains('javascript:')));
            expect(code, isNot(contains('onerror=')));
            expect(code, isNot(contains('onload=')));
            expect(code, isNot(contains('alert(')));
          }
        }
      }
    });
  });
}
