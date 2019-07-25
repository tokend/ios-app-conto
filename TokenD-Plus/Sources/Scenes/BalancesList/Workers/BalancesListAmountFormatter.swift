import Foundation

protocol BalancesListAmountFormatterProtocol {
    func formatAmount(_ amount: Decimal, currency: String) -> String
    func assetAmountToString(_ amount: Decimal) -> String
}

extension BalancesList {
    typealias AmountFormatterProtocol = BalancesListAmountFormatterProtocol
    
    class AmountFormatter: SharedAmountFormatter { }
}

extension BalancesList.AmountFormatter: BalancesList.AmountFormatterProtocol {
    
}
