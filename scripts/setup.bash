#!/bin/bash

set -eo pipefail

echo "::group::🔍 Inspecting runner..."
echo "RUNNER_ENVIRONMENT: $RUNNER_ENVIRONMENT"
echo "RUNNER_OS: $RUNNER_OS"
echo "RUNNER_ARCH: $RUNNER_ARCH"
echo "::endgroup::"

INSTALL_PATH=

function download() {
    echo "::group::⬇️ Downloading..."
    local url err fail=false
    for url in "${URLS[@]}"; do
        err=$(curl -sSfLO "$url" 2>&1) && echo "✅ $url" && continue
        printf "❌ %s\n%s\n" "$url" "$err"
        fail=true
    done
    echo "::endgroup::"
    if $fail; then
        echo "::error::Failed to download!"
        exit 1
    fi
}

function extract() {
    echo "::group::📦 Extracting..."
    local file err fail=false
    for file in instantclient-*.zip; do
        err=$(unzip -qo "$file" 2>&1) && echo "✅ $file" && continue
        printf "❌ %s\n%s\n" "$file" "$err"
        fail=true
    done
    echo "::endgroup::"
    if $fail; then
        echo "::error::Failed to extract!"
        exit 1
    fi
    rm -f ./*.zip
    INSTALL_PATH="$(realpath ./instantclient_*)"
}

function install() {
    echo "::group::📦 Installing..."
    local file err fail=false
    for file in instantclient-*.dmg; do
        err=$({
            hdiutil mount -quiet "$file" &&
                cd /Volumes/instantclient-* &&
                ./install_ic.sh >/dev/null &&
                hdiutil unmount -force -quiet /Volumes/instantclient-*
        } 2>&1) && echo "✅ $file" && continue
        printf "❌ %s\n%s\n" "$file" "$err"
        fail=true
    done
    echo "::endgroup::"
    if $fail; then
        echo "::error::Failed to install!"
        exit 1
    fi
    rm -f ./*.dmg
    INSTALL_PATH="$(realpath /Users/"$USER"/Downloads/instantclient_*)"
}

if [[ $RUNNER_OS == "Linux" ]]; then
    if [[ -f /usr/lib/x86_64-linux-gnu/libaio.so.1t64 ]]; then
        sudo ln -sr /usr/lib/x86_64-linux-gnu/libaio.so.1t64 /usr/lib/x86_64-linux-gnu/libaio.so.1
    fi
    URLS=()
    if [[ $RUNNER_ARCH == "X86" ]]; then
        URLS=(
            https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linux.zip
            https://download.oracle.com/otn_software/linux/instantclient/instantclient-sqlplus-linux.zip
        )
    elif [[ $RUNNER_ARCH == "X64" ]]; then
        URLS=(
            https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linuxx64.zip
            https://download.oracle.com/otn_software/linux/instantclient/instantclient-sqlplus-linuxx64.zip
        )
    elif [[ $RUNNER_ARCH == "ARM64" ]]; then
        URLS=(
            https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linux-arm64.zip
            https://download.oracle.com/otn_software/linux/instantclient/instantclient-sqlplus-linux-arm64.zip
        )
    else
        echo "::error::Unsupported architecture!"
        exit 1
    fi

    cd "$RUNNER_TEMP" && download && extract

    echo "::notice::Running ldconfig..."
    echo "$INSTALL_PATH" | sudo tee /etc/ld.so.conf.d/oracle-instantclient.conf >/dev/null
    sudo ldconfig
elif [[ $RUNNER_OS == "macOS" ]]; then
    URLS=()
    if [[ $RUNNER_ARCH == "X86" || $RUNNER_ARCH == "X64" ]]; then
        URLS=(
            https://download.oracle.com/otn_software/mac/instantclient/instantclient-basic-macos.dmg
            https://download.oracle.com/otn_software/mac/instantclient/instantclient-sqlplus-macos.dmg
        )
    elif [[ $RUNNER_ARCH == "ARM64" ]]; then
        URLS=(
            https://download.oracle.com/otn_software/mac/instantclient/instantclient-basic-macos-arm64.dmg
            https://download.oracle.com/otn_software/mac/instantclient/instantclient-sqlplus-macos-arm64.dmg
        )
    else
        echo "::error::Unsupported architecture!"
        exit 1
    fi

    cd "$RUNNER_TEMP" && download && install
elif [[ $RUNNER_OS == "Windows" ]]; then
    URLS=()
    if [[ $RUNNER_ARCH == "X86" ]]; then
        URLS=(
            https://download.oracle.com/otn_software/nt/instantclient/instantclient-basic-nt.zip
            https://download.oracle.com/otn_software/nt/instantclient/instantclient-sqlplus-nt.zip
        )
    elif [[ $RUNNER_ARCH == "X64" ]]; then
        URLS=(
            https://download.oracle.com/otn_software/nt/instantclient/instantclient-basic-windows.zip
            https://download.oracle.com/otn_software/nt/instantclient/instantclient-sqlplus-windows.zip
        )
    else
        echo "::error::Unsupported architecture!"
        exit 1
    fi

    cd "$RUNNER_TEMP" && download && extract
else
    echo "::error::Unsupported OS!"
    exit 1
fi

echo "::notice::Adding '$INSTALL_PATH' to PATH"
echo "$INSTALL_PATH" >>"$GITHUB_PATH"

echo "::notice::Setting 'install-path' output parameter"
echo "install-path=$INSTALL_PATH" >>"$GITHUB_OUTPUT"

echo "::notice::Installed successfully!"
