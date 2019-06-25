import Foundation
import TokenDSDK
import RxSwift
import RxCocoa

public protocol PollsPollsFetcherProtocol {
    func observePolls() -> Observable<[Polls.Model.Poll]>
    func observeLoadingStatus() -> Observable<Polls.Model.LoadingStatus>
    func reloadPolls()
}

extension Polls {
    public typealias PollsFetcherProtocol = PollsPollsFetcherProtocol
    
    public class PollsFetcher {
        public typealias Model = Polls.Model
        
        // MARK: - Private properties
        
        private var pollsRepo: PollsRepo
        private let polls: BehaviorRelay<[Model.Poll]> = BehaviorRelay(value: [])
        private let loadingStatus: BehaviorRelay<Model.LoadingStatus> = BehaviorRelay(value: .loaded)
        
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        init(pollsRepo: PollsRepo) {
            self.pollsRepo = pollsRepo
        }
        
        // MARK: - Private
        
        private func observeRepoPolls() {
            let pollsObservable = self.pollsRepo.observePolls()
            let votesObservable = self.getVotesObservable()
            Observable.zip(pollsObservable, votesObservable)
                .subscribe(onNext: { [weak self] (pollResources, votes) in
                    let currentTime = Date()
                    let polls = pollResources.compactMap({ (poll) -> Model.Poll? in
                        guard let id = poll.id,
                            let subject = poll.subject,
                            let pollChoices = poll.choices,
                            let outcomeDetails = poll.outcome else {
                                return nil
                        }
                        
                        let pollIsClosed = currentTime > poll.endTime
                        let totalVotes = outcomeDetails.outcome
                            .reduce(0, { (total, pair) -> Int in
                                return total + pair.value
                            })
                        let choices = pollChoices.choices.map({ (choice) -> Model.Poll.Choice in
                            var result: Model.Poll.Choice.Result?
                            if currentTime > poll.endTime {
                                let votesCount = outcomeDetails.outcome["\(choice.number)"] ?? 0
                                result = Model.Poll.Choice.Result(
                                    voteCounts: votesCount,
                                    totalVotes: totalVotes
                                )
                            }
                            return Model.Poll.Choice(
                                name: choice.description,
                                value: choice.number,
                                result: result
                            )
                        })
                        let currentChoice = votes.first(where: { (vote) -> Bool in
                            return vote.id == id
                        })?.choice
                        
                        return Model.Poll(
                            id: id,
                            subject: subject.question,
                            choices: choices,
                            currentChoice: currentChoice,
                            isClosed: pollIsClosed
                        )
                    })
                    self?.polls.accept(polls)
                })
            .disposed(by: self.disposeBag)
        }
        
        private func observeRepoLoadingStatus() {
            self.pollsRepo
                .observeLoadingStatus()
                .subscribe(onNext: { [weak self] (status) in
                    self?.loadingStatus.accept(status.pollsLoadingStatus)
                })
            .disposed(by: self.disposeBag)
        }
        
        private func getVotesObservable() -> Observable<[Model.Vote]> {
            return self.pollsRepo.observeVotes()
                .map { (votesResources) -> [Model.Vote] in
                    return votesResources
                        .compactMap({ (vote) -> Model.Vote? in
                            guard let id = vote.poll?.id else {
                                return nil
                            }
                            let choice = Int(vote.voteData?.singleChoice ?? 0)
                            return Model.Vote(id: id, choice: choice)
                        })
                        .filter({ (vote) -> Bool in
                            vote.choice > 0
                        })
            }
        }
    }
}

extension Polls.PollsFetcher: Polls.PollsFetcherProtocol {
    
    public func observePolls() -> Observable<[Model.Poll]> {
        self.observeRepoPolls()
        return self.polls.asObservable()
    }
    
    public func observeLoadingStatus() -> Observable<Polls.Model.LoadingStatus> {
        return self.loadingStatus.asObservable()
    }
    
    public func reloadPolls() {
        self.pollsRepo.reloadPolls()
    }
}

extension PollsRepo.LoadingStatus {
    var pollsLoadingStatus: Polls.Model.LoadingStatus {
        switch self {
            
        case .loaded:
            return .loaded
            
        case .loading:
            return .loading
        }
    }
}
