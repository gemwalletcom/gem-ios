#!/usr/bin/env bash

set -e

CURRENT_DIR=$(dirname `realpath $0`)
PROJ_PATH=${CURRENT_DIR}/../Gem.xcodeproj/project.pbxproj
STONE_DIR=${CURRENT_DIR}/../core/gemstone
PACKAGES_DIR=${CURRENT_DIR}/../Packages/Gemstone
BUILD_MODE=$1

read_deployment_target() {
    echo -n $(/usr/libexec/PlistBuddy -c "Print" "$PROJ_PATH" | grep IPHONEOS_DEPLOYMENT_TARGET | awk -F ' = ' '{print $2}' | uniq)
}

generate() {
    if [ -z $BUILD_MODE ]; then
        echo "Build Gemstone debug"
    else
        echo "Build Gemstone $BUILD_MODE"
    fi

    pushd ${STONE_DIR} > /dev/null
    BUILD_MODE=$BUILD_MODE IPHONEOS_DEPLOYMENT_TARGET=$(read_deployment_target) just build-ios
    rm -rf ${PACKAGES_DIR}
    cp -Rf target/spm ${PACKAGES_DIR}

    popd /dev/null
}

generate
