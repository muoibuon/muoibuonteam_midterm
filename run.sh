#!/usr/bin/env bash
set -euo pipefail

PROJECT="B2BInvoiceApp.xcodeproj"
SCHEME="B2BInvoiceApp"
CONFIGURATION="Debug"
SDK="macosx"
DERIVED_DATA=".derivedData"
APP_PATH="$DERIVED_DATA/Build/Products/$CONFIGURATION/$SCHEME.app"
EXECUTABLE_PATH="$APP_PATH/Contents/MacOS/$SCHEME"
SAVED_STATE_DIR="$HOME/Library/Saved Application State/com.muoi.B2BInvoiceApp.savedState"

if [[ ! -d "$PROJECT" ]]; then
  echo "Project not found: $PROJECT"
  exit 1
fi

echo "Building $SCHEME..."
rm -rf "$SAVED_STATE_DIR"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -sdk "$SDK" \
  -derivedDataPath "$DERIVED_DATA" \
  build CODE_SIGNING_ALLOWED=NO ENABLE_DEBUG_DYLIB=NO

if [[ ! -d "$APP_PATH" ]]; then
  echo "Build completed but app not found at: $APP_PATH"
  exit 1
fi

if [[ ! -x "$EXECUTABLE_PATH" ]]; then
  echo "Build completed but executable not found at: $EXECUTABLE_PATH"
  exit 1
fi

echo "Launching $SCHEME..."
pkill -x "$SCHEME" >/dev/null 2>&1 || true
open -n "$APP_PATH" --args -ApplePersistenceIgnoreState YES
