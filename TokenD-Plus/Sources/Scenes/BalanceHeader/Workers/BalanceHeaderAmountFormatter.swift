import Foundation

protocol BalanceHeaderAmountFormatterProtocol {
    typealias Amount = BalanceHeader.Model.Amount
    
    func assetAmountToString(_ amount: Decimal) -> String
}

extension BalanceHeader {
    typealias AmountFormatterProtocol = BalanceHeaderAmountFormatterProtocol
}

extension BalanceHeader {
    class AmountFormatter: SharedAmountFormatter { }
}

extension BalanceHeader.AmountFormatter: BalanceHeader.AmountFormatterProtocol {
    
}
