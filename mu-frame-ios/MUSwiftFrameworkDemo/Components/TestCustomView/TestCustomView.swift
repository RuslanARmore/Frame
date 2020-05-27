//
//  TestCustomView.swift
//  MUSwiftFramework
//
//  Created by Ilya B Macmini on 17.06.2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - TestCustomView

class TestCustomView: MUCustomView {
    
    // MARK: - Public properties
    
    var butonAction: (() -> Void)?
    
    // MARK: - Private properties
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Private methods
    
    @IBAction private func closeBtnDidTouch(_ sender: UIButton) {
        
        butonAction?()
    }
}
