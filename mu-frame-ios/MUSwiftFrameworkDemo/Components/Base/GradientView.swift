//
//  GradientView.swift

//
//  Created by Dmitry Smirnov on 19.04.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

class GradientView: View {
    
    @IBInspectable var startColor : UIColor? { didSet { updateGradient() } }
    @IBInspectable var endColor   : UIColor? { didSet { updateGradient() } }
    
    @IBInspectable var startPoint : CGPoint = CGPoint() { didSet { updateGradient() } }
    @IBInspectable var endPoint   : CGPoint = CGPoint() { didSet { updateGradient() } }
    
    override var backgroundColor: UIColor? { get { return .clear } set { } }
    
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
}
