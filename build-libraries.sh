#!/bin/sh

set -e

SOURCE_DIR=.source
BUILD_DIR=prebuilt
XCF_DIR=$BUILD_DIR/xcframeworks
LIB_DIR=Libraries/XCFrameworks
MODULE_MAPS_DIR=Libraries/ModuleMaps

IOS_TARGET=15.0
TVOS_TARGET=15.0
XROS_TARGET=1.0
MAC_TARGET=12.0
MAC_CATALYST_TARGET=15.0

recreate_dir() {
	if [ -d "$1" ]; then
		rm -rf "$1"
	fi
	mkdir "$1"
}

checkout() {
	recreate_dir $SOURCE_DIR
	cd $SOURCE_DIR
	# Change this when visionOS support is added
	git clone git@github.com:mihai8804858/ffmpeg-kit.git
	cd ffmpeg-kit
}

build_ios() {
	./ios.sh -s -x -l \
		--target=$IOS_TARGET \
		--mac-catalyst-target=$MAC_CATALYST_TARGET \
		--enable-libass \
		--no-bitcode \
		--disable-armv7 \
		--disable-armv7s \
		--disable-arm64e \
		--disable-i386
}

build_tvos() {
	./tvos.sh -s -x -l \
		--target=$TVOS_TARGET \
		--enable-libass \
		--no-bitcode
}

build_xros() {
	./xros.sh -s -x -l \
		--target=$XROS_TARGET \
		--enable-libass \
		--no-bitcode
}

build_macos() {
	./macos.sh -s -x -l \
		--target=$MAC_TARGET \
		--enable-libass
}

build() {
	build_ios
	build_tvos
	build_xros
	build_macos
}

create_fat_library() {
	lipo -create $1 $2 -output $3
	cp -r $4 $5
}

create_fat_libraries() {
	mkdir -p ./$BUILD_DIR/apple-ios-arm64-x86_64-simulator-lts/$1/lib
	create_fat_library \
		./$BUILD_DIR/apple-ios-arm64-simulator-lts/$1/$2 \
		./$BUILD_DIR/apple-ios-x86_64-lts/$1/$2 \
		./$BUILD_DIR/apple-ios-arm64-x86_64-simulator-lts/$1/$2 \
		./$BUILD_DIR/apple-ios-arm64-simulator-lts/$1/$3 \
		./$BUILD_DIR/apple-ios-arm64-x86_64-simulator-lts/$1/$3

	mkdir -p ./$BUILD_DIR/apple-ios-arm64-x86_64-mac-catalyst-lts/$1/lib
	create_fat_library \
		./$BUILD_DIR/apple-ios-arm64-mac-catalyst-lts/$1/$2 \
		./$BUILD_DIR/apple-ios-x86_64-mac-catalyst-lts/$1/$2 \
		./$BUILD_DIR/apple-ios-arm64-x86_64-mac-catalyst-lts/$1/$2 \
		./$BUILD_DIR/apple-ios-arm64-mac-catalyst-lts/$1/$3 \
		./$BUILD_DIR/apple-ios-arm64-x86_64-mac-catalyst-lts/$1/$3

	mkdir -p ./$BUILD_DIR/apple-tvos-arm64-x86_64-simulator-lts/$1/lib
	create_fat_library \
		./$BUILD_DIR/apple-tvos-arm64-simulator-lts/$1/$2 \
		./$BUILD_DIR/apple-tvos-x86_64-lts/$1/$2 \
		./$BUILD_DIR/apple-tvos-arm64-x86_64-simulator-lts/$1/$2 \
		./$BUILD_DIR/apple-tvos-arm64-simulator-lts/$1/$3 \
		./$BUILD_DIR/apple-tvos-arm64-x86_64-simulator-lts/$1/$3

	mkdir -p ./$BUILD_DIR/apple-xros-arm64-x86_64-simulator-lts/$1/lib
	create_fat_library \
		./$BUILD_DIR/apple-xros-arm64-simulator-lts/$1/$2 \
		./$BUILD_DIR/apple-xros-x86_64-lts/$1/$2 \
		./$BUILD_DIR/apple-xros-arm64-x86_64-simulator-lts/$1/$2 \
		./$BUILD_DIR/apple-xros-arm64-simulator-lts/$1/$3 \
		./$BUILD_DIR/apple-xros-arm64-x86_64-simulator-lts/$1/$3

	mkdir -p ./$BUILD_DIR/apple-macos-arm64-x86_64-lts/$1/lib
	create_fat_library \
		./$BUILD_DIR/apple-macos-arm64-lts/$1/$2 \
		./$BUILD_DIR/apple-macos-x86_64-lts/$1/$2 \
		./$BUILD_DIR/apple-macos-arm64-x86_64-lts/$1/$2 \
		./$BUILD_DIR/apple-macos-arm64-lts/$1/$3 \
		./$BUILD_DIR/apple-macos-arm64-x86_64-lts/$1/$3
}

