import Testing
@testable import SwiftLibass

@Suite struct SwiftLibassTests {
    @Test func libraryInit() throws {
        let library = try #require(ass_library_init())
        ass_library_done(library)
    }

    @Test func rendererInit() throws {
        let library = try #require(ass_library_init())
        let renderer = try #require(ass_renderer_init(library))
        ass_renderer_done(renderer)
        ass_library_done(library)
    }
}
