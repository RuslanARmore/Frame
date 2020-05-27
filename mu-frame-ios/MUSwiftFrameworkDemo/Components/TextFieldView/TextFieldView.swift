//
//  TextFieldView.swift

//
//  Created by Dmitry Smirnov on 06.04.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - TextFieldViewDelegate

@objc protocol TextFieldViewDelegate: class {
    
    @objc optional func textFieldViewBeginEditing(_ textFieldView: TextFieldView)
    @objc optional func textFieldViewDidEndEditing(_ textFieldView: TextFieldView)
    @objc optional func textFieldViewShouldReturn(_ textFieldView: TextFieldView)
    @objc optional func textFieldViewChanged(_ textFieldView: TextFieldView)
    @objc optional func textFieldViewButtonDidTap(_ textFieldView: TextFieldView)
}

// MARK: - TextFieldView

@IBDesignable
class TextFieldView: MUCustomView, VerifyFieldProtocol {
    
    // MARK: - State
    
    enum State {
        
        case inactive, active
    }
    
    @IBInspectable var identifier: String? { didSet { accessibilityIdentifier = identifier } }
    
    @IBInspectable var firstColorScheme: UIColor? = .clear
    
    @IBInspectable var firstInactiveColorScheme: UIColor? { didSet { updateFirstInactiveColorScheme() } }
    
    @IBInspectable var secondColorScheme: UIColor? { didSet { updateSecondColorScheme() } }
    
    @IBInspectable var labelColor: UIColor? { didSet { updateLabelColor() } }
    
    @IBInspectable var textColor: UIColor? { didSet { updateTextColor() } }
    
    @IBInspectable var caretColor: UIColor? { didSet { updateCaretColor() } }
    
    @IBInspectable var errorMessage: String? { didSet { updateErrorMessage() } }
    
    @IBInspectable var errorMessageBackColor: UIColor? { didSet { updateErrorMessageBackColor() } }
    
    @IBInspectable var placeholder: String? { didSet { updatePlaceholder() } }
    
    @IBInspectable var note: String? { didSet { updateNote() } }
    
    @IBInspectable var isPassword: Bool = false { didSet { valueTextfield.isSecureTextEntry = isPassword } }
    
    @IBInspectable var isEmail: Bool = false { didSet { updateKeyboardType() } }
    
    @IBInspectable var isPhone: Bool = false { didSet { updateKeyboardType() } }
    
    @IBInspectable var autocapitalizationType: Int = 0 { didSet { updateAutocapitalizationType() } }
    
    @IBInspectable var clearsOnActive: Bool = false
    
    @IBInspectable var value: String {
        
        set { updateValue(newValue) }
        get { return valueTextfield.text ?? "" }
    }
    
    @IBInspectable var numbersOnly: Bool = false { didSet { updateKeyboardType() } }
    
    @IBInspectable var hasButton: Bool = false { didSet { updateButtonVisibility() } }
    
    @IBInspectable var buttonImage: UIImage? { didSet { button.setImage(buttonImage, for: .normal) } }
    
    @IBInspectable var units: String? { didSet { updateUnits() } }
    
    @IBInspectable var showUnitsLeft: Bool = false { didSet { updateUnits() } }
    
    @IBInspectable var showPlaceholderOnTop: Bool = true { didSet { updatePlaceholder() } }
    
    // MARK: - Public properties
    
    @IBOutlet weak var delegate: TextFieldViewDelegate?
    
    var isEditing: Bool { return valueTextfield.isEditing }
    
    var isError : Bool = false { didSet { updateError() } }
    
    var isEmpty : Bool { return value == "" }
    
    var isEnabled : Bool = true { didSet { valueTextfield.isEnabled = isEnabled } }
    
    // MARK: - Private properties
    
    private var state: State = .inactive { didSet { updateState() } }
    
    private static let marginLeft: CGFloat = 15

    @IBOutlet private weak var textfieldContainer: View!
    
    @IBOutlet private weak var topPlaceholderLabel: Label!
    
    @IBOutlet private weak var placeholderLabel: Label!
    
    @IBOutlet private weak var bottomLabel: Label!
    
    @IBOutlet private weak var valueTextfield: TextField!
    
    @IBOutlet private weak var valueTextFieldLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var errorContainer: View!
    
    @IBOutlet private weak var appendErrorContainer: View!
    
    @IBOutlet private weak var errorLabel: Label!
    
    @IBOutlet private weak var unitsLabel: Label!
    