create_xcframework() {
	create_fat_libraries $1 $2 $3

	xcodebuild -create-xcframework \
		-library ./$BUILD_DIR/apple-ios-arm64-lts/$1/$2 \
		-headers ./$BUILD_DIR/apple-ios-arm64-lts/$1/$3 \
		-library ./$BUILD_DIR/apple-ios-arm64-x86_64-simulator-lts/$1/$2 \
		-headers ./$BUILD_DIR/apple-ios-arm64-x86_64-simulator-lts/$1/$3 \
		-library ./$BUILD_DIR/apple-ios-arm64-x86_64-mac-catalyst-lts/$1/$2 \
		-headers ./$BUILD_DIR/apple-ios-arm64-x86_64-mac-catalyst-lts/$1/$3 \
		-library ./$BUILD_DIR/apple-tvos-arm64-lts/$1/$2 \
		-headers ./$BUILD_DIR/apple-tvos-arm64-lts/$1/$3 \
		-library ./$BUILD_DIR/apple-tvos-arm64-x86_64-simulator-lts/$1/$2 \
		-headers ./$BUILD_DIR/apple-tvos-arm64-x86_64-simulator-lts/$1/$3 \
		-library ./$BUILD_DIR/apple-xros-arm64-lts/$1/$2 \
		-headers ./$BUILD_DIR/apple-xros-arm64-lts/$1/$3 \
		-library ./$BUILD_DIR/apple-xros-arm64-x86_64-simulator-lts/$1/$2 \
		-headers ./$BUILD_DIR/apple-xros-arm64-x86_64-simulator-lts/$1/$3 \
		-library ./$BUILD_DIR/apple-macos-arm64-x86_64-lts/$1/$2 \
		-headers ./$BUILD_DIR/apple-macos-arm64-x86_64-lts/$1/$3 \
		-output  ./$XCF_DIR/$1.xcframework
}

create_xcframeworks() {
	recreate_dir "./$XCF_DIR"

	create_xcframework "fontconfig" "lib/libfontconfig.a" "include"
	create_xcframework "freetype" "lib/libfreetype.a" "include"
	create_xcframework "harfbuzz" "lib/libharfbuzz.a" "include"
	create_xcframework "fribidi" "lib/libfribidi.a" "include"
	create_xcframework "libpng" "lib/libpng16.a" "include"
	create_xcframework "libass" "lib/libass.a" "include"
}

move_xcframework() {
	rm -rf "../../$LIB_DIR/$1.xcframework"
	cp -r "./$XCF_DIR/$1.xcframework" "../../$LIB_DIR/$1.xcframework"
}

move_xcframeworks() {
	recreate_dir "../../$LIB_DIR"

	move_xcframework "fontconfig"
	move_xcframework "freetype"
	move_xcframework "harfbuzz"
	move_xcframework "fribidi"
	move_xcframework "libpng"
	move_xcframework "libass"
}

move_module_map_for_arch() {
	HEADERS=$LIB_DIR/$2/$3/Headers
	UMBRELLA_DIR=$HEADERS/$1
	TEMP_DIR_NAME=temp
	TEMP_DIR=$HEADERS/$TEMP_DIR_NAME
	MODULE_MAP_SRC=$MODULE_MAPS_DIR/$1/module.modulemap
	MODULE_MAP_DST=$TEMP_DIR/module.modulemap
	MODULE_MAP_FINAL=$UMBRELLA_DIR/module.modulemap

	recreate_dir $TEMP_DIR
	find $HEADERS -mindepth 1 -maxdepth 1 -not \( -name "$TEMP_DIR_NAME" \) -exec mv {} $TEMP_DIR \;
	cp $MODULE_MAP_SRC $MODULE_MAP_DST
	mv $TEMP_DIR $UMBRELLA_DIR

	echo "modulemap successfully written out to: $MODULE_MAP_FINAL"
}

move_module_map() {
	for ARCH in $(find $LIB_DIR/$2 -mindepth 1 -maxdepth 1 -type d); do
	    move_module_map_for_arch $1 $2 $(basename $ARCH)
	done
}

move_module_maps() {
	move_module_map "fontconfig" "fontconfig.xcframework"
	move_module_map "freetype2" "freetype.xcframework"
	move_module_map "fribidi" "fribidi.xcframework"
	move_module_map "harfbuzz" "harfbuzz.xcframework"
	move_module_map "libpng" "libpng.xcframework"
	move_module_map "libass" "libass.xcframework"
}

checkout
build
create_xcframeworks
move_xcframeworks
move_module_maps
