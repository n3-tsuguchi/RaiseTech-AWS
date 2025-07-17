# -----------------------------------------------------------------
# Dockerfile: Spring Bootアプリケーションをコンテナイメージ化する
# -----------------------------------------------------------------
# Multi-stage build を利用して、最終的なイメージサイズを小さく保ちます。

# --- ビルドステージ ---
# ★★★ 変更点: Gradle公式の専用イメージを使用 ★★★
# これまでの環境依存の問題を根本的に解決するため、
# Gradleの実行に最適化された公式イメージに切り替えます。
FROM gradle:8.5.0-jdk17 AS builder

# 作業ディレクトリを設定
WORKDIR /workspace

# Gradleのビルド定義ファイルのみをコピー
# (gradlew と gradle/ ディレクトリは不要になります)
COPY build.gradle .
COPY settings.gradle .

# ソースコードをコピー
COPY src src

# Gradleのメモリ使用量を制限 (念のため維持)
ENV GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx512m"

# ★★★ 変更点: gradle コマンドでビルドを実行 ★★★
# プリインストールされたgradleを直接使用します。
# --info オプションで、より詳細なログを出力します。
RUN gradle build -x test --no-daemon --info --stacktrace

# ビルド後に build/libs ディレクトリの中身を確認します
RUN ls -l /workspace/build/libs


# --- 実行ステージ ---
# ★★★ 変更点: 実行イメージを軽量で安定した temurin に戻す ★★★
FROM eclipse-temurin:17-jre-jammy

# アプリケーションのポート番号
EXPOSE 8080

# ビルドステージから、ビルド済みの.jarファイルのみをコピー
COPY --from=builder /workspace/build/libs/*.jar app.jar

# コンテナ起動時にアプリケーションを実行するコマンド
ENTRYPOINT ["java", "-jar", "/app.jar"]
