# -----------------------------------------------------------------
# Dockerfile: Spring Bootアプリケーションをコンテナイメージ化する
# -----------------------------------------------------------------
# Multi-stage build を利用して、最終的なイメージサイズを小さく保ちます。

# --- ビルドステージ ---
# JDKが含まれるイメージをベースに、アプリケーションをビルドします。
FROM eclipse-temurin:21-jdk-jammy as builder

# 作業ディレクトリを設定
WORKDIR /workspace

# Gradleのビルド定義ファイルとラッパーを先にコピー
COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .

# gradlewに実行権限を付与
RUN chmod +x ./gradlew

# これにより、ソースコードの変更だけでは再ダウンロードが走らなくなり、ビルドが高速化します。
RUN ./gradlew dependencies

# アプリケーションのソースコードをコピー
COPY src src

# テストはスキップして時間短縮
RUN ./gradlew build -x test


# --- 実行ステージ ---
# JRE（Java実行環境）のみが含まれる、より軽量なイメージをベースにします。
FROM eclipse-temurin:21-jre-jammy

# アプリケーションのポート番号
EXPOSE 8080

# ビルドステージから、ビルド済みの.jarファイルのみをコピー
# ファイル名を app.jar に統一することで、実行コマンドを固定化できます。
COPY --from=builder /workspace/build/libs/*.jar app.jar

# コンテナ起動時にアプリケーションを実行するコマンド
ENTRYPOINT ["java", "-jar", "/app.jar"]
