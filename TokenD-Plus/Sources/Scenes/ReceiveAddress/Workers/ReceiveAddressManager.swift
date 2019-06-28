import RxCocoa
import RxSwift
import UIKit

extension ReceiveAddress {
    class ReceiveAddressManager {
    
        private let addressToCodeBehaviorRelay: BehaviorRelay<ReceiveAddressManagerProtocol.Address>
        private let addressToShowBehaviorRelay: BehaviorRelay<ReceiveAddressManagerProtocol.Address>
        
        init(
            accountId: String,
            email: String
            ) {
            
            self.addressToCodeBehaviorRelay = BehaviorRelay(value: accountId)
            self.addressToShowBehaviorRelay = BehaviorRelay(value: email)
        }
    }
}

extension ReceiveAddress.ReceiveAddressManager: ReceiveAddress.AddressManagerProtocol {
    
    var addressToCode: ReceiveAddressManagerProtocol.Address {
        return self.addressToCodeBehaviorRelay.value
    }
    
    var addressToShow: ReceiveAddressManagerProtocol.Address {
        return self.addressToShowBehaviorRelay.value
    }
    
    func observeAddressToCodeChange() -> Observable<ReceiveAddressManagerProtocol.Address> {
        return self.addressToCodeBehaviorRelay.asObservable()
    }
    
    func observeAddressToShowChange() -> Observable<ReceiveAddressManagerProtocol.Address> {
        return self.addressToShowBehaviorRelay.asObservable()
    }
}
