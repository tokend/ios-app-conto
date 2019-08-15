import UIKit

public protocol PhoneNumberDisplayLogic: class {
    typealias Event = PhoneNumber.Event
    
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
        
        private let plusLabel: UILabel = UILabel()
        private let numberField: TextFieldView = TextFieldView()
        private var numberEditingContext: TextEditingContext<String>?
        private let underlineView: UIView = UIView()
        
        private let submitButton: UIButton = UIButton()
        
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
            self.setupPlusLabel()
            self.setupNumberTextField()
            self.setupUnderlineView()
            self.setupSubmitButton()
            self.setupLayout()
        }
        
        // MARK: - Private
        
        private func setupView() {
            self.view.backgroundColor = Theme.Colors.contentBackgroundColor
        }
        
        private func setupPlusLabel() {
            self.plusLabel.backgroundColor = Theme.Colors.contentBackgroundColor
            self.plusLabel.text = "+"
            self.plusLabel.font = Theme.Fonts.largeTitleFont
        }
        
        private func setupNumberTextField() {
            self.numberField.backgroundColor = Theme.Colors.contentBackgroundColor
            
            self.numberEditingContext = 
        }
        
        private func setupUnderlineView() {
            
        }
        
        private func setupSubmitButton() {
            
        }
        
        private func setupLayout() {
            
        }
    }
}

extension PhoneNumber.ViewController: PhoneNumber.DisplayLogic {
    
}
