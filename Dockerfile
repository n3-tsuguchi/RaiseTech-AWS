# --- ステージ1: ビルドステージ ---
# アプリケーションをビルドするための環境
# GradleとJDK 17を含むイメージをベースにします
FROM gradle:8.5-jdk17-focal AS build

# 作業ディレクトリを設定
WORKDIR /home/gradle/project

# 最初にビルド設定ファイルをコピーして、依存関係をダウンロードします
# これにより、ソースコードの変更時にも依存関係のレイヤーはキャッシュが利用され、ビルドが高速になります
COPY build.gradle settings.gradle ./

# Gradleの依存関係を解決
RUN gradle build --no-daemon || return 0

# アプリケーションのソースコードをコピー
COPY src ./src

# アプリケーションをビルドして実行可能なJARファイルを作成します
# bootJarタスクは、Spring Bootアプリケーションを実行可能な単一のJARにパッケージングします
RUN gradle bootJar --no-daemon


# --- ステージ2: 実行ステージ ---
# ビルドされたアプリケーションを実行するための環境
# JREのみを含む、より軽量なイメージをベースにします
FROM openjdk:17-jre-slim

# 作業ディレクトリを設定
WORKDIR /app

# ビルドステージから生成されたJARファイルをコピーします
# ワイルドカード(*)を使って、バージョン番号が変動しても対応できるようにします
COPY --from=build /home/gradle/project/build/libs/*.jar app.jar

# アプリケーションがリッスンするポートを公開
EXPOSE 8080

# コンテナ起動時にアプリケーションを実行するコマンド
ENTRYPOINT ["java", "-jar", "app.jar"]
