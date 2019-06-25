import Foundation
import RxSwift
import RxCocoa

public protocol PollsBusinessLogic {
    typealias Event = Polls.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onActionButtonClicked(request: Event.ActionButtonClicked.Request)
    func onChoiceChanged(request: Event.ChoiceChanged.Request)
}

extension Polls {
    public typealias BusinessLogic = PollsBusinessLogic
    
    @objc(PollsInteractor)
    public class Interactor: NSObject {
        
        public typealias Event = Polls.Event
        public typealias Model = Polls.Model
        
        // MARK: - Private properties
        
        private let presenter: PresentationLogic
        private var sceneModel: Model.SceneModel
        private let pollsFetcher: PollsFetcherProtocol
        private let voteWorker: VoteWorkerProtocol
        
        private let loadingStatus: BehaviorRelay<Model.LoadingStatus> = BehaviorRelay(value: .loaded)
        
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        public init(
            presenter: PresentationLogic,
            pollsFetcher: PollsFetcherProtocol,
            voteWorker: VoteWorkerProtocol
            ) {
            
            self.presenter = presenter
            self.pollsFetcher = pollsFetcher
            self.voteWorker = voteWorker
            self.sceneModel = Model.SceneModel(
                polls: []
            )
        }
        
        // MARK: - Private
        
        private func updateScene() {
            let response = Event.SceneUpdated.Response(
                content: .polls(self.sceneModel.polls)
            )
            self.presenter.presentSceneUpdated(response: response)
        }
        
        // MARK: - Observe
        
        private func observePolls() {
            self.pollsFetcher
                .observePolls()
                .subscribe(onNext: { [weak self] (polls) in
                    self?.sceneModel.polls = polls
                    self?.updateScene()
                })
                .disposed(by: self.disposeBag)
        }
        
        private func observeFetcherLoadingStatus() {
            self.pollsFetcher
                .observeLoadingStatus()
                .subscribe(onNext: { [weak self] (status) in
                    self?.loadingStatus.accept(status)
                })
            .disposed(by: self.disposeBag)
        }
        
        private func observeLoadingStatus() {
            self.loadingStatus.subscribe(onNext: { [weak self] (status) in
                self?.presenter.presentLoadingStatusDidChange(response: status)
            })
            .disposed(by: self.disposeBag)
        }
        
        // MARK: - Action handling
        
        private func handleAddVote(pollId: String) {
            guard let poll = self.sceneModel.polls.first(where: { (poll) -> Bool in
                return poll.id == pollId
            }), let currentChoice = poll.currentChoice else {
                return
            }
            self.loadingStatus.accept(.loading)
            self.voteWorker.addVote(
                pollId: pollId,
                choice: currentChoice,
                completion: { [weak self] (result) in
                    self?.loadingStatus.accept(.loaded)
                    switch result {
                    case .failure(let error):
                        let response = Event.Error.Response(error: error)
                        self?.presenter.presentError(response: response)
                        
                    case .success:
                        self?.pollsFetcher.reloadPolls()
                    }
            })
        }
        
        private func handleRemoveVote(pollId: String) {
            self.loadingStatus.accept(.loading)
            self.voteWorker.removeVote(
                pollId: pollId,
                completion: { [weak self] (result) in
                    self?.loadingStatus.accept(.loaded)
                    switch result {
                        
                    case .failure(let error):
                        let response = Event.Error.Response(error: error)
                        self?.presenter.presentError(response: response)
                        
                    case .success:
                        self?.pollsFetcher.reloadPolls()
                    }
            })
        }
    }
}

extension Polls.Interactor: Polls.BusinessLogic {
    
    public func onViewDidLoad(request: Event.ViewDidLoad.Request) {
        self.observeLoadingStatus()
        self.observePolls()
        self.observeFetcherLoadingStatus()
    }
    
    public func onActionButtonClicked(request: Event.ActionButtonClicked.Request) {
        switch request.actionType {
            
        case .remove:
            self.handleRemoveVote(pollId: request.pollId)
            
        case .submit:
            self.handleAddVote(pollId: request.pollId)
        }
    }
    
    public func onChoiceChanged(request: Event.ChoiceChanged.Request) {
        guard var poll = self.sceneModel.polls.first(where: { (poll) -> Bool in
            return poll.id == request.pollId
        }),
            let pollIndex = self.sceneModel.polls.indexOf(poll),
            poll.choices.contains(where: { (choice) -> Bool in
                return choice.value == request.choice
            }) else { return }
        
        poll.currentChoice = request.choice
        self.sceneModel.polls[pollIndex] = poll
    }
}
