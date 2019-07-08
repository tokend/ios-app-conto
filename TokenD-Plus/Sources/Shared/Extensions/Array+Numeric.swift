import Foundation

extension Array where Element == Int8 {
    
    func getValue<T: Numeric>(type: T.Type) -> T {
        let reversed = Array(self.reversed())
        let valueData = Data(bytes: reversed, count: reversed.count)
        return valueData.getValue(type: type)
    }
}
