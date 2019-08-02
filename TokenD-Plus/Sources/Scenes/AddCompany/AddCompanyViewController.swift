import UIKit
import RxSwift
import Nuke

public protocol AddCompanyDisplayLogic: class {
    typealias Event = AddCompany.Event
    
    func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel)
    func displayAddCompanyAction(viewModel: Event.AddCompanyAction.ViewModel)
    func displayLoadingStatusDidChange(viewModel: Event.LoadingStatusDidChange.ViewModel)
}

extension AddCompany {
    public typealias DisplayLogic = AddCompanyDisplayLogic
    
    @objc(AddCompanyViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = AddCompany.Event
        public typealias Model = AddCompany.Model
        
        // MARK: - Private properties
        
        private let imageContainer: UIView = UIView()
        private let abbreviationLabel: UILabel = UILabel()
        private let companyLogo: UIImageView = UIImageView()
        private let companyNameLabel: UILabel = UILabel()
        private let addCompanyButton: UIButton = UIButton()
        private let cancelButton: UIButton = UIButton()
        
        private let topInset: CGFloat = 30.0
        private let iconSize: CGFloat = 90.0
        private let buttonWidth: CGFloat = 90.0
        private let buttonHeight: CGFloat = 40.0
        
        private let disposeBag: DisposeBag = DisposeBag()
        
        // MARK: -
        
        deinit {
            self.onDeinit?(self)
        }
        
        // MARK: - Injections
        
        private var interactorDispatch: InteractorDispatch?
        private var routing: Routing?
        private var onDeinit: DeinitCompletion = nil
        
        public func inject(
            interactorDispatch: InteractorDispatch?,
            routing: Routing?,
            onDeinit: DeinitCompletion = nil
            ) {
            
            self.interactorDispatch = interactorDispatch
            self.routing = routing
            self.onDeinit = onDeinit
        }
        
        // MARK: - Overridden
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            
            self.setupView()
            self.setupImageContainer()
            self.setupCompanyImage()
            self.setupCompanyAbbreviationLabel()
            self.setupCompanyNameLabel()
            self.setupAddButton()
            self.setupCancelButton()
            self.setupLayout()
            
            let request = Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }
        }
        
        // MARK: - Private
        
        private func setupView() {
            self.view.backgroundColor = Theme.Colors.contentBackgroundColor
        }
        
        private func setupImageContainer() {
            self.imageContainer.backgroundColor = Theme.Colors.contentBackgroundColor
            self.imageContainer.layer.cornerRadius = self.iconSize / 2
        }
        
        private func setupCompanyImage() {
            self.companyLogo.backgroundColor = Theme.Colors.contentBackgroundColor
            self.companyLogo.clipsToBounds = true
            self.companyLogo.layer.cornerRadius = self.iconSize / 2
        }
        
        private func setupCompanyAbbreviationLabel() {
            self.abbreviationLabel.backgroundColor = Theme.Colors.contentBackgroundColor
            self.abbreviationLabel.layer.cornerRadius = self.iconSize / 2
            self.abbreviationLabel.textAlignment = .center
            self.abbreviationLabel.font = Theme.Fonts.hugeTitleFont
        }
        
        private func setupCompanyNameLabel() {
            self.companyNameLabel.backgroundColor = Theme.Colors.contentBackgroundColor
            self.companyNameLabel.textAlignment = .center
            self.companyNameLabel.font = Theme.Fonts.hugeTitleFont
        }
        
        private func setupAddButton() {
            self.addCompanyButton.backgroundColor = Theme.Colors.accentColor
            self.addCompanyButton.setTitleColor(
                Theme.Colors.textOnAccentColor,
                for: .normal
            )
            self.addCompanyButton.setTitle(
                Localized(.add),
                for: .normal
            )
            self.addCompanyButton.titleLabel?.font = Theme.Fonts.actionButtonFont
            self.addCompanyButton
                .rx
                .tap
                .asDriver()
                .drive(onNext: { [weak self] _ in
                    let request = Event.AddCompanyAction.Request()
                    self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                        businessLogic.onAddCompanyAction(request: request)
                    })
                })
                .disposed(by: self.disposeBag)
        }
        
        private func setupCancelButton() {
            self.cancelButton.backgroundColor = Theme.Colors.contentBackgroundColor
            self.cancelButton.setTitleColor(
                Theme.Colors.accentColor,
                for: .normal
            )
            self.cancelButton.setTitle(
                Localized(.cancel),
                for: .normal
            )
            self.cancelButton.titleLabel?.font = Theme.Fonts.plainTextFont
            self.cancelButton
                .rx
                .tap
                .asDriver()
                .drive(onNext: { [weak self] _ in
                    self?.routing?.onCancel()
                })
                .disposed(by: self.disposeBag)
        }
        
        private func setupLayout() {
            self.view.addSubview(self.imageContainer)
            self.view.addSubview(self.companyNameLabel)
            self.view.addSubview(self.addCompanyButton)
            self.view.addSubview(self.cancelButton)
            
            self.imageContainer.addSubview(self.companyLogo)
            self.imageContainer.addSubview(self.abbreviationLabel)
            
            self.imageContainer.snp.makeConstraints { (make) in
                make.top.equalToSuperview().inset(self.topInset * 2)
                make.centerX.equalToSuperview()
                make.height.width.equalTo(self.iconSize)
            }
            
            self.companyNameLabel.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(20.0)
                make.top.equalTo(self.imageContainer.snp.bottom).offset(self.topInset / 2)
            }
            
            self.addCompanyButton.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.height.equalTo(self.buttonHeight)
                make.width.equalTo(self.buttonWidth)
            }
            
            self.cancelButton.snp.makeConstraints { (make) in
                make.top.equalTo(self.addCompanyButton.snp.bottom).offset(self.topInset / 2)
                make.leading.trailing.equalTo(self.addCompanyButton)
                make.height.equalTo(self.buttonHeight)
                make.width.equalTo(self.buttonWidth)
            }
            
            self.companyLogo.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            self.abbreviationLabel.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}

extension AddCompany.ViewController: AddCompany.DisplayLogic {
    
    public func displayViewDidLoad(viewModel: Event.ViewDidLoad.ViewModel) {
        self.companyNameLabel.text = viewModel.company.name
        switch viewModel.company.logoAppearance {
            
        case .abbreviation(let text):
            self.abbreviationLabel.text = text
            self.abbreviationLabel.isHidden = false
            
        case .logo(let url):
            Nuke.loadImage(with: url, into: self.companyLogo)
            self.abbreviationLabel.isHidden = true
        }
    }
    
    public func displayAddCompanyAction(viewModel: Event.AddCompanyAction.ViewModel) {
        switch viewModel {
            
        case .error(let message):
            self.routing?.onAddActionResult(.error(message))
            
        case .success(let message):
            self.routing?.onAddActionResult(.success(message))
        }
    }
    
    public func displayLoadingStatusDidChange(viewModel: Event.LoadingStatusDidChange.ViewModel) {
        switch viewModel {
        case .loaded:
            self.routing?.hideLoading()
            
        case .loading:
            self.routing?.showLoading()
        }
    }
}
