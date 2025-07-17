# -----------------------------------------------------------------
# Dockerfile: Spring Bootアプリケーションをコンテナイメージ化する
# -----------------------------------------------------------------
# Multi-stage build を利用して、最終的なイメージサイズを小さく保ちます。

# --- ビルドステージ ---
# ベースイメージとして Amazon Corretto を使用します。
FROM amazoncorretto:17-al2-jdk AS builder

# 作業ディレクトリを設定
WORKDIR /workspace

# Gradleのビルド定義ファイルとラッパーを先にコピー
COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .

# ソースコードをコピー
COPY src src

# gradlewに実行権限を付与
RUN chmod +x ./gradlew

# Gradleのメモリ使用量を制限
ENV GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx512m"

# 依存関係の解決とビルドを一つのステップにまとめます。
RUN ./gradlew build -x test --no-daemon --stacktrace

# ビルド後に build/libs ディレクトリの中身を確認します
RUN ls -l /workspace/build/libs


# --- 実行ステージ ---
# ★★★ 変更点: 実行ステージのイメージをビルドステージと統一 ★★★
# これにより "image not found" エラーを解決し、環境の一貫性を保ちます。
FROM amazoncorretto:17-al2-jdk

# アプリケーションのポート番号
EXPOSE 8080

# ビルドステージから、ビルド済みの.jarファイルのみをコピー
COPY --from=builder /workspace/build/libs/*.jar app.jar

# コンテナ起動時にアプリケーションを実行するコマンド
ENTRYPOINT ["java", "-jar", "/app.jar"]
