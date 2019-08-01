import Foundation
import RxCocoa
import RxSwift

public protocol AddCompanyBusinessLogic {
    typealias Event = AddCompany.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onAddCompanyAction(request: Event.AddCompanyAction.Request)
}

extension AddCompany {
    public typealias BusinessLogic = AddCompanyBusinessLogic
    
    @objc(AddCompanyInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = AddCompany.Event
        public typealias Model = AddCompany.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private let sceneModel: Model.SceneModel
        private let addCompanyWorker: AddCompanyWorkerProtocol
        
        private let loadingStatus: BehaviorRelay<Model.LoadingStatus> = BehaviorRelay(value: .loaded)
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            sceneModel: Model.SceneModel,
            addCompanyWorker: AddCompanyWorkerProtocol
            ) {
            
            self.presenter = presenter
            self.sceneModel = sceneModel
            self.addCompanyWorker = addCompanyWorker
        }
        
        private func addCompany() {
            self.loadingStatus.accept(.loading)
            self.addCompanyWorker.addCompany(
                businessAccountId: self.sceneModel.company.accountId,
                completion: { [weak self] (result) in
                    self?.loadingStatus.accept(.loaded)
                    let response: Event.AddCompanyAction.Response
                    switch result {
                        
                    case .failure(let error):
                        response = .error(error)
                        
                    case .success:
                        response = .success
                    }
                    self?.presenter.presentAddCompanyAction(response: response)
                }
            )
        }
        
        private func observeLoadingStatus() {
            self.loadingStatus
                .subscribe(onNext: { [weak self] (status) in
                    self?.presenter.presentLoadingStatusDidChange(response: status)
            })
            .disposed(by: self.disposeBag)
        }
    }
}

extension AddCompany.Interactor: AddCompany.BusinessLogic {
    
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        self.observeLoadingStatus()
        let response = Event.ViewDidLoad.Response(company: self.sceneModel.company)
        self.presenter.presentViewDidLoad(response: response)
    }
    
    public func onAddCompanyAction(request: Event.AddCompanyAction.Request) {
        self.addCompany()
    }
}
