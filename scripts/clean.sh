#!/bin/bash -e

echo "クリーンアップしています"
rm -rf packages/*/pkg packages/*/src packages/*/*.pkg.tar.zst "dist"
