#
#  Copyright (c) 2016 Rich Relevance Inc. All rights reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http:#www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#!/bin/bash
#
# Universal framework build script
# Adapted from: https://medium.com/@syshen/create-an-ios-universal-framework-148eb130a46c
# Gist: https://gist.github.com/syshen/c24d127e1adc2783e0e7
#

######################
# Options
######################
while getopts ":s" opt; do
  case $opt in
    s)
      STATIC_DIR="Static"
      STATIC_SCHEME="-Static"
      echo "Statically linking framework..."
      ;;
  esac
done

######################
# Configuration
######################
 
REVEAL_ARCHIVE_IN_FINDER=false

FRAMEWORK_NAME="${PROJECT_NAME}"
 
SIMULATOR_LIBRARY_PATH="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/$STATIC_DIR/${FRAMEWORK_NAME}.framework"
 
DEVICE_LIBRARY_PATH="${BUILD_DIR}/${CONFIGURATION}-iphoneos/$STATIC_DIR/${FRAMEWORK_NAME}.framework"
 
UNIVERSAL_LIBRARY_DIR="${BUILD_DIR}/${CONFIGURATION}-iphoneuniversal/$STATIC_DIR"
 
FRAMEWORK="${UNIVERSAL_LIBRARY_DIR}/${FRAMEWORK_NAME}.framework"
 
README_PATH="${PROJECT_DIR}/../Readme.md"
 
OUTPUT_DIR="${SYMROOT}/${CONFIGURATION}-universal/$STATIC_DIR"
 
set -e
set -o pipefail
 
######################
# Build Frameworks
######################
 
echo "Creating simulator build"
xcodebuild -scheme "${PROJECT_NAME}$STATIC_SCHEME" -sdk iphonesimulator -configuration ${CONFIGURATION} clean build CONFIGURATION_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/$STATIC_DIR 2>&1
 
echo "Creating device build"
xcodebuild -scheme "${PROJECT_NAME}$STATIC_SCHEME" -sdk iphoneos -configuration ${CONFIGURATION} clean build CONFIGURATION_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphoneos/$STATIC_DIR 2>&1
 
##########################################
# Create directory for Universal Framework
##########################################
 
echo "Creating directory: ${UNIVERSAL_LIBRARY_DIR}"
 
rm -rf "${UNIVERSAL_LIBRARY_DIR}"
mkdir -p "${UNIVERSAL_LIBRARY_DIR}"
mkdir  "${FRAMEWORK}"
 
#######################
# Copy Framework files
#######################
 
echo "Copy files to: ${FRAMEWORK}"
 
cp -r "${DEVICE_LIBRARY_PATH}/." "${FRAMEWORK}"
 
###########################
# Make an universal binary
###########################
 
lipo "${SIMULATOR_LIBRARY_PATH}/${FRAMEWORK_NAME}" "${DEVICE_LIBRARY_PATH}/${FRAMEWORK_NAME}" -create -output "${FRAMEWORK}/${FRAMEWORK_NAME}" | echo
 
####################################################
# Copy result and Readme files to release directory
####################################################
 
echo "Copy result and Readme files to: ${OUTPUT_DIR}"
 
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
 
cp -r "${FRAMEWORK}" "$OUTPUT_DIR"
 
if [ "${README_PATH}" ]; then
cp -r "${README_PATH}" "$OUTPUT_DIR"
fi

####################################################
# Generate and copy documentation
####################################################

APPLEDOC_PATH="/usr/local/bin/appledoc"
DOC_DIR="${OUTPUT_DIR}/Docs"

echo "Generating doc for files in ${PROJECT_DIR}/${PROJECT_NAME}"

if [ -f $APPLEDOC_PATH ]; then
$APPLEDOC_PATH \
--project-name "${PRODUCT_NAME}" \
--project-company "Rich Relevance" \
--company-id "com.richrelevance" \
--output "${DOC_DIR}" \
--keep-intermediate-files \
--no-repeat-first-par \
--no-warn-invalid-crossref \
--exit-threshold 2 \
--create-html \
"${PROJECT_DIR}/${PROJECT_NAME}"
fi

####################################################
# Package Zip
####################################################

echo "Creating project build directory..."
 
PROJ_BUILD_DIR="${PROJECT_DIR}/../build/$STATIC_DIR"
rm -rf "${PROJ_BUILD_DIR}"
mkdir "${PROJ_BUILD_DIR}"

 SDK_ZIP_PATH="${PROJ_BUILD_DIR}/${PROJECT_NAME}.zip"
echo "Zipping to ${SDK_ZIP_PATH}"
pushd "${OUTPUT_DIR}"
zip -rq "${SDK_ZIP_PATH}" .
popd
 
echo "Copying Framework to Root Project Dir..."

cp -r "${FRAMEWORK}" "${PROJ_BUILD_DIR}"

echo "Copying Framework to Demo Build Dir..."

DEMO_BUILD_DIR="${PROJECT_DIR}/../Demo/build"
rm -rf "${DEMO_BUILD_DIR}"
mkdir "${DEMO_BUILD_DIR}"

cp -r "${FRAMEWORK}" "${DEMO_BUILD_DIR}"
