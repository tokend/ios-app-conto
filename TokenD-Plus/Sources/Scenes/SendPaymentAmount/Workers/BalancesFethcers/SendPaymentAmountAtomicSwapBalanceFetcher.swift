import Foundation
import TokenDWallet
import RxSwift
import RxCocoa

extension SendPaymentAmount {
    class AtomicSwapBalanceFetcherWorker {
        
        // MARK: - Private properties
        
        private let errors: PublishRelay<Swift.Error> = PublishRelay()
        private let buyPreposition: SendPaymentAmount.Model.BalanceDetails
        
        // MARK: -
        
        init(buyPreposition: SendPaymentAmount.Model.BalanceDetails) {
           self.buyPreposition = buyPreposition
        }
    }
}

// MARK: - BalanceDetailsLoader

extension SendPaymentAmount.AtomicSwapBalanceFetcherWorker: SendPaymentAmount.BalanceDetailsLoader {
    func observeBalanceDetails() -> Observable<[SendPaymentAmount.Model.BalanceDetails]> {
        
        return Observable.just([self.buyPreposition])
    }
    
    func observeLoadingStatus() -> Observable<SendPaymentAmountBalanceDetailsLoaderLoadingStatus> {
        return Observable.just(.loaded)
    }
    
    func observeErrors() -> Observable<Swift.Error> {
        return self.errors.asObservable()
    }
    
    func loadBalanceDetails() {
        
    }
}
