import UIKit

extension ReceiveAddress {
    
    class ReceiveAddressShareUtil {
        
        private let qrCodeGenerator: ReceiveAddressQRCodeGeneratorProtocol
        private let shareQRCodeSize: CGSize = CGSize(width: 200, height: 200)
        
        init(
            qrCodeGenerator: ReceiveAddressQRCodeGeneratorProtocol
            ) {
            
            self.qrCodeGenerator = qrCodeGenerator
        }
        
        private func invoiceWithAddress(
            _ address: ReceiveAddress.Address
            ) -> String {
            
            return address
        }
    }
}

extension ReceiveAddress.ReceiveAddressShareUtil: ReceiveAddress.ShareUtilProtocol {
    
    var canBeCopied: Bool {
        return true
    }
    
    var canBeShared: Bool {
        return true
    }
    
    func stringToCopyAddress(
        _ address: ReceiveAddress.Address
        ) -> String {
        
        return address
    }
    
    func itemsToShareAddress(
        _ addressToCode: ReceiveAddress.Address,
        _ qrCodeSize: CGSize,
        _ addressToShow: ReceiveAddress.Address
        ) -> ReceiveAddress.Model.ItemsToShare {
        
        return ReceiveAddress.Model.ItemsToShare(
            addressToCode: addressToCode,
            qrCodeSize: qrCodeSize,
            addressToShow:addressToShow
        )
    }
}
