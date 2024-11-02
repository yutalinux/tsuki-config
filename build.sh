cd packages

# 各サブディレクトリに対して処理を実行
for dir in */; do
  if [ -d "$dir" ]; then
    echo "Processing package in $dir"
    cd "$dir"

    if [ -f "PKGBUILD" ]; then
      echo "Building package in $dir"
      makepkg -sf --syncdeps --noconfirm

      if [ $? -ne 0 ]; then
        echo "Error building package in $dir"
      else
        echo "Successfully built package in $dir"
      fi
    else
      echo "No PKGBUILD found in $dir"
    fi

    cd ..
  fi
done

echo "All packages processed"

cd ..

mkdir -p dist
find packages -name "*.pkg.tar.zst" -exec cp {} dist/ \;
repo-add dist/tsuki.db.tar.gz dist/*.pkg.tar.zst
