//
//  MUFormController.swift
//
//  Created by Dmitry Smirnov on 09.04.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - VerifyFieldProtocol

protocol VerifyFieldProtocol {
    
    var value: String { set get }
    
    var isError: Bool   { set get }
    
    var errorMessage: String? { set get }
    
    func setError(on: Bool, message: String?)
}

// MARK: - VerifyObject

struct VerifyObject {
    
    var field: VerifyFieldProtocol
    
    var rules: [MUValidateRule]
    
    var message: String?
}

// MARK: - MUFormController

class MUFormController: MUViewController {
    
    // MARK: - Behavior properties
    
    var isPresented: Bool = false
    
    // MARK: - Public properties
    
    var isValid: Bool { return !hasError }    
    
    weak var submitButton: Button?
    
    weak var continueButton: Button?
    
    // MARK: - Private properties
    
    private var hasError: Bool = false
    
    private var verifyObjects: [VerifyObject] = []
    
    // MARK: - Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(submitButtonTap)))
    }
    
    func addVerify(field: VerifyFieldProtocol?, rules: [MUValidateRule], message: String? = nil) {
        
        guard let field = field else {
            
            return
        }
        
        verifyObjects.append(VerifyObject(field: field, rules: rules, message: message))
    }
    
    func fieldChanged(_ field: TextFieldView) {
        
    }
    
    func fieldBeginEditing(_ field: TextFieldView) {
        
    }
    
    func validateWhenEditing() {
        
        hasError = false
        
        for var object in verifyObjects {
            
            let isValid = MUValidateManager.shared.checkIsValid(value: object.field.value, match: object.rules)
            
            if isValid {
                
                object.field.setError(on: false, message: object.message)
                
            } else {
                
                hasError = true
            }
        }
        
        afterValidate()
    }
    
    func validate() {
        
        hasError = false
        
        for var object in verifyObjects {
            
            let isError = !MUValidateManager.shared.checkIsValid(value: object.field.value, match: object.rules)
            
            object.field.setError(on: isError, message: object.message)
            
            if isError {
                
                hasError = true
            }
        }
        
        if !customValidate() {
            
            hasError = true
        }
        
        afterValidate()
    }
    
    func customValidate() -> Bool {
        
        return true
    }
    
    func afterValidate() {
        
        updateSubmitButton()
    }
    
    func submitForm() {
        
        showPopup(title: "Success", message: "Well done, pal!", buttonTitle: "Yeah")
    }
    
    // MARK: - Private methods
    
    private func getField(after position: Int) -> VerifyFieldProtocol? {
        
        guard position + 1 < verifyObjects.count else {
            
            return nil
        }
        
        return verifyObjects[position + 1].field
    }
    
    @objc private func submitButtonTap() {
        
        validate()
        
        guard isValid else { return }
        
        view.endEditing(true)
        
        submitForm()
    }
    
    private func updateSubmitButton() {
        
        continueButton?.isEnabled = isValid
        
        submitButton?.isEnabled = isValid
    }
}

// MARK: - TextFieldViewDelegate

extension MUFormController: TextFieldViewDelegate {
    
    func textFieldViewChanged(_ textFieldView: TextFieldView) {
        
        validateWhenEditing()
        
        fieldChanged(textFieldView)
    }
    
    func textFieldViewBeginEditing(_ textFieldView: TextFieldView) {
        
        fieldBeginEditing(textFieldView)
    }
    
    func textFieldViewDidEndEditing(_ textFieldView: TextFieldView) {        
        
        validate()
    }
    
    func textFieldViewShouldReturn(_ textFieldView: TextFieldView) {
        
        for (index, object) in verifyObjects.enumerated() {
            
            guard (object.field as? TextFieldView) == textFieldView else {
                
                continue
            }
            
            validate()
            
            if let nextField = getField(after: index) as? TextFieldView {
                
                guard !object.field.isError else { return }
                
                nextField.becomeFirstResponder()
                
            } else {
                
                guard isValid else { return }
                
                view.endEditing(true)
                
                submitForm()
            }
            
            return
        }
    }
}
