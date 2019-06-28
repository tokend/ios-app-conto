import Foundation
import RxCocoa
import RxSwift

protocol ReceiveAddressManagerProtocol {
    typealias Address = ReceiveAddress.Address
    
    var addressToCode: Address { get }
    var addressToShow: Address { get }
    func observeAddressToCodeChange() -> Observable<Address>
    func observeAddressToShowChange() -> Observable<Address>
}

extension ReceiveAddress {
    typealias AddressManagerProtocol = ReceiveAddressManagerProtocol
}
