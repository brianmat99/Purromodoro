#!/bin/bash -e
ASSETS_PATH=../TomatoBar/Assets.xcassets
APPICON_SRC=cat_app_icon.png
APPICON_ICONSET=${ASSETS_PATH}/AppIcon.appiconset

BARICON_SRC_IDLE=cat_idle_transparent.png
BARICON_SRC_WORK=cat_work_transparent.png
BARICON_SRC_SHORT_REST=cat_short_rest_transparent.png
BARICON_SRC_LONG_REST=cat_long_rest_transparent.png
BARICON_ICONSET_IDLE=${ASSETS_PATH}/BarIconIdle.imageset
BARICON_ICONSET_WORK=${ASSETS_PATH}/BarIconWork.imageset
BARICON_ICONSET_SHORT_REST=${ASSETS_PATH}/BarIconShortRest.imageset
BARICON_ICONSET_LONG_REST=${ASSETS_PATH}/BarIconLongRest.imageset

MAGICK="magick -verbose -background none +repage"

if [ "$1" == "appicon" ]; then
    ${MAGICK} ${APPICON_SRC} -resize '!16x16' ${APPICON_ICONSET}/icon_16x16.png
    ${MAGICK} ${APPICON_SRC} -resize '!32x32' ${APPICON_ICONSET}/icon_16x16@2x.png
    ${MAGICK} ${APPICON_SRC} -resize '!32x32' ${APPICON_ICONSET}/icon_32x32.png
    ${MAGICK} ${APPICON_SRC} -resize '!64x64' ${APPICON_ICONSET}/icon_32x32@2x.png
    ${MAGICK} ${APPICON_SRC} -resize '!128x128' ${APPICON_ICONSET}/icon_128x128.png
    ${MAGICK} ${APPICON_SRC} -resize '!256x256' ${APPICON_ICONSET}/icon_128x128@2x.png
    ${MAGICK} ${APPICON_SRC} -resize '!256x256' ${APPICON_ICONSET}/icon_256x256.png
    ${MAGICK} ${APPICON_SRC} -resize '!512x512' ${APPICON_ICONSET}/icon_256x256@2x.png
    ${MAGICK} ${APPICON_SRC} -resize '!512x512' ${APPICON_ICONSET}/icon_512x512.png
    ${MAGICK} ${APPICON_SRC} -resize '!1024x1024' ${APPICON_ICONSET}/icon_512x512@2x.png
fi

function convert_baricon() {
    SRC_FILE=$1
    ICONSET_NAME=$2

    for SCALE in $(seq 1 3); do
        IMAGE_SIZE=$((16*SCALE))
        SCALE_NAME="@${SCALE}x"
        if [ ${SCALE} -eq 1 ]; then
            SCALE_NAME=""
        fi
        DEST_NAME="${ICONSET_NAME}/icon_16x16${SCALE_NAME}.png"
        ${MAGICK} ${SRC_FILE} -resize ${IMAGE_SIZE}x${IMAGE_SIZE} -gravity center -extent ${IMAGE_SIZE}x${IMAGE_SIZE} ${DEST_NAME}
    done
}

if [ "$1" == "baricon" ]; then
    convert_baricon ${BARICON_SRC_IDLE} ${BARICON_ICONSET_IDLE}
    convert_baricon ${BARICON_SRC_WORK} ${BARICON_ICONSET_WORK}
    convert_baricon ${BARICON_SRC_SHORT_REST} ${BARICON_ICONSET_SHORT_REST}
    convert_baricon ${BARICON_SRC_LONG_REST} ${BARICON_ICONSET_LONG_REST}
fi
