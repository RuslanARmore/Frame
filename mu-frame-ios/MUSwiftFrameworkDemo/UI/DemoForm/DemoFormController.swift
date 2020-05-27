//
//  DemoFormController.swift
//  MUSwiftFramework
//
//  Created by Dmitry Smirnov on 07/03/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - DemoFormController

class DemoFormController: FormController {
    
    // MARK: - Override properties
    
    override class var storyboardName: String { return "DemoForm" }
    
    // MARK: - Private properties
    
    @IBOutlet private weak var emailField: TextFieldView!
    
    @IBOutlet private weak var passwordField: TextFieldView!
    
    @IBOutlet private weak var buttonContainer: UIView! { didSet { keyboardContainer = buttonContainer } }
    
    @IBOutlet private weak var submitButtonProvider: Button! { didSet { submitButton = submitButtonProvider } }
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        addVerify(field: emailField, rules: [.required, .email])
        
        addVerify(field: passwordField, rules: [.required])
        
        validate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        emailField.becomeFirstResponder()
    }
}
