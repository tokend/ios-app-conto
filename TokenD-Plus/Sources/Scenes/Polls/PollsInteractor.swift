import Foundation
import RxSwift
import RxCocoa

public protocol PollsBusinessLogic {
    typealias Event = Polls.Event
    
    func onViewDidLoad(request: Event.ViewDidLoad.Request)
    func onActionButtonClicked(request: Event.ActionButtonClicked.Request)
    func onChoiceChanged(request: Event.ChoiceChanged.Request)
    func onRefreshInitiated(request: Event.RefreshInitiated.Request)
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
        
        private func updatePolls(polls: [Model.Poll]) {
            if polls.isEmpty {
                self.sceneModel.polls = polls
                self.updateScene()
            } else if self.sceneModel.polls.allSatisfy({ (scenePoll) -> Bool in
                return polls.contains(scenePoll)
            }), polls.allSatisfy({ (newPoll) -> Bool in
                return self.sceneModel.polls.contains(newPoll)
            }) {
                var pollsToBeUpdated: [Model.Poll] = []
                polls.forEach { (newPoll) in
                    if let index = self.sceneModel.polls.indexOf(newPoll) {
                        let scenePoll = self.sceneModel.polls[index]
                        if newPoll.isClosed != scenePoll.isClosed ||
                            newPoll.currentRemoteChoice != scenePoll.currentRemoteChoice {
                            
                            self.sceneModel.polls[index] = newPoll
                            pollsToBeUpdated.append(newPoll)
                        }
                    }
                }
                if !pollsToBeUpdated.isEmpty {
                    let response = Event.PollsDidChange.Response(polls: pollsToBeUpdated)
                    self.presenter.presentPollsDidChange(response: response)
                }
            } else {
                self.sceneModel.polls = polls
                self.updateScene()
            }
        }
        
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
                    self?.updatePolls(polls: polls)
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
        
        private func updatePolls() {
            self.pollsFetcher.reloadPolls()
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
                        self?.pollsFetcher.reloadVotes()
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
        self.handleAddVote(pollId: request.pollId)
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
    
    public func onRefreshInitiated(request: Event.RefreshInitiated.Request) {
        self.pollsFetcher.reloadPolls()
    }
}
