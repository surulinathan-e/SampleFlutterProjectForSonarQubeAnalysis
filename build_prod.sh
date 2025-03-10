#!/bin/bash 
PATH_PROJECT=$(pwd)

# build apk
flutter clean
flutter pub get
flutter gen-l10n
flutter build apk --flavor prod -t lib/main_prod.dart --release
flutter build appbundle --flavor prod -t lib/main_prod.dart --target-platform android-arm,android-arm64,android-x64

# move file app-release.apk to root folder
cp "$PATH_PROJECT/build/app/outputs/flutter-apk/app-prod-release.apk" "$PATH_PROJECT/Task_O prod $(date '+%Y-%m-%d %H-%M-%S').apk"
# move file app-release.aab to root folder
cp "$PATH_PROJECT/build/app/outputs/bundle/prodRelease/app-prod-release.aab" "$PATH_PROJECT/Task_O prod $(date '+%Y-%m-%d %H-%M-%S').aab"