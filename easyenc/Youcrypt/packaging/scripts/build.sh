#!/bin/sh

PROJECT=Youcrypt
PRODUCT=Youcrypt
TARGET=Youcrypt
SCHEME=Youcrypt
CONFIGURATION=Release
SDK=macosx10.8


MY_PATH=`dirname $0`
BUILD_FROM_DIR=${MY_PATH}/../../

INTERMEDIATES_PATH=${BUILD_FROM_DIR}/build/intermediates
PRODUCTS_PATH=${BUILD_FROM_DIR}/build/products

echo  cd ${BUILD_FROM_DIR}
cd ${BUILD_FROM_DIR}

if ! [ -d ${PROJECT}.xcodeproj ] ; then 
    echo "${PROJECT} project directory not found. Wrong directory? ${PWD}"
    exit 1
fi

if ! [ -d ${INTERMEDIATES_PATH} ] ; then
    mkdir -p ${INTERMEDIATES_PATH}
fi

if ! [ -d ${PRODUCTS_PATH} ] ; then
    mkdir -p ${PRODUCTS_PATH}
fi

xcodebuild -target ${TARGET} -scheme ${SCHEME} \
    -configuration ${CONFIGURATION} -sdk ${SDK} \
    OBJROOT=${INTERMEDIATES_PATH} SYMROOT=${PRODUCTS_PATH}
