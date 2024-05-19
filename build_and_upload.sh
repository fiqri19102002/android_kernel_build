#!/bin/bash

SECONDS=0

KERN_DIR=$PWD/msm-5.10-marble
IMG_DIR=$PWD/out/msm-5.10/dist

git clone --depth=1 https://github.com/fabianonline/telegram.sh.git telegram
export TELEGRAM_DIR=$PWD/telegram/telegram
export TELEGRAM_CHAT="-1002143823461"

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
KERVER=$(make -C "$KERN_DIR" kernelversion)

# Get date and time
DATE=$(date '+%Y%m%d-%H%M')

# Get branch name
BRANCH=$(git -C "$KERN_DIR" rev-parse --abbrev-ref HEAD)

# Get last commit
COMMIT_HEAD=$(git -C "$KERN_DIR" log --oneline -1)

echo -e "Kernel compilation starting"

export BUILD_CONFIG="$KERN_DIR"/build.config.msm.marble

tg_post_msg "<b>Docker OS: </b><code>$DISTRO</code>" \
            "<b>Kernel Version : </b><code>$KERVER</code>" \
            "<b>Date : </b><code>$DATE</code>" \
            "<b>Device : </b><code>Poco F5 (marble)</code>" \
            "<b>Branch : </b><code>$BRANCH</code>" \
            "<b>Last Commit : </b><code>$COMMIT_HEAD</code>"

ZIPNAME=STRIX-marble-"$DATE"
FIXED_ZIPNAME="$ZIPNAME.zip"

cp "$IMG_DIR"/Image AnyKernel3
cd AnyKernel3
zip "../$FIXED_ZIPNAME" * -x .git README.md
cd ..
tg_post_build "$FIXED_ZIPNAME" "<b>Build took : $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s)</b>"
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s)"