    @IBOutlet private weak var unitsLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var button: UIButton!
    
    private var cachedValue: String = ""
    
    private var oldText: String = ""
    
    // MARK: - Override methods
    
    override func initSetup() {
        super.initSetup()
        
        valueTextfield.accessibilityIdentifier = identifier ?? placeholder
    
        updateNote()
        
        updateErrorMessage()
    }
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        
        return valueTextfield.becomeFirstResponder()
    }
    
    @discardableResult override func resignFirstResponder() -> Bool {
        
        state = .inactive
        
        return valueTextfield.resignFirstResponder()
    }
    
    // MARK: - VerifyFieldProtocol
    
    func setError(on: Bool, message: String?) {
        
        isError = on
        
        if isError, let message = message {
            
            errorMessage = message
        }
    }
    
    // MARK: - Private methods
    
    private func updateFirstInactiveColorScheme() {
        
        textfieldContainer.borderColor = firstInactiveColorScheme ?? .clear
    }
    
    private func updateSecondColorScheme() {
        
        textfieldContainer.backgroundColor = secondColorScheme
    }
    
    private func updateLabelColor() {
        
        guard let labelColor = labelColor else { return }
        
        placeholderLabel.setAttributedText(color: labelColor)
        
        topPlaceholderLabel.setAttributedText(color: labelColor)
        
        unitsLabel.setAttributedText(color: labelColor)
        
        bottomLabel.setAttributedText(color: labelColor)
    }
    
    private func updateTextColor() {
        
        valueTextfield.textColor = textColor
    }
    
    private func updateCaretColor() {
        
        guard let color = caretColor else { return }
        
        valueTextfield.tintColor = color
    }
    
    @IBAction func textfieldChanged(_ sender: Any) {
        
        errorMessage = ""
        
        checkForExtraSpaceAfterPasting()
        
        updateUnits()
        
        delegate?.textFieldViewChanged?(self)
    }
    
    @IBAction func textfieldContainerTap(_ sender: Any) {
        
        state = .active
        
        valueTextfield.becomeFirstResponder()
    }
    
    @IBAction func buttonTap(_ sender: Any) {
        
        delegate?.textFieldViewButtonDidTap?(self)
    }
    
    private func updateValue(_ value: String) {
        
        valueTextfield.text = value
        
        updateStateValue()
        
        updateUnits()
    }
    
    private func updateStateValue() {
        
        state = valueTextfield.isEditing ? .active : .inactive
    }
    
    private func updateBorderColor(state: State) {
        
        guard let firstInactiveColorScheme = self.firstInactiveColorScheme else { return }
        
        switch state {
            
        case .inactive : textfieldContainer.borderColor = firstInactiveColorScheme
        case .active   : textfieldContainer.borderColor = firstColorScheme
        }
    }
    
    private func updateState() {
        
        UIView.animate(
            
            withDuration : 0.3,
            delay        : 0,
            options      : [.beginFromCurrentState],
            animations   : { [weak self] in
            
                guard let state = self?.state, let isEmpty = self?.isEmpty else { return }
                
                switch state {
                    
                case .inactive:
                    
                    self?.topPlaceholderLabel.alpha = isEmpty ? 0 : 1
                    self?.placeholderLabel.alpha    = isEmpty ? 1 : 0
                    self?.valueTextfield.alpha      = isEmpty ? 0 : 1
                    
                case .active:
                    
                    self?.topPlaceholderLabel.alpha = 1
                    self?.placeholderLabel.alpha    = 0
                    self?.valueTextfield.alpha      = 1
                }
                
                self?.updateBorderColor(state: state)
            }
        )
    }
    
    private func updateError() {
        
        let showError = isError && !isEmpty
        
        if showError {
            
            textfieldContainer.borderColor = UIColor.errorColor()
            
        } else {
            
            textfieldContainer.borderColor = state == .active ? firstColorScheme : (firstInactiveColorScheme ?? firstColorScheme)
        }
        
        textfieldContainer.borderWidth = 1
        
        updateErrorMessageVisibility()
    }
    
    private func updateErrorMessage() {
        
        errorLabel.aText = errorMessage ?? ""
        
        if errorMessage != "" {
            
            isError = true
        }
        
        updateErrorMessageVisibility()
    }
    
    private func updateErrorMessageBackColor() {
        
        guard let color = errorMessageBackColor else { return }
        
        errorContainer.backgroundColor       = color
        appendErrorContainer.backgroundColor = color
    }
    
    private func updateErrorMessageVisibility() {
        
        if !isEmpty && (errorMessage ?? "") != "" {
            
            errorContainer.alpha = 1
            
        } else {
            
            errorContainer.alpha = 0
        }
    }
    
    private func updatePlaceholder() {
        
        topPlaceholderLabel.aText = showPlaceholderOnTop ? (placeholder ?? "") : ""
        
        placeholderLabel.aText = placeholder ?? ""
    }
    
    private func updateNote() {
        
        if let note = note {
            
            bottomLabel.aText = note
            bottomLabel.isHidden = false
            
        } else {
            
            bottomLabel.isHidden = true
        }
    }
    
    private func updateKeyboardType() {
        
        if numbersOnly {
            
            valueTextfield.keyboardType = .decimalPad
            
            addReturnButtonToolbar()
            
        } else if isPhone {
            
            valueTextfield.keyboardType = .phonePad
            
            addReturnButtonToolbar()
            
        } else if isEmail {
            
            valueTextfield.keyboardType = .emailAddress
            
        } else {
            
            valueTextfield.keyboardType = .default
        }
    }
    
    private func addReturnButtonToolbar() {
        
        let flexibleSpace = UIBarButtonItem(
            
            barButtonSystemItem : .flexibleSpace,
            target              : nil,
            action              : nil
        )
        
        let returnButton = UIBarButtonItem(
            
            barButtonSystemItem : .done,
            target              : self,
            action              : #selector(returnButtonDidTouch)
        )
        
        let toolbar = UIToolbar()
        toolbar.setItems([flexibleSpace, returnButton], animated: false)
        toolbar.sizeToFit()
        
        valueTextfield.inputAccessoryView = toolbar
    }
    
    @objc private func returnButtonDidTouch() {
        
        delegate?.textFieldViewShouldReturn?(self)
    }
    
    private func updateAutocapitalizationType() {
        
        switch autocapitalizationType {
        
        case 0: valueTextfield.autocapitalizationType = .none
        case 1: valueTextfield.autocapitalizationType = .words
        case 2: valueTextfield.autocapitalizationType = .sentences
        case 3: valueTextfield.autocapitalizationType = .allCharacters
        default: valueTextfield.autocapitalizationType = .none
        }
    }
    
    private func updateButtonVisibility() {
        
        valueTextfield.setConstraint(type: .trailing, value: hasButton ? button.frame.width : 15)
        
        button.isHidden = hasButton == false
    }
    
    private func checkForExtraSpaceAfterPasting() {
        
        var text = valueTextfield.text ?? ""
        
        let isPastMoreThenOneChar = text.count - oldText.count > 1
        
        guard isPastMoreThenOneChar, text.last == " " else {
            
            oldText = text
            
            return
        }
        
        text.removeLast()
        
        valueTextfield.text = text
        
        oldText = text
    }
    
    private func updateUnits() {
        
        guard let units = units, units != "" else {
            
            return unitsLabel.isHidden = true
        }
        
        unitsLabel.aText = units
        
        unitsLabel.isHiddenWithAnimate = isEmpty && state == .inactive
        
        if showUnitsLeft {            
            
            let unitsTextWidth = unitsLabel.attributedText?.size().width ?? 0
            
            let valueTextMarginLeft: CGFloat = 5
            
            valueTextFieldLeadingConstraint.constant = TextFieldView.marginLeft + unitsTextWidth + valueTextMarginLeft
            
            unitsLeadingConstraint.constant = TextFieldView.marginLeft
            
        } else {
            
            let valueTextWidth = valueTextfield.attributedText?.size().width ?? 0
            
            let valueTextMarginLeft: CGFloat = 5
            
            unitsLeadingConstraint.constant = TextFieldView.marginLeft + valueTextWidth + valueTextMarginLeft
        }
    }
}

// MARK: - UITextFieldDelegate

extension TextFieldView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if clearsOnActive {
            
            cachedValue = valueTextfield.text ?? ""
            
            valueTextfield.text = ""
        }
        
        state = .active
     
        isError = false
        
        errorMessage = ""
        
        updateUnits()
        
        delegate?.textFieldViewBeginEditing?(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if clearsOnActive && valueTextfield.text ?? "" == "" {
            
            valueTextfield.text = cachedValue
        }
        
        updateStateValue()
        
        updateUnits()
        
        delegate?.textFieldViewDidEndEditing?(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        delegate?.textFieldViewShouldReturn?(self)
        
        return true
    }
}
