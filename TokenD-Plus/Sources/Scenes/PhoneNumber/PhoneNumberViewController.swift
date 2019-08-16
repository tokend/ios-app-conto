import UIKit
import RxSwift

public protocol PhoneNumberDisplayLogic: class {
    typealias Event = PhoneNumber.Event
 
    func displaySetNumberAction(viewModel: Event.SetNumberAction.ViewModel)
}

extension PhoneNumber {
    public typealias DisplayLogic = PhoneNumberDisplayLogic
    
    @objc(PhoneNumberViewController)
    public class ViewController: UIViewController {
        
        public typealias Event = PhoneNumber.Event
        public typealias Model = PhoneNumber.Model
        
        // MARK: -
        
        deinit {
            self.onDeinit?(self)
        }
        
        // MARK: - Private properties
        
        private let hintLabel: UILabel = UILabel()
        private let plusLabel: UILabel = UILabel()
        private let numberField: TextFieldView = TextFieldView()
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
            self.setupHintLabel()
            self.setupPlusLabel()
            self.setupNumberTextField()
            self.setupUnderlineView()
            self.setupSubmitButton()
            self.setupLayout()
            
            self.observeKeyboard()
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
            self.hintLabel.text = Localized(.set_phone_number_hint)
            self.hintLabel.font = Theme.Fonts.plainTextFont
            self.hintLabel.numberOfLines = 0
        }
        
        private func setupPlusLabel() {
            self.plusLabel.backgroundColor = Theme.Colors.contentBackgroundColor
            self.plusLabel.text = "+"
            self.plusLabel.font = Theme.Fonts.largeTitleFont
        }
        
        private func setupNumberTextField() {
            self.numberField.backgroundColor = Theme.Colors.contentBackgroundColor
            self.numberField.placeholder = Localized(.phone_number)
            let phoneNumberFormatter = PhoneNumberFormatter()
            self.numberEditingContext = TextEditingContext(
                textInputView: self.numberField,
                valueFormatter: phoneNumberFormatter,
                callbacks: TextEditingContext.Callbacks(
                    onInputValue: { [weak self] (value) in
                        let request = Event.NumberEdited.Request(number: value)
                        self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                            businessLogic.onNumberEdited(request: request)
                        })
                    }
            ))
            self.numberField.keyboardType = .phonePad
            _ = self.numberField.becomeFirstResponder()
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
            self.submitButton.setTitle(
                Localized(.set_phone_number),
                for: .normal
            )
            self.submitButton.titleLabel?.font = Theme.Fonts.actionButtonFont
            self.submitButton
                .rx
                .tap
                .asDriver()
                .drive(onNext: { [weak self] (_) in
                    let request = Event.SetNumberAction.Request()
                    self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                        businessLogic.onSetNumberAction(request: request)
                    })
                })
                .disposed(by: self.disposeBag)
            
        }
        
        private func setupLayout() {
            self.view.addSubview(self.hintLabel)
            self.view.addSubview(self.plusLabel)
            self.view.addSubview(self.numberField)
            self.view.addSubview(self.underlineView)
            self.view.addSubview(self.submitButton)
            
            
            self.hintLabel.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(self.sideInset)
                make.top.equalToSuperview().inset(self.topInset * 3)
            }
            
            self.plusLabel.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().inset(self.sideInset)
                make.centerY.equalTo(self.numberField)
            }
            
            self.numberField.snp.makeConstraints { (make) in
                make.leading.equalTo(self.plusLabel.snp.trailing).offset(self.sideInset/2)
                make.trailing.equalToSuperview().inset(self.sideInset)
                make.top.equalTo(self.hintLabel.snp.bottom).offset(self.topInset * 3)
                make.height.equalTo(35.0)
            }
            
            self.underlineView.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(self.sideInset)
                make.top.equalTo(self.numberField.snp.bottom).offset(self.topInset / 2)
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

extension PhoneNumber.ViewController: PhoneNumber.DisplayLogic {
    
    public func displaySetNumberAction(viewModel: Event.SetNumberAction.ViewModel) {
        switch viewModel {
            
        case .error(let message):
            self.routing?.showError(message)
            
        case .success(let message):
            self.routing?.showMessage(message)
        }
    }
}
