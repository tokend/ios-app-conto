import Foundation

public protocol PaymentMethodPaymentMethodsFetcherProtocol {
    func fetchPaymentMetods(baseAmount: Decimal) -> [PaymentMethod.Model.PaymentMethod]
}

extension PaymentMethod {
    public typealias PaymentMethodsFetcherProtocol = PaymentMethodPaymentMethodsFetcherProtocol
    
    public class AtomicSwapAsksPaymentMethodsFetcher {
        typealias QuoteAsset = AtomicSwap.Model.QuoteAmount
        
        // MARK: - Public properties
        
        private let quoteAssets: [QuoteAsset]
        
        // MARK: -
        
        init(quoteAssets: [QuoteAsset]) {
            self.quoteAssets = quoteAssets
        }
    }
}

extension PaymentMethod.AtomicSwapAsksPaymentMethodsFetcher: PaymentMethod.PaymentMethodsFetcherProtocol {
    
    public func fetchPaymentMetods(baseAmount: Decimal) -> [PaymentMethod.Model.PaymentMethod] {
        
        return self.quoteAssets.map({ (price) -> PaymentMethod.Model.PaymentMethod in
            
            let amount = price.value * baseAmount
            return PaymentMethod.Model.PaymentMethod(
                asset: price.asset,
                amount: amount
            )
        })
    }
}
