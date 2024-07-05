

# SwiftLibass

Swift wrapper for [`libass`](https://github.com/libass/libass).

[![CI](https://github.com/mihai8804858/swift-libass/actions/workflows/ci.yml/badge.svg)](https://github.com/mihai8804858/swift-libass/actions/workflows/ci.yml) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmihai8804858%2Fswift-libass%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/mihai8804858/swift-libass) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmihai8804858%2Fswift-libass%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/mihai8804858/swift-libass)

## Installation

You can add `swift-libass` to an Xcode project by adding it to your project as a package.

> https://github.com/mihai8804858/swift-libass

If you want to use `swift-libass` in a [SwiftPM](https://swift.org/package-manager/) project, it's as
simple as adding it to your `Package.swift`:

``` swift
dependencies: [
  .package(url: "https://github.com/mihai8804858/swift-libass", from: "1.0.0")
]
```

And then adding the product to any target that needs access to the library:

```swift
.product(name: "SwiftLibass", package: "swift-libass"),
```

## Quick Start

Just import `SwiftLibass` in your project to access the underlying `libass` C API:
```swift
import SwiftLibass

let library = ass_library_init()
let renderer = ass_renderer_init(library)
```

## Build Dependencies

All C dependencies come prebuilt as XCFramewroks in `Libraries` folder.

To rebuild the dependencies, run:

```bash
sh ./build-libraries.sh
```

The script will rebuild all C dependencies for all platforms and architectures, create XCFrameworks from them, and move them to `Libraries` folder.

## Prebuilt Versions

* `fontconfig` - `2.15.0`
* `freetype` - `2.13.2`
* `fribidi` - `1.0.14`
* `harfbuzz` - `8.5.0`
* `libpng` - `1.6.43`
* `libass` - `0.17.3`

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
