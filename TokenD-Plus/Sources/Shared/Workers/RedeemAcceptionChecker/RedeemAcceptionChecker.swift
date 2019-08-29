import Foundation
import TokenDSDK
import RxSwift

public enum RedeemAcceptionCheckerResult {
    case accepted
}
public protocol RedeemAcceptionCheckerProtocol {
    func checkRedeemAcception(
        reference: String,
        completion: @escaping(RedeemAcceptionCheckerResult) -> Void
    )
}

public class RedeemAcceptionChecker {
    
    // MARK: - Private properties
    
    private let movementsRepo: MovementsRepo
    
    private let dispatchQueue: DispatchQueue = DispatchQueue(label: "payment-check")
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: -
    
    init(movementsRepo: MovementsRepo) {
        self.movementsRepo = movementsRepo
    }
    
    // MARK: - RedeemAcceptionChecker
    
    public func checkRedeemAcception(
        reference: String,
        completion: @escaping(RedeemAcceptionCheckerResult) -> Void
        ) {
        
        self.movementsRepo
            .observeMovements()
            .subscribe(onNext: { [weak self](effects) in
                self?.handleEffects(
                    effects: effects,
                    reference: reference,
                    completion: completion)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func handleEffects(
        effects: [ParticipantEffectResource],
        reference: String,
        completion: @escaping(RedeemAcceptionCheckerResult) -> Void) {
     
        if effects.first(where: { (effect) -> Bool in
            guard let operation = effect.operation,
                let details = operation.details else {
                    return false
            }
            switch details.operationDetailsRelatedToBalance {
            case .opPaymentDetails(let payment):
                return payment.reference == reference
                
            default:
                return false
            }
        }) != nil {
            completion(.accepted)
        } else {
            self.dispatchQueue.asyncAfter(
                deadline: .now() + .seconds(2),
                execute: {
                    self.reloadMovements()
            })
        }
    }
    
    private func reloadMovements() {
        self.movementsRepo.reloadTransactions()
    }
}
