#!/bin/bash

echo
echo "--------------------------------------"
echo "          AOSP 14.0 Buildbot          "
echo "                  by                  "
echo "                ponces                "
echo "        edited by MrFluffyOven        "
echo "--------------------------------------"
echo

set -e

BL=$PWD/treble_aosp
BD=$HOME/builds

initRepos() {
    if [ ! -d .repo ]; then
        echo "--> Initializing workspace"
        repo init -u https://android.googlesource.com/platform/manifest -b android-14.0.0_r21 --git-lfs
        echo

        echo "--> Preparing local manifest"
        mkdir -p .repo
        git clone https://github.com/MrFluffyOven/treble_manifest.git -b arrowgapps .repo/local_manifests
        echo
    fi
}

syncRepos() {
    echo "--> Syncing repos"
    repo sync -c --force-sync --no-clone-bundle --no-tags -j6
    echo
}

applyPatches() {
    echo "--> Applying TrebleDroid patches"
    bash $BL/patch.sh $BL trebledroid
    echo

    echo "--> Applying ponces patches"
    bash $BL/patch.sh $BL ponces
    echo

    echo "--> Generating makefiles"
    cd device/phh/treble
    cp $BL/aosp.mk .
    bash generate.sh aosp
    cd ../../..
    echo
}

setupEnv() {
    echo "--> Setting up build environment"
    source build/envsetup.sh &>/dev/null
    mkdir -p $BD
    echo
}

buildTrebleApp() {
    echo "--> Building treble_app"
    cd treble_app
    bash build.sh release
    cp TrebleApp.apk ../vendor/hardware_overlay/TrebleApp/app.apk
    cd ..
    echo
}

buildVanillaVariant() {
    echo "--> Building treble_arm64_bvN"
    lunch treble_arm64_bvN-userdebug
    make -j4 installclean
    make -j4 systemimage
    mv $OUT/system.img $BD/system-treble_arm64_bvN.img
    echo
}

buildGappsVariant() {
    echo "--> Building treble_arm64_bgN"
    lunch treble_arm64_bgN-userdebug
    make -j4 installclean
    make -j4 systemimage
    mv $OUT/system.img $BD/system-treble_arm64_bgN.img
    echo
}

buildVndkliteVariants() {
    echo "--> Building treble_arm64_bvN-vndklite"
    cd treble_adapter
    sudo bash lite-adapter.sh 64 $BD/system-treble_arm64_bvN.img
    mv s.img $BD/system-treble_arm64_bvN-vndklite.img
    sudo rm -rf d tmp

    echo "--> Building treble_arm64_bgN-vndklite"
    sudo bash lite-adapter.sh 64 $BD/system-treble_arm64_bgN.img
    mv s.img $BD/system-treble_arm64_bgN-vndklite.img
    sudo rm -rf d tmp
    cd ..
    echo
}

generatePackages() {
    echo "--> Generating packages"
    buildDate="$(date +%Y%m%d)"
    xz -cv $BD/system-treble_arm64_bvN.img -T0 > $BD/aosp-arm64-ab-vanilla-14.0-$buildDate.img.xz
    xz -cv $BD/system-treble_arm64_bvN-vndklite.img -T0 > $BD/aosp-arm64-ab-vanilla-vndklite-14.0-$buildDate.img.xz
    xz -cv $BD/system-treble_arm64_bgN.img -T0 > $BD/aosp-arm64-ab-gapps-14.0-$buildDate.img.xz
    xz -cv $BD/system-treble_arm64_bgN-vndklite.img -T0 > $BD/aosp-arm64-ab-gapps-vndklite-14.0-$buildDate.img.xz
    rm -rf $BD/system-*.img
    echo
}

generateOta() {
    echo "--> Generating OTA file"
    version="$(date +v%Y.%m.%d)"
    buildDate="$(date +%Y%m%d)"
    timestamp="$START"
    json="{\"version\": \"$version\",\"date\": \"$timestamp\",\"variants\": ["
    find $BD/ -name "aosp-*-14.0-$buildDate.img.xz" | sort | {
        while read file; do
            filename="$(basename $file)"
            if [[ $filename == *"vanilla-vndklite"* ]]; then
                name="treble_arm64_bvN-vndklite"
            elif [[ $filename == *"gapps-vndklite"* ]]; then
                name="treble_arm64_bgN-vndklite"
            elif [[ $filename == *"vanilla"* ]]; then
                name="treble_arm64_bvN"
            else
                name="treble_arm64_bgN"
            fi
            size=$(wc -c $file | awk '{print $1}')
            url="https://github.com/MrFluffyOven/treble_aosp/releases/download/$version/$filename"
            json="${json} {\"name\": \"$name\",\"size\": \"$size\",\"url\": \"$url\"},"
        done
        json="${json%?}]}"
        echo "$json" | jq . > $BL/config/ota.json
    }
    echo
}

START=$(date +%s)

initRepos
syncRepos
applyPatches
setupEnv
buildTrebleApp
buildVanillaVariant
buildGappsVariant
buildVndkliteVariants
generatePackages
generateOta

END=$(date +%s)
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))

echo "--> Buildbot completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo
