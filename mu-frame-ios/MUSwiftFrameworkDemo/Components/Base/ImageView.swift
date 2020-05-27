//
//  ImageView.swift

//
//  Created by Ilya B Macmini on 11.05.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

@IBDesignable
class ImageView: UIImageView {
    
    @IBInspectable var alwaysTemplate : Bool = false { didSet { updateRenderingMode() } }
    
    @IBInspectable var newTintColor   : UIColor? { didSet { updateTintColor() } }

    private func updateRenderingMode() {
 
        let image = self.image?.withRenderingMode(alwaysTemplate ? .alwaysTemplate : .automatic)
        
        self.image = image
    }
    
    private func updateTintColor() {

        guard let newTintColor = newTintColor else {
            
            return
        }
        
        self.tintColor = newTintColor
    }
}
