import RxCocoa
import RxSwift
import UIKit

extension ReceiveAddress {
    
    class AtomicSwapManager {
        
        // MARK: - Private properties
        
        private let address: BehaviorRelay<ReceiveAddressManagerProtocol.Address>
        
        // MARK: -
        
        init(address: String) {
            self.address = BehaviorRelay(value: address)
        }
    }
}

extension ReceiveAddress.AtomicSwapManager: ReceiveAddress.AddressManagerProtocol {
    
    var addressToCode: ReceiveAddressManagerProtocol.Address {
        return self.address.value
    }
    
    var addressToShow: ReceiveAddressManagerProtocol.Address {
        return self.address.value
    }
    
    func observeAddressToCodeChange() -> Observable<ReceiveAddressManagerProtocol.Address> {
        return self.address.asObservable()
    }
    
    func observeAddressToShowChange() -> Observable<ReceiveAddressManagerProtocol.Address> {
        return self.address.asObservable()
    }
}
