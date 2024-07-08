import XCTest
@testable import SwiftLibass

final class SwiftLibassTests: XCTestCase {
    func testLibraryInit() {
        let library = ass_library_init()
        ass_library_done(library)
        XCTAssert(true)
    }

    func testRendererInit() {
        let library = ass_library_init()
        let renderer = ass_renderer_init(library)
        ass_renderer_done(renderer)
        ass_library_done(library)
        XCTAssert(true)
    }
}
