#!/usr/bin/env bash

# ==============================================================================
# CONFIGURATION VARIABLES
# ==============================================================================
# Target directory for releases (relative to project root)
DIST_DIR="dist"

# Android APK source folder (where Flutter outputs APKs)
APK_SRC_DIR="build/app/outputs/flutter-apk"

# Android App Bundle source file
BUNDLE_SRC="build/app/outputs/bundle/release/app-release.aab"

# Windows release source folder (where Flutter outputs Windows build)
WINDOWS_SRC_DIR="build/windows/x64/runner/Release"

# Linux release source folder (where Flutter outputs Linux build)
LINUX_SRC_DIR="build/linux/x64/release/bundle"

# Target file prefixes/names for dist folder
APP_NAME="NutriScan"

# ==============================================================================
# FUNCTIONS
# ==============================================================================

# Show a nice help message
show_help() {
  echo -e "\033[1;36m========================================================\033[0m"
  echo -e "\033[1;32m             ${APP_NAME} Calorie Tracker Build Tool       \033[0m"
  echo -e "\033[1;36m========================================================\033[0m"
  echo -e "Usage: ./build.sh [arguments...]"
  echo -e ""
  echo -e "You can combine multiple arguments. They will execute in order"
  echo -e "except 'clean' which always runs first."
  echo -e ""
  echo -e "\033[1;33mArguments:\033[0m"
  echo -e "  \033[1;32mclean\033[0m       - Clean Flutter build cache and clear dist/ (always runs first)"
  echo -e "  \033[1;32mapk\033[0m         - Build universal Android APK"
  echo -e "  \033[1;32mapks\033[0m        - Build Android APKs split per ABI (apk-split also accepted)"
  echo -e "  \033[1;32mapks1\033[0m       - Build Android arm64-v8a Split APK"
  echo -e "  \033[1;32mbundle\033[0m      - Build Android App Bundle (.aab)"
  echo -e "  \033[1;32mwindows\033[0m     - Build Windows Desktop release"
  echo -e "  \033[1;32mlinux\033[0m       - Build Linux Desktop release"
  echo -e "  \033[1;32mpackage\033[0m     - Package Windows/Linux build into a ZIP file with install script"
  echo -e "  \033[1;32mhelp\033[0m        - Show this help message"
  echo -e ""
  echo -e "\033[1;36m========================================================\033[0m"
}

create_zip() {
  local zip_name="$1"
  local folder_to_zip="$2"
  shift 2
  local extra_files=("$@")

  local stage_dir="$DIST_DIR/stage"
  rm -rf "$stage_dir"
  mkdir -p "$stage_dir/dist"

  # Copy compiled folder to stage/dist/
  cp -r "$folder_to_zip" "$stage_dir/dist/"

  # Copy extra files (installers) to stage/
  for f in "${extra_files[@]}"; do
    if [ -f "$f" ]; then
      cp "$f" "$stage_dir/"
      if [ "$(basename "$f")" = "install.ps1" ] && [ -n "$VERSION" ]; then
        sed -i "s/\$Version = '[^']*'/\$Version = '${VERSION}'/g" "$stage_dir/install.ps1"
      fi
    fi
  done

  # 1. Try standard 'zip' command
  if command -v zip >/dev/null 2>&1; then
    local abs_zip_path="$(pwd)/$zip_name"
    (cd "$stage_dir" && zip -r "$abs_zip_path" .)
    rm -rf "$stage_dir"
    return 0
  fi

  # 2. Try PowerShell on Windows (native)
  if command -v powershell.exe >/dev/null 2>&1; then
    echo "Using PowerShell to compress..."
    powershell.exe -NoProfile -Command "Compress-Archive -Path '${stage_dir}/*' -DestinationPath '${zip_name}' -Force"
    rm -rf "$stage_dir"
    return 0
  fi

  # 3. Try Tar on Linux/macOS (native, creates .tar.gz instead of .zip)
  if command -v tar >/dev/null 2>&1; then
    local tar_name="${zip_name%.zip}.tar.gz"
    echo "Using tar to compress to $tar_name..."
    local abs_tar_path="$(pwd)/$tar_name"
    (cd "$stage_dir" && tar -czf "$abs_tar_path" .)
    rm -rf "$stage_dir"
    return 0
  fi

  rm -rf "$stage_dir"
  echo -e "\033[1;31mError: No compression tool found ('zip', 'powershell.exe', or 'tar' not available).\033[0m"
  return 1
}

