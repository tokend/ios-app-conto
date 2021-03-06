import Foundation

extension TransactionsListScene {
    
    enum Configurator {
        static func configure(
            viewController: ViewController,
            transactionsFetcher: TransactionsFetcherProtocol,
            actionProvider: ActionProviderProtocol,
            amountFormatter: AmountFormatterProtocol,
            dateFormatter: DateFormatterProtocol,
            emptyTitle: String,
            viewConfig: Model.ViewConfig,
            routing: Routing?
            ) {
            
            let presenterDispatch = PresenterDispatch(displayLogic: viewController)
            let presenter = Presenter(
                presenterDispatch: presenterDispatch,
                amountFormatter: amountFormatter,
                dateFormatter: dateFormatter,
                emptyTitle: emptyTitle
            )
            let interactor = Interactor(
                presenter: presenter,
                transactionsFetcher: transactionsFetcher,
                actionProvider: actionProvider
            )
            let interactorDispatch = InteractorDispatch(businessLogic: interactor)
            viewController.inject(
                interactorDispatch: interactorDispatch,
                viewConfig: viewConfig,
                routing: routing
            )
        }
    }
}

extension TransactionsListScene {
    
    class InteractorDispatch {
        
        private let queue: DispatchQueue = DispatchQueue(
            label: "\(NSStringFromClass(InteractorDispatch.self))\(BusinessLogic.self)".queueLabel,
            qos: .userInteractive
        )
        
        private let businessLogic: BusinessLogic
        
        init(businessLogic: BusinessLogic) {
            self.businessLogic = businessLogic
        }
        
        func sendRequest(requestBlock: @escaping (_ businessLogic: BusinessLogic) -> Void) {
            self.queue.async {
                requestBlock(self.businessLogic)
            }
        }
        
        func sendSyncRequest<ReturnType: Any>(
            requestBlock: @escaping (_ businessLogic: BusinessLogic) -> ReturnType
            ) -> ReturnType {
            return requestBlock(self.businessLogic)
        }
    }
    
    class PresenterDispatch {
        
        private weak var displayLogic: DisplayLogic?
        
        init(displayLogic: DisplayLogic) {
            self.displayLogic = displayLogic
        }
        
        func display(displayBlock: @escaping (_ displayLogic: DisplayLogic) -> Void) {
            guard let displayLogic = self.displayLogic else { return }
            
            DispatchQueue.main.async {
                displayBlock(displayLogic)
            }
        }
        
        func displaySync(displayBlock: @escaping (_ displayLogic: DisplayLogic) -> Void) {
            guard let displayLogic = self.displayLogic else { return }
            
            displayBlock(displayLogic)
        }
    }
}
