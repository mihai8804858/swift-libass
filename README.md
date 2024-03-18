

# SwiftLibass

Swift wrapper for [`libass`](https://github.com/libass/libass).

[![CI](https://github.com/mihai8804858/swift-libass/actions/workflows/ci.yml/badge.svg)](https://github.com/mihai8804858/swift-libass/actions/workflows/ci.yml)

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


## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
