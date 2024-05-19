#!/bin/bash
#
# Script build GKI and upload it to Telegram
# Copyright (c) 2024 Fiqri Aryansyah <fiqri191002@gmail.com>
#

SECONDS=0 # builtin bash timer

KERN_DIR=$PWD/common
IMG_DIR=$PWD/out/android12-5.10/dist

git clone https://github.com/fabianonline/telegram.sh.git --depth=1 telegram
export TELEGRAM_DIR="$PWD/telegram/telegram"

tg_post_msg() {
    "${TELEGRAM_DIR}" -H -D \
        "$(
            for POST in "${@}"; do
                echo "${POST}"
            done
        )"
}

tg_post_build() {
    "${TELEGRAM_DIR}" -H \
        -f "$1" \
        "$2"
}

# Get distro name
DISTRO=$(source /etc/os-release && echo ${NAME})

# Check kernel version
KERVER=$(MAKEFLAGS="--no-print-directory" make -C "$KERN_DIR" kernelversion)

# Get date and time
DATE=$(TZ=Asia/Jakarta date)
ZIP_DATE=$(date '+%Y%m%d-%H%M')

# Get last commit
COMMIT_HEAD=$(git -C "$KERN_DIR" log --oneline -1)

echo -e "Kernel compilation starting"

tg_post_msg "<b>Docker OS: </b><code>$DISTRO</code>" \
            "<b>Kernel Version : </b><code>$KERVER</code>" \
            "<b>Date : </b><code>$DATE</code>" \
            "<b>Device : </b><code>Poco F5 (marble)</code>" \
            "<b>Last Commit : </b><code>$COMMIT_HEAD</code>"

LTO=thin BUILD_CONFIG=common/build.config.gki.aarch64 build/build.sh

if [ -f "$IMG_DIR"/Image ]; then
    echo -e "Kernel compilation successful, wait a moment..."
else
    echo -e "Kernel compilation failed"
    tg_post_msg "<b>Failed to compile after $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s)</b>"
    exit 1
fi

ZIPNAME=GKI-custom-marble-"$ZIP_DATE"
FIXED_ZIPNAME="$ZIPNAME.zip"

cp "$IMG_DIR"/Image AnyKernel3
cd AnyKernel3
zip "../$FIXED_ZIPNAME" * -x .git README.md
cd ..
tg_post_build "$FIXED_ZIPNAME" "<b>Build took : $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s)</b>"
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s)"
