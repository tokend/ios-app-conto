import Foundation

public protocol PaymentMethodPaymentMethodsFetcherProtocol {
    func fetchPaymentMetods(
        baseAmount: Decimal,
        completion: @escaping ([PaymentMethod.Model.PaymentMethod]) -> Void
    )
}

extension PaymentMethod {
    public typealias PaymentMethodsFetcherProtocol = PaymentMethodPaymentMethodsFetcherProtocol
    
    public class AtomicSwapAsksPaymentMethodsFetcher {
        typealias QuoteAsset = AtomicSwap.Model.QuoteAmount
        
        // MARK: - Public properties
        
        private let networkFecther: NetworkInfoFetcher
        private let quoteAssets: [QuoteAsset]
        
        private var precision: Int64 = 1_000_000
        
        // MARK: -
        
        init(
            networkFecther: NetworkInfoFetcher,
            quoteAssets: [QuoteAsset]
            ) {
            
            self.networkFecther = networkFecther
            self.quoteAssets = quoteAssets
        }
        
        // MARK: - Private
        
        private func fetchNetworkInfo(
            baseAmount: Decimal,
            completion: @escaping ([PaymentMethod.Model.PaymentMethod]) -> Void
            ) {
            
            self.networkFecther.fetchNetworkInfo { [weak self] (result) in
                switch result {
                    
                case .failed:
                    break
                    
                case .succeeded(let networkInfo):
                    self?.precision = networkInfo.precision
                }
                self?.handleNetworkInfoResult(
                    baseAmount: baseAmount,
                    completion: completion
                )
            }
        }
        
        private func handleNetworkInfoResult(
            baseAmount: Decimal,
            completion: @escaping ([PaymentMethod.Model.PaymentMethod]) -> Void
            ) {
            
            let methods = self.quoteAssets
                .map({ (price) -> PaymentMethod.Model.PaymentMethod in
                    let amount = price.value * baseAmount
                    return PaymentMethod.Model.PaymentMethod(
                        asset: price.assetName,
                        amount: amount
                    )
                })
                .filter({ (method) -> Bool in
                    let precisedAmount = NSDecimalNumber(decimal: method.amount).doubleValue * Double(self.precision)
                    return precisedAmount.rounded() > 0
                })
            completion(methods)
        }
    }
}

extension PaymentMethod.AtomicSwapAsksPaymentMethodsFetcher: PaymentMethod.PaymentMethodsFetcherProtocol {
    
    public func fetchPaymentMetods(
        baseAmount: Decimal,
        completion: @escaping ([PaymentMethod.Model.PaymentMethod]) -> Void
        ) {
        
        self.fetchNetworkInfo(
            baseAmount: baseAmount,
            completion: completion
        )
    }
}
