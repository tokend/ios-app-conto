import UIKit

protocol ReceiveAddressShareUtilProtocol {
    var canBeCopied: Bool { get }
    var canBeShared: Bool { get }
    
    func stringToCopyAddress(
        _ address: ReceiveAddress.Address
        ) -> String
    
    func itemsToShareAddress(
        _ addressToCode: ReceiveAddress.Address,
        _ qrCodeSize: CGSize,
        _ addressToShow: ReceiveAddress.Address
        ) -> ReceiveAddress.Model.ItemsToShare
}

extension ReceiveAddress {
    typealias ShareUtilProtocol = ReceiveAddressShareUtilProtocol
}
