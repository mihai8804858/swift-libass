#!/bin/sh

set -e

SOURCE_DIR=.source
BUILD_DIR=prebuilt
XCF_DIR=$BUILD_DIR/xcframeworks
LIB_DIR=Libraries

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
		-library ./$BUILD_DIR/apple-xros-arm64-simulator-lts/$1/$2 \
		-headers ./$BUILD_DIR/apple-xros-arm64-simulator-lts/$1/$3 \
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

checkout
build
create_xcframeworks
move_xcframeworks
