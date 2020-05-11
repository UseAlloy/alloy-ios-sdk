#!/bin/sh

# Create folder where we place built frameworks
mkdir build

# build framework for simulators
xcodebuild clean build \
  -project Alloy.xcodeproj \
  -scheme Alloy \
  -configuration Release \
  -sdk iphonesimulator \
  -derivedDataPath derived_data

# Create folder to store compiled framework for simulator
mkdir build/simulator

# copy compiled framework for simulator into our build folder
cp -r derived_data/Build/Products/Release-iphonesimulator/Alloy.framework build/simulator

# Build framework for devices
xcodebuild clean build \
  -project Alloy.xcodeproj \
  -scheme Alloy \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath derived_data

# Create folder to store compiled framework for devices
mkdir build/devices

# copy compiled framework for simulator into our build folder
cp -r derived_data/Build/Products/Release-iphoneos/Alloy.framework build/devices

# create folder to store compiled universal framework
mkdir build/universal

####################### Create universal framework #############################

# copy device framework into universal folder
cp -r build/devices/Alloy.framework build/universal/

# create framework binary compatible with simulators and devices, and replace binary in unviersal framework
lipo -create \
  build/simulator/Alloy.framework/Alloy \
  build/devices/Alloy.framework/Alloy \
  -output build/universal/Alloy.framework/Alloy

# copy simulator Swift public interface to universal framework
cp build/simulator/Alloy.framework/Modules/Alloy.swiftmodule/* build/universal/Alloy.framework/Modules/Alloy.swiftmodule
