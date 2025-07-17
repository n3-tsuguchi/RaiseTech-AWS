# -----------------------------------------------------------------
# Dockerfile: Spring Bootアプリケーションをコンテナイメージ化する
# -----------------------------------------------------------------
# Multi-stage build を利用して、最終的なイメージサイズを小さく保ちます。

# --- ビルドステージ ---
# JDKが含まれるイメージをベースに、アプリケーションをビルドします。
FROM eclipse-temurin:17-jdk-jammy AS builder

# 作業ディレクトリを設定
WORKDIR /workspace

# Gradleのビルド定義ファイルとラッパーを先にコピー
COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .

# gradlewに実行権限を付与
RUN chmod +x ./gradlew

# ★★★ 変更点: 'dependencies' の代わりに 'classes' タスクを使用して依存関係を解決 ★★★
# これにより、CI環境での安定性が向上することがあります。
RUN ./gradlew classes --no-daemon --stacktrace

# アプリケーションのソースコードをコピー
COPY src src

# アプリケーションをビルド
# (テストはスキップし、デーモンは使用しない)
RUN ./gradlew build -x test --no-daemon --stacktrace

# ビルド後に build/libs ディレクトリの中身を確認します
RUN ls -l /workspace/build/libs


# --- 実行ステージ ---
# JRE（Java実行環境）のみが含まれる、より軽量なイメージをベースにします。
FROM eclipse-temurin:17-jre-jammy

# アプリケーションのポート番号
EXPOSE 8080

# ビルドステージから、ビルド済みの.jarファイルのみをコピー
# ファイル名を app.jar に統一することで、実行コマンドを固定化できます。
COPY --from=builder /workspace/build/libs/*.jar app.jar

# コンテナ起動時にアプリケーションを実行するコマンド
ENTRYPOINT ["java", "-jar", "/app.jar"]
