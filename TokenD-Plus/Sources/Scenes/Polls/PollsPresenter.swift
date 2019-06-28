import Foundation

public protocol PollsPresentationLogic {
    typealias Event = Polls.Event
    
    func presentSceneUpdated(response: Event.SceneUpdated.Response)
    func presentPollsDidChange(response: Event.PollsDidChange.Response)
    func presentError(response: Event.Error.Response)
    func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response)
}

extension Polls {
    public typealias PresentationLogic = PollsPresentationLogic
    
    @objc(PollsPresenter)
    public class Presenter: NSObject {
        
        public typealias Event = Polls.Event
        public typealias Model = Polls.Model
        
        // MARK: - Private properties
        
        private let presenterDispatch: PresenterDispatch
        private let percentFormatter: PercentFormatterProtocol
        
        // MARK: -
        
        public init(
            presenterDispatch: PresenterDispatch,
            percentFormatter: PercentFormatterProtocol
            ) {
            
            self.presenterDispatch = presenterDispatch
            self.percentFormatter = percentFormatter
        }
        
        // MARK: - Private
        
        private func getPollsViewModel(polls: [Model.Poll]) -> [PollCell.ViewModel] {
            return polls.map { (poll) -> Polls.PollCell.ViewModel in
                let subtitle = poll.isClosed ? Localized(.ended_capitalized) : nil
                
                let choiceViewModels = self.getChoiceViewModel(
                    models: poll.choices,
                    currentChoice: poll.currentChoice
                )
                let actionTitle = Localized(.submit_vote)
                let actionState: Model.ActionState
                if poll.currentChoice != nil || poll.isClosed {
                    actionState = .hidden
                } else {
                    actionState = .disabled
                }
                
                return Polls.PollCell.ViewModel(
                    pollId: poll.id,
                    question: poll.subject,
                    subtitle: subtitle,
                    choicesViewModels: choiceViewModels,
                    actionState: actionState,
                    actionTitle: actionTitle
                )
            }
        }
        
        private func getChoiceViewModel(
            models: [Model.Poll.Choice],
            currentChoice: Int?
            ) -> [Polls.PollsChoiceCell.ViewModel] {
            
            return models.map({ (choice) -> Polls.PollsChoiceCell.ViewModel in
                var isSelected = false
                if let currentChoice = currentChoice {
                    isSelected = currentChoice == choice.value
                }
                var resultViewModel: PollsChoiceCell.ViewModel.Result?
                if let result = choice.result {
                    let relation = result.totalVotes != 0 ?
                        Float(result.voteCounts) / Float(result.totalVotes) : 0
                    
                    let percentageText = self.percentFormatter.formatPercantage(
                        percent: relation * 100
                    )
                    let votesText: String
                    if result.voteCounts == 1 {
                        votesText = Localized(
                            .one_vote,
                            replace: [
                               .one_vote_replace_percent: percentageText
                            ]
                        )
                    } else {
                        votesText = Localized(
                            .votes,
                            replace: [
                                .votes_replace_votes_count: result.voteCounts.description,
                                .votes_replace_percent: percentageText
                            ]
                        )
                    }
                    resultViewModel = PollsChoiceCell.ViewModel.Result(
                        votesText: votesText,
                        percentage: relation
                    )
                }
                return Polls.PollsChoiceCell.ViewModel(
                    name: choice.name,
                    choiceValue: choice.value,
                    isSelected: isSelected,
                    result: resultViewModel
                )
            })
        }
    }
}

extension Polls.Presenter: Polls.PresentationLogic {
    
    public func presentSceneUpdated(response: Event.SceneUpdated.Response) {
        let contentViewModel: Model.SceneContentViewModel
        switch response.content {
            
        case .error(let error):
            contentViewModel = .empty(error.localizedDescription)
            
        case .polls(let responsePolls):
            if responsePolls.isEmpty {
                contentViewModel = .empty(Localized(.there_is_no_any_poll_for_chosen_company))
            } else {
                let polls = self.getPollsViewModel(polls: responsePolls)
                contentViewModel = .polls(polls)
            }
        }
        let viewModel = Event.SceneUpdated.ViewModel(
            content: contentViewModel
        )
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displaySceneUpdated(viewModel: viewModel)
        }
    }
    
    public func presentPollsDidChange(response: Event.PollsDidChange.Response) {
        let polls = self.getPollsViewModel(polls: response.polls)
        let viewModel = Event.PollsDidChange.ViewModel(polls: polls)
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayPollsDidChange(viewModel: viewModel)
        }
    }
    
    public func presentError(response: Event.Error.Response) {
        let viewModel = Event.Error.ViewModel(
            message: response.error.localizedDescription
        )
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayError(viewModel: viewModel)
        }
    }
    
    public func presentLoadingStatusDidChange(response: Event.LoadingStatusDidChange.Response) {
        let viewModel = response
        self.presenterDispatch.display { (displayLogic) in
            displayLogic.displayLoadingStatusDidChange(viewModel: viewModel)
        }
    }
}
