import Foundation
import TokenDWallet
import RxSwift
import RxCocoa

extension ReceiveAddress {
    
    class ExportSeedManager {
        
        // MARK: - Private properties
        
        private let seedRelay: BehaviorRelay<ReceiveAddress.Address> = BehaviorRelay(value: "")
        private let keychainDataProvider: KeychainDataProviderProtocol
        
        // MARK: -
        
        init(keychainDataProvider: KeychainDataProviderProtocol) {
            self.keychainDataProvider = keychainDataProvider
        }
    }
}

extension ReceiveAddress.ExportSeedManager: ReceiveAddressManagerProtocol {
    
    var addressToCode: Address {
        return self.seedRelay.value
    }
    
    var addressToShow: Address {
        return self.seedRelay.value
    }
    
    func observeAddressToCodeChange() -> Observable<Address> {
        let seedData = self.keychainDataProvider.getKeyData()
        let seed = Base32Check.encode(version: .seedEd25519, data: seedData.getSeedData())
        self.seedRelay.accept(seed)
        return self.seedRelay.asObservable()
    }
    
    func observeAddressToShowChange() -> Observable<Address> {
        return self.seedRelay.asObservable()
    }
}
