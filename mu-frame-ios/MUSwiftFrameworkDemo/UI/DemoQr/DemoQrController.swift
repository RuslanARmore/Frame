//
//  DemoQrController.swift
//  MUSwiftFramework
//
//  Created by Ilya B Macmini on 05/08/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

class DemoQrController: FormController {
    
    // MARK: - Override properties
    
    override class var storyboardName: String { return "DemoQr" }
    
    // MARK: - Private properties
    
    @IBOutlet private weak var qrCodeImageView: UIImageView!
    
    @IBOutlet private weak var textToQrField: TextFieldView!
    
    @IBOutlet private weak var submitButtonProvider: Button! { didSet { submitButton = submitButtonProvider } }
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        addVerify(field: textToQrField, rules: [.required])
        
        validate()
    }
    
    override func submitForm() {
        
        generateQrCode()
    }
    
    // MAR: - Private methods
    
    @IBAction private func scanQrCodeBtnDidTouch(_ sender: Button) {
        
        readQrCode()
    }
    
    private func generateQrCode() {
        
        let textToQrCode = textToQrField.value
        
        if let qrCodeImage = MUQrCodeManager.generateQRCode(
            
            from: textToQrCode,
            size: qrCodeImageView.frame.size
        ) {
            
            qrCodeImageView.image = qrCodeImage
            
        } else {
            
            Log.error("Failed to generate QR code image for string: \(textToQrCode)")
        }
    }
    
    private func readQrCode() {
        
        MUQrCodeManager.read(for: self, descriptionText: "Scan QR code") { [weak self] result in
            
            self?.showPopup(title: "QR code output", message:result ?? "nil")
        }
    }
}
