#!/bin/bash -e

dist_dir=dist

for pkgbuild in packages/*/PKGBUILD; do
  echo "ビルド中: $pkgbuild"

  # PKGBUILDから情報を抽出
  pkgname=$(grep -Po '^pkgname=\K.*' "$pkgbuild")
  pkgver=$(grep -Po '^pkgver=\K.*' "$pkgbuild")
  pkgrel=$(grep -Po '^pkgrel=\K.*' "$pkgbuild")
  arch=$(grep -Po "^arch=\('\K[^']+" "$pkgbuild" | head -1)

  package_filename="${pkgname}-${pkgver}-${pkgrel}-${arch}.pkg.tar.zst"

  # タイムスタンプの比較
  pkg_dir=$(dirname "$pkgbuild")
  mkdir -p "$dist_dir"
  (
    cd "$pkg_dir" || { echo "ディレクトリ移動に失敗しました"; exit 1; }
    makepkg -sf --syncdeps --noconfirm --needed || { echo "makepkgに失敗しました"; exit 1; }
    cp ./"$package_filename" "../../$dist_dir/" || { echo "パッケージコピーに失敗しました"; exit 1; }
  )
  echo "パッケージ $package_filename をビルドしました"
done
