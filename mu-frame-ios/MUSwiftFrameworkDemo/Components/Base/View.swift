//
//  View.swift

//
//  Created by Dmitry Smirnov on 26.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

@IBDesignable
class View: UIView {
    
    @IBInspectable var clearBackgroundInRuntime: Bool = false
    
    @IBInspectable var isRounded: Bool = false { didSet { updateRounded() } }
    
    @IBInspectable var maskedCornerRadius: CGFloat = 0 { didSet { updateLayerMask() } }
    
    @IBInspectable var roundedTopLeftCorner: Bool = false { didSet { updateLayerMask() } }
    
    @IBInspectable var roundedTopRightCorner: Bool = false { didSet { updateLayerMask() } }
    
    @IBInspectable var roundedBottomLeftCorner: Bool = false { didSet { updateLayerMask() } }
    
    @IBInspectable var roundedBottomRightCorner: Bool = false { didSet { updateLayerMask() } }
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateRounded()
        
        #if !TARGET_INTERFACE_BUILDER
        
        updateBackground()
        
        #endif
    }
    
    // MARK: - Private methods
    
    private func updateBackground() {
        
        if clearBackgroundInRuntime {
            
            backgroundColor = .clear
        }
    }
    
    private func updateRounded() {
        
        if isRounded {
            
            cornerRadius = frame.height / 2
        }
    }
    
    private func updateLayerMask() {
        
        var corners: UIRectCorner = []
        
        if roundedTopLeftCorner     { corners = corners.union(.topLeft) }
        if roundedTopRightCorner    { corners = corners.union(.topRight) }
        if roundedBottomLeftCorner  { corners = corners.union(.bottomLeft) }
        if roundedBottomRightCorner { corners = corners.union(.bottomRight) }
        
        masked(corners: corners, radius: maskedCornerRadius)
    }
}
