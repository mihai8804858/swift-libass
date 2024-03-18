import SwiftUI
import SwiftLibass

struct ContentView: View {
    @State private var library: OpaquePointer?
    @State private var renderer: OpaquePointer?

    var body: some View {
        Text("Swift Libass").onAppear {
            library = ass_library_init()
            renderer = ass_renderer_init(library)
        }
    }
}
