#!/bin/bash

dist_dir="dist"
repo_db="$dist_dir/tsuki.db.tar.gz"

build_packages() {
  for pkgbuild in packages/*/PKGBUILD; do
    echo "ビルド中: $pkgbuild"

    # PKGBUILDから情報を抽出
    pkgname=$(grep -Po '^pkgname=\K.*' "$pkgbuild")
    pkgver=$(grep -Po '^pkgver=\K.*' "$pkgbuild")
    pkgrel=$(grep -Po '^pkgrel=\K.*' "$pkgbuild")
    arch=$(grep -Po "^arch=\('\K[^']+" "$pkgbuild" | head -1)

    package_filename="${pkgname}-${pkgver}-${pkgrel}-${arch}.pkg.tar.zst"
    package_path="$dist_dir/$package_filename"

    # タイムスタンプの比較
    if [ ! -f "$package_path" ] || [ "$pkgbuild" -nt "$package_path" ]; then
      pkg_dir=$(dirname "$pkgbuild")
      mkdir -p "$dist_dir"
      (
        cd "$pkg_dir" || { echo "ディレクトリ移動に失敗しました"; exit 1; }
        makepkg -sf --syncdeps --noconfirm --needed || { echo "makepkgに失敗しました"; exit 1; }
        cp ./"$package_filename" "../../$dist_dir/" || { echo "パッケージコピーに失敗しました"; exit 1; }
      )
      echo "パッケージ $package_filename をビルドしました"
    else
      echo "パッケージ $package_filename は最新です。スキップします。"
    fi
  done
  echo "全てのパッケージのビルドが完了しました"
}

create_repo() {
  echo "リポジトリを作成しています"
  repo-add "$repo_db" "$dist_dir"/*.pkg.tar.zst || { echo "リポジトリ作成に失敗しました"; exit 1; }
}

clean_up() {
  echo "クリーンアップしています"
  rm -rf packages/*/pkg packages/*/*.pkg.tar.zst "$dist_dir"
}

case "$1" in
  clean)
    clean_up
    ;;
  build)
    build_packages
    create_repo
    ;;
  *)
    echo "使用法: $0 {build|clean}"
    exit 1
    ;;
esac

exit 0
