import Foundation

extension Numeric {
    var bytes: [Int8] {
        var mutableSelf = self
        return Data(bytes: &mutableSelf, count: MemoryLayout.size(ofValue: self)).bytes
    }
}