package_windows() {
  if [ -d "$DIST_DIR/${APP_NAME}-windows" ]; then
    echo -e "\033[1;32m>>> Packaging Windows Release...\033[0m"
    pkg_files=()
    [ -f "install.bat" ] && pkg_files+=("install.bat")
    [ -f "install.ps1" ] && pkg_files+=("install.ps1")
    
    zip_name="$DIST_DIR/${APP_NAME}${ZIP_SUFFIX}-windows.zip"
    rm -f "$zip_name"
    create_zip "$zip_name" "$DIST_DIR/${APP_NAME}-windows" "${pkg_files[@]}"
  else
    echo -e "\033[1;31mError: Windows build folder not found at '$DIST_DIR/${APP_NAME}-windows'.\033[0m"
    return 1
  fi
}

package_linux() {
  if [ -d "$DIST_DIR/${APP_NAME}-linux" ]; then
    echo -e "\033[1;32m>>> Packaging Linux Release...\033[0m"
    pkg_files=()
    [ -f "install.sh" ] && pkg_files+=("install.sh")
    
    zip_name="$DIST_DIR/${APP_NAME}${ZIP_SUFFIX}-linux.zip"
    rm -f "$zip_name"
    create_zip "$zip_name" "$DIST_DIR/${APP_NAME}-linux" "${pkg_files[@]}"
  else
    echo -e "\033[1;31mError: Linux build folder not found at '$DIST_DIR/${APP_NAME}-linux'.\033[0m"
    return 1
  fi
}

# ==============================================================================
# ARGUMENT PARSING
# ==============================================================================

if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

# Flags to track requested actions
RUN_CLEAN=false
RUN_APK=false
RUN_APK_SPLIT=false
RUN_APKS1=false
RUN_BUNDLE=false
RUN_WINDOWS=false
RUN_LINUX=false
PACKAGE=false
WINDOWS_PACKAGED=false
LINUX_PACKAGED=false

# Extract version from pubspec.yaml
VERSION=""
if [ -f "pubspec.yaml" ]; then
  VERSION=$(grep '^version: ' pubspec.yaml | sed 's/version: //g' | tr -d '\r')
fi

if [ -n "$VERSION" ]; then
  VERSION_SAFE=$(echo "$VERSION" | tr '+' '_')
  ZIP_SUFFIX="-v${VERSION_SAFE}"
  VER_STR=" (v${VERSION})"
else
  ZIP_SUFFIX=""
  VER_STR=""
fi

# Order of execution for non-clean tasks
declare -a TASKS=()

for arg in "$@"; do
  case "$arg" in
    clean)
      RUN_CLEAN=true
      ;;
    apk)
      RUN_APK=true
      TASKS+=("apk")
      ;;
    apks|apk-split)
      RUN_APK_SPLIT=true
      TASKS+=("apk-split")
      ;;
    apks1)
      RUN_APKS1=true
      TASKS+=("apks1")
      ;;
    bundle)
      RUN_BUNDLE=true
      TASKS+=("bundle")
      ;;
    windows)
      RUN_WINDOWS=true
      TASKS+=("windows")
      ;;
    linux)
      RUN_LINUX=true
      TASKS+=("linux")
      ;;
    package)
      PACKAGE=true
      ;;
    -h|--help|help)
      show_help
      exit 0
      ;;
    *)
      echo -e "\033[1;31mError: Unknown argument '$arg'\033[0m"
      show_help
      exit 1
      ;;
  esac
done

# ==============================================================================
# EXECUTION
# ==============================================================================

