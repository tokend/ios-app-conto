import UIKit
import RxSwift

public protocol PhoneNumberDisplayLogic: class {
    typealias Event = Identity.Event
 
    func displaySetNumberAction(viewModel: Event.SetNumberAction.ViewModel)
    func displaySceneUpdated(viewModel: Event.SceneUpdated.ViewModel)
    func displayLoadingStatusDidChange(viewModel: Event.LoadingStatusDidChange.ViewModel)
    func displayError(viewModel: Event.Error.ViewModel)
}

extension Identity {
    public typealias DisplayLogic = PhoneNumberDisplayLogic
    
    @objc(PhoneNumberViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = Identity.Event
        public typealias Model = Identity.Model
        
        // MARK: -
        
        deinit {
            self.onDeinit?(self)
        }
        
        // MARK: - Private properties
        
        private let hintLabel: UILabel = UILabel()
        private let prefixLabel: UILabel = UILabel()
        private let valueField: TextFieldView = TextFieldView()
        private var numberEditingContext: TextEditingContext<String>?
        private let underlineView: UIView = UIView()
        
        private let submitButton: UIButton = UIButton()
        
        private let disposeBag: DisposeBag = DisposeBag()
        
        private let sideInset: CGFloat = 15.0
        private let topInset: CGFloat = 10.0
        private let buttonHeight: CGFloat = 45.0
        
        private var viewDidAppear: Bool = false
        
        // MARK: - Injections
        
        private var interactorDispatch: InteractorDispatch?
        private var viewConfig: Model.ViewConfig = Model.ViewConfig(
            hint: "",
            prefix: "",
            placeholder: "",
            keyboardType: .default,
            valueFormatter: PlainTextValueFormatter()
        )
        private var routing: Routing?
        private var onDeinit: DeinitCompletion = nil
        
        public func inject(
            interactorDispatch: InteractorDispatch?,
            viewConfig: Model.ViewConfig,
            routing: Routing?,
            onDeinit: DeinitCompletion = nil
            ) {
            
            self.interactorDispatch = interactorDispatch
            self.viewConfig = viewConfig
            self.routing = routing
            self.onDeinit = onDeinit
        }
        
        // MARK: - Overridden
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            
            self.setupView()
            self.setupHintLabel()
            self.setupPrefixLabel()
            self.setupNumberTextField()
            self.setupUnderlineView()
            self.setupSubmitButton()
            self.setupLayout()
            
            self.observeKeyboard()
            
            let request = Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                businessLogic.onViewDidLoad(request: request)
            })
        }
        
        public override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            self.viewDidAppear = true
        }
        
        // MARK: - Private
        
        private func observeKeyboard() {
            let keyboardObserver = KeyboardObserver(
                self,
                keyboardWillChange: { [weak self] (attributes) in
                    guard let strongSelf = self else {
                        return
                    }
                    let keyboardHeight = attributes.heightIn(view: strongSelf.view)
                    if attributes.showingIn(view: strongSelf.view) {
                        strongSelf.submitButton.snp.remakeConstraints { (make) in
                            make.leading.trailing.equalToSuperview()
                            make.bottom.equalToSuperview().inset(keyboardHeight)
                            make.height.equalTo(strongSelf.buttonHeight)
                        }
                    } else {
                        strongSelf.submitButton.snp.remakeConstraints { (make) in
                            make.leading.trailing.equalToSuperview()
                            make.bottom.equalTo(strongSelf.view.safeArea.bottom)
                            make.height.equalTo(strongSelf.buttonHeight)
                        }
                    }
                    
                    if strongSelf.viewDidAppear {
                        UIView.animate(withKeyboardAttributes: attributes, animations: {
                            strongSelf.view.layoutIfNeeded()
                        })
                    }
            })
            KeyboardController.shared.add(observer: keyboardObserver)
        }
        
        private func setupView() {
            self.view.backgroundColor = Theme.Colors.contentBackgroundColor
        }
        
        private func setupHintLabel() {
            self.hintLabel.backgroundColor = Theme.Colors.contentBackgroundColor
            self.hintLabel.text = self.viewConfig.hint
            self.hintLabel.font = Theme.Fonts.plainTextFont
            self.hintLabel.numberOfLines = 0
        }
        
        private func setupPrefixLabel() {
            self.prefixLabel.backgroundColor = Theme.Colors.contentBackgroundColor
            self.prefixLabel.text = self.viewConfig.prefix
            self.prefixLabel.font = Theme.Fonts.largeTitleFont
        }
        
        private func setupNumberTextField() {
            self.valueField.backgroundColor = Theme.Colors.contentBackgroundColor
            self.valueField.placeholder = self.viewConfig.placeholder
            self.numberEditingContext = TextEditingContext(
                textInputView: self.valueField,
                valueFormatter: self.viewConfig.valueFormatter,
                callbacks: TextEditingContext.Callbacks(
                    onInputValue: { [weak self] (value) in
                        let request = Event.ValueEdited.Request(value: value)
                        self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                            businessLogic.onValueEdited(request: request)
                        })
                    }
            ))
            self.valueField.keyboardType = self.viewConfig.keyboardType
            _ = self.valueField.becomeFirstResponder()
        }
        
        private func setupUnderlineView() {
            self.underlineView.backgroundColor = Theme.Colors.separatorOnContentBackgroundColor
        }
        
        private func setupSubmitButton() {
            self.submitButton.backgroundColor = Theme.Colors.accentColor
            self.submitButton.setTitleColor(
                Theme.Colors.textOnAccentColor,
                for: .normal
            )
            self.submitButton.titleLabel?.font = Theme.Fonts.actionButtonFont
            self.submitButton
                .rx
                .tap
                .asDriver()
                .drive(onNext: { [weak self] (_) in
                    let request = Event.Action.Request()
                    self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                        businessLogic.onAction(request: request)
                    })
                })
                .disposed(by: self.disposeBag)
            
        }
        
        private func setupLayout() {
            self.view.addSubview(self.hintLabel)
            self.view.addSubview(self.prefixLabel)
            self.view.addSubview(self.valueField)
            self.view.addSubview(self.underlineView)
            self.view.addSubview(self.submitButton)
            
            
            self.hintLabel.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(self.sideInset)
                make.top.equalToSuperview().inset(self.topInset * 3)
            }
            
            self.prefixLabel.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().inset(self.sideInset)
                make.centerY.equalTo(self.valueField)
            }
            
            self.valueField.snp.makeConstraints { (make) in
                make.leading.equalTo(self.prefixLabel.snp.trailing).offset(self.sideInset/2)
                make.trailing.equalToSuperview().inset(self.sideInset)
                make.top.equalTo(self.hintLabel.snp.bottom).offset(self.topInset * 3)
                make.height.equalTo(35.0)
            }
            
            self.underlineView.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(self.sideInset)
                make.top.equalTo(self.valueField.snp.bottom).offset(self.topInset / 2)
                make.height.equalTo(1.5)
            }
            
            self.submitButton.snp.remakeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(self.view.safeArea.bottom)
                make.height.equalTo(self.buttonHeight)
            }
        }
    }
}

extension Identity.ViewController: Identity.DisplayLogic {
    
    public func displaySetNumberAction(viewModel: Event.SetNumberAction.ViewModel) {
        switch viewModel {
            
        case .error(let message):
            self.routing?.hideLoading()
            self.routing?.showError(message)
            
        case .success(let message):
            self.routing?.hideLoading()
            self.routing?.showMessage(message)
            
        case .loading:
            self.routing?.showLoading()
            
        case .loaded:
            self.routing?.hideLoading()
        }
    }
    
    public func displaySceneUpdated(viewModel: Event.SceneUpdated.ViewModel) {
        self.submitButton.setTitle(
            viewModel.buttonAppearence.title,
            for: .normal
        )
        if viewModel.buttonAppearence.isEnabled {
            self.submitButton.isEnabled = true
            self.submitButton.backgroundColor = Theme.Colors.accentColor
        } else {
            self.submitButton.isEnabled = false
            self.submitButton.backgroundColor = Theme.Colors.disabledActionButtonColor
        }
        if viewModel.value != self.valueField.text {
            self.valueField.text = viewModel.value
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
    
    public func displayError(viewModel: Event.Error.ViewModel) {
        self.routing?.showError(viewModel.error)
    }
}
