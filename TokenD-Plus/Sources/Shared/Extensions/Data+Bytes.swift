import Foundation

extension Data {
    
    public var bytes: [Int8] {
        var result: [Int8] = [Int8](repeating: 0, count: self.count)
        (self as NSData).getBytes(&result, length:self.count)
        return result
    }
    
    public func getValue<T: Numeric>(type: T.Type) -> T {
        return self.withUnsafeBytes { (bytes) -> T in
            return bytes.pointee
        }
    }
}