# 1. Clean always runs first if specified
if [ "$RUN_CLEAN" = true ]; then
  echo -e "\033[1;33m>>> Cleaning Flutter build cache...\033[0m"
  flutter clean
  
  if [ -d "$DIST_DIR" ]; then
    echo -e "\033[1;33m>>> Clearing dist folder ($DIST_DIR)...\033[0m"
    rm -rf "${DIST_DIR:?}"/*
  fi
fi

# Ensure dist directory exists
if [ ! -d "$DIST_DIR" ]; then
  echo -e "\033[1;32m>>> Creating dist directory...\033[0m"
  mkdir -p "$DIST_DIR"
fi

# 2. Run other tasks in the order they were parsed or requested
for task in "${TASKS[@]}"; do
  case "$task" in
    apk)
      echo -e "\033[1;32m>>> Building Android APK (Release)${VER_STR}...\033[0m"
      # Prevent copying older files: delete old build output first
      rm -f "$APK_SRC_DIR/app-release.apk"
      
      if flutter build apk --release; then
        if [ -f "$APK_SRC_DIR/app-release.apk" ]; then
          echo -e "\033[1;32m>>> Moving & renaming APK to dist/...\033[0m"
          cp "$APK_SRC_DIR/app-release.apk" "$DIST_DIR/${APP_NAME}${ZIP_SUFFIX}-release.apk"
          echo -e "\033[1;32m>>> Saved: $DIST_DIR/${APP_NAME}${ZIP_SUFFIX}-release.apk\033[0m"
        else
          echo -e "\033[1;31mError: APK output not found at $APK_SRC_DIR/app-release.apk\033[0m"
          exit 1
        fi
      else
        echo -e "\033[1;31mError: Flutter apk build failed. Aborting.\033[0m"
        exit 1
      fi
      ;;
      
    apk-split)
      echo -e "\033[1;32m>>> Building Android Split APKs (Release)${VER_STR}...\033[0m"
      # Prevent copying older files: delete old split APKs first
      rm -f "$APK_SRC_DIR"/app-*-release.apk
      
      if flutter build apk --release --split-per-abi; then
        echo -e "\033[1;32m>>> Processing and renaming split APKs...\033[0m"
        found_any=false
        for file in "$APK_SRC_DIR"/app-*-release.apk; do
          if [ -f "$file" ]; then
            filename=$(basename "$file")
            abi="${filename#app-}"
            abi="${abi%-release.apk}"
            
            target_name="${APP_NAME}${ZIP_SUFFIX}-${abi}-release.apk"
            echo -e "\033[1;32m>>> Moving & renaming $filename to $target_name\033[0m"
            cp "$file" "$DIST_DIR/$target_name"
            found_any=true
          fi
        done
        
        if [ "$found_any" = false ]; then
          echo -e "\033[1;31mError: Split APKs not found in $APK_SRC_DIR. Aborting.\033[0m"
          exit 1
        fi
      else
        echo -e "\033[1;31mError: Flutter split apk build failed. Aborting.\033[0m"
        exit 1
      fi
      ;;

    apks1)
      echo -e "\033[1;32m>>> Building Android arm64-v8a Split APK (Release)${VER_STR}...\033[0m"
      # Prevent copying older files: delete old split APKs first
      rm -f "$APK_SRC_DIR"/app-*-release.apk
      
      if flutter build apk --release --target-platform android-arm64 --split-per-abi; then
        echo -e "\033[1;32m>>> Processing and renaming split APKs...\033[0m"
        found_any=false
        for file in "$APK_SRC_DIR"/app-*-release.apk; do
          if [ -f "$file" ]; then
            filename=$(basename "$file")
            abi="${filename#app-}"
            abi="${abi%-release.apk}"
            
            target_name="${APP_NAME}${ZIP_SUFFIX}-${abi}-release.apk"
            echo -e "\033[1;32m>>> Moving & renaming $filename to $target_name\033[0m"
            cp "$file" "$DIST_DIR/$target_name"
            found_any=true
          fi
        done
        
        if [ "$found_any" = false ]; then
          echo -e "\033[1;31mError: Split APKs not found in $APK_SRC_DIR. Aborting.\033[0m"
          exit 1
        fi
      else
        echo -e "\033[1;31mError: Flutter split apk build failed. Aborting.\033[0m"
        exit 1
      fi
      ;;

    bundle)
      echo -e "\033[1;32m>>> Building Android App Bundle (Release)${VER_STR}...\033[0m"
      # Prevent copying older files: delete old bundle first
      rm -f "$BUNDLE_SRC"
      
      if flutter build appbundle --release; then
        if [ -f "$BUNDLE_SRC" ]; then
          echo -e "\033[1;32m>>> Moving & renaming App Bundle to dist/...\033[0m"
          cp "$BUNDLE_SRC" "$DIST_DIR/${APP_NAME}${ZIP_SUFFIX}-release.aab"
          echo -e "\033[1;32m>>> Saved: $DIST_DIR/${APP_NAME}${ZIP_SUFFIX}-release.aab\033[0m"
        else
          echo -e "\033[1;31mError: App Bundle output not found at $BUNDLE_SRC\033[0m"
          exit 1
        fi
      else
        echo -e "\033[1;31mError: Flutter appbundle build failed. Aborting.\033[0m"
        exit 1
      fi
      ;;
      
    windows)
      echo -e "\033[1;32m>>> Building Windows Release${VER_STR}...\033[0m"
      # Prevent copying older files: delete old windows build folder first
      rm -rf "$WINDOWS_SRC_DIR"
      
      if flutter build windows --release; then
        if [ -d "$WINDOWS_SRC_DIR" ]; then
          echo -e "\033[1;32m>>> Copying Windows release to $DIST_DIR/${APP_NAME}-windows...\033[0m"
          rm -rf "$DIST_DIR/${APP_NAME}-windows"
          mkdir -p "$DIST_DIR/${APP_NAME}-windows"
          
          # Copy release folder contents
          cp -r "$WINDOWS_SRC_DIR"/* "$DIST_DIR/${APP_NAME}-windows/"
          echo "$VERSION" > "$DIST_DIR/${APP_NAME}-windows/version.txt"
          echo -e "\033[1;32m>>> Saved Windows build to: $DIST_DIR/${APP_NAME}-windows/\033[0m"
          if [ "$PACKAGE" = true ]; then
            package_windows
            WINDOWS_PACKAGED=true
          fi
        else
          echo -e "\033[1;31mError: Windows build directory not found at $WINDOWS_SRC_DIR\033[0m"
          exit 1
        fi
      else
        echo -e "\033[1;31mError: Flutter windows build failed. Aborting.\033[0m"
        exit 1
      fi
      ;;
      
    linux)
      echo -e "\033[1;32m>>> Building Linux Release${VER_STR}...\033[0m"
      # Prevent copying older files: delete old linux build folder first
      rm -rf "$LINUX_SRC_DIR"
      
      if flutter build linux --release; then
        if [ -d "$LINUX_SRC_DIR" ]; then
          echo -e "\033[1;32m>>> Copying Linux release to $DIST_DIR/${APP_NAME}-linux...\033[0m"
          rm -rf "$DIST_DIR/${APP_NAME}-linux"
          mkdir -p "$DIST_DIR/${APP_NAME}-linux"
          
          # Copy release folder contents
          cp -r "$LINUX_SRC_DIR"/* "$DIST_DIR/${APP_NAME}-linux/"
          echo "$VERSION" > "$DIST_DIR/${APP_NAME}-linux/version.txt"
          echo -e "\033[1;32m>>> Saved Linux build to: $DIST_DIR/${APP_NAME}-linux/\033[0m"
          if [ "$PACKAGE" = true ]; then
            package_linux
            LINUX_PACKAGED=true
          fi
        else
          echo -e "\033[1;31mError: Linux build directory not found at $LINUX_SRC_DIR\033[0m"
          exit 1
        fi
      else
        echo -e "\033[1;31mError: Flutter linux build failed. Aborting.\033[0m"
        exit 1
      fi
      ;;
  esac
done

if [ "$PACKAGE" = true ]; then
  if [ "$WINDOWS_PACKAGED" != true ] && [ -d "$DIST_DIR/${APP_NAME}-windows" ]; then
    package_windows || exit 1
    WINDOWS_PACKAGED=true
  fi
  if [ "$LINUX_PACKAGED" != true ] && [ -d "$DIST_DIR/${APP_NAME}-linux" ]; then
    package_linux || exit 1
    LINUX_PACKAGED=true
  fi

  if [ "$WINDOWS_PACKAGED" != true ] && [ "$LINUX_PACKAGED" != true ]; then
    echo -e "\033[1;31mError: No existing Windows or Linux build found in '$DIST_DIR/' to package.\033[0m"
    exit 1
  fi
fi

echo -e "\033[1;32m>>> All requested builds completed successfully!\033[0m"
echo -e "\033[1;32m>>> Dist directory contents:\033[0m"
ls -lh "$DIST_DIR"
