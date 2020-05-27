//
//  Label.swift

//
//  Created by Dmitry Smirnov on 26.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

@IBDesignable
class Label: UILabel {
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if let attributedText = attributedText {
            
            aText = attributedText.string.localize
        }
    }
}
