import Foundation

extension Array where Element == Int8 {
    
    mutating func readBytes(n: Int) -> [Int8] {
        let readBytes = Array(self.prefix(n))
        self.removeSubrange(0..<n)
        return readBytes
    }
}
