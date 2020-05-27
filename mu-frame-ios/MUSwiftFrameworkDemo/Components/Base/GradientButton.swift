//
//  GradientButton.swift

//
//  Created by Dmitry Smirnov on 06.04.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

@IBDesignable
class GradientButton: Button {
    
    @IBInspectable var startColor : UIColor? { didSet { updateGradient() } }
    @IBInspectable var endColor   : UIColor? { didSet { updateGradient() } }
    
    @IBInspectable var startPoint : CGPoint = CGPoint() { didSet { updateGradient() } }
    @IBInspectable var endPoint   : CGPoint = CGPoint() { didSet { updateGradient() } }
    
    override var backgroundColor: UIColor? { get { return .clear } set { } }
    
    override var isEnabled     : Bool { didSet { updateEnabled() } }
    override var isHighlighted : Bool { didSet { updateHighlighted() } }
    
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    
    // MARK: - Private properties
    
    private var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
    
    // MARK: - Private methods
    
    private func updateGradient() {
        
        guard
            
            let startColor = startColor,
            let endColor   = self.endColor ?? startColor.darker(by : 15)
        
        else {
            
            return
        }
        
        gradientLayer.startPoint = CGPoint(x: startPoint.x, y: startPoint.y)
        gradientLayer.endPoint   = CGPoint(x: endPoint.x, y: endPoint.y)
        gradientLayer.colors     = [startColor.cgColor, endColor.cgColor]
    }
    
    private func updateHighlighted() {
        
        guard isEnabled && isHighlighted else {
            
            updateGradient()
            return
        }
        
        guard let highlightedColor = highlightedColor ?? startColor else { return }
        
        gradientLayer.startPoint = CGPoint(x: startPoint.x, y: startPoint.y)
        gradientLayer.endPoint   = CGPoint(x: endPoint.x, y: endPoint.y)
        gradientLayer.colors     = [highlightedColor.cgColor, highlightedColor.cgColor]
    }
    
    private func updateEnabled() {
        
        guard !isEnabled else {

            updateGradient()
            return
        }

        guard let disabledColor = disabledColor ?? startColor?.withAlphaComponent(0.3) else { return }

        gradientLayer.startPoint = CGPoint(x: startPoint.x, y: startPoint.y)
        gradientLayer.endPoint   = CGPoint(x: endPoint.x, y: endPoint.y)
        gradientLayer.colors     = [disabledColor.cgColor, disabledColor.cgColor]
    }
}
