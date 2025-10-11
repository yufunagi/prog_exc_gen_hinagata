# プログラム雛形生成アプリケーション

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

C言語プログラミングの授業で使用する、プログラム雛形を自動生成するFlutterアプリケーションです。  
ファイル名を入力するだけで、Google Colabで動作する標準的なC言語のプログラムテンプレートを即座に生成できます。

## ✨ 特徴

- **簡単入力**: ファイル名を改行区切りで入力するだけ
- **自動生成**: C言語の標準的なプログラム雛形を自動生成
- **複数ファイル対応**: 一度に複数のファイルテンプレートを生成
- **ナビゲーション**: 生成されたコード間を簡単に移動
- **クリップボード対応**: 生成したコードをワンクリックでコピー
- **クロスプラットフォーム**: Web、モバイル、デスクトップに対応

## 🚀 クイックスタート

### 必要条件

- Flutter SDK (3.9.2 以上)
- Dart SDK (3.9.2 以上)

### インストール

1. リポジトリをクローン
```bash
git clone https://github.com/your-username/prog_exc_gen_hinagata.git
cd prog_exc_gen_hinagata
```

2. 依存関係をインストール
```bash
flutter pub get
```

3. アプリケーションを起動
```bash
# Web版
flutter run -d chrome

# モバイル版 (iOS/Android)
flutter run

# デスクトップ版 (Windows/macOS/Linux)
flutter run -d windows  # または macos/linux
```

## 📖 使用方法

### 基本的な使い方

1. **ファイル名入力**: テキストフィールドに生成したいファイル名を入力
   - 複数ファイルの場合は改行で区切って入力
   - 例:
     ```
     List5-2
     List5-3
     List5-5
     ```

2. **コード生成**: 「コード生成」ボタンをクリック

3. **コード確認**: 生成されたC言語のプログラム雛形が表示されます
   ```c
   %%file List5-2.c
   #include <stdio.h>
   int main(void)
   {
       return 0;
   }
   ```

4. **コードコピー**: 「コピー」ボタンでクリップボードにコピー

5. **ナビゲーション**: 「次へ」「前へ」ボタンで他のファイルのテンプレートを表示

### 入力例

```
hello
world
test_program
```

これで以下の3つのファイルテンプレートが生成されます：
- `hello.c`
- `world.c` 
- `test_program.c`

## 🛠️ 技術スタック

- **Framework**: Flutter 3.9.2
- **Language**: Dart 3.9.2
- **UI**: Material Design 3
- **State Management**: StatefulWidget
- **Clipboard**: flutter/services.dart

## 📁 プロジェクト構造

```
lib/
├── main.dart          # メインアプリケーション
test/
├── widget_test.dart   # ウィジェットテスト
android/               # Android固有設定
ios/                   # iOS固有設定
web/                   # Web固有設定
windows/               # Windows固有設定
macos/                 # macOS固有設定
linux/                 # Linux固有設定
```

## 📝 ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

**Happy Coding! 🎉**