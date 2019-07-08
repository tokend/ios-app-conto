import RxCocoa
import RxSwift
import UIKit

extension ReceiveAddress {
    
    class RedeemManager {
        
        // MARK: - Private properties
        
        private let redeem: BehaviorRelay<ReceiveAddressManagerProtocol.Address>
        
        // MARK: -
        
        init(redeem: String) {
            self.redeem = BehaviorRelay(value: redeem)
        }
    }
}

extension ReceiveAddress.RedeemManager: ReceiveAddress.AddressManagerProtocol {
    
    var addressToCode: ReceiveAddressManagerProtocol.Address {
        return self.redeem.value
    }
    
    var addressToShow: ReceiveAddressManagerProtocol.Address {
        return self.redeem.value
    }
    
    func observeAddressToCodeChange() -> Observable<ReceiveAddressManagerProtocol.Address> {
        return self.redeem.asObservable()
    }
    
    func observeAddressToShowChange() -> Observable<ReceiveAddressManagerProtocol.Address> {
        return self.redeem.asObservable()
    }
}
