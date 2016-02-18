#!/bin/bash

git clone "$TAP_REPO_URL" "$TAP_DIR"
cd "$TAP_DIR"
sed "s/version \"[\.0-9]*\"/version \"${VERSION}\"/g" Formula/swift-express.rb > tmp && mv -f tmp Formula/swift-express.rb
git add Formula/swift-express.rb
git commit -m "Updated swift-express version to ${VERSION}"
git pull
# git push
cd $OLD_PWD
rm -rf "$TAP_DIR"
echo build done