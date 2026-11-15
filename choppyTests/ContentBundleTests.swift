import ChoppyCore
import Testing
@testable import choppy

struct ContentBundleTests {
    @Test func bundledContentLoadsAndValidates() throws {
        let library = try ContentLibrary.loadBundled()
        #expect(library.contentVersion >= 1)
        #expect(library.kana.count == 208)
        #expect(!library.topics.isEmpty)
        for topic in library.topics {
            #expect(!library.vocab(inTopic: topic.id).isEmpty, "Topic \(topic.id) has no words")
        }
    }
}
