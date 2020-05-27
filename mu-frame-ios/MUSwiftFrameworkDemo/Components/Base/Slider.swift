//
//  Slider.swift

//
//  Created by Maxim Aliev on 24/07/2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

@IBDesignable
class Slider: UIControl {
    
    // MARK: - Public properties
    
    @IBInspectable var trackColor                : UIColor? { didSet { trackLayer.setNeedsDisplay() } }
    @IBInspectable var trackBorderColor          : UIColor? { didSet { trackLayer.setNeedsDisplay() } }
    @IBInspectable var trackHighlightColor       : UIColor? { didSet { trackLayer.setNeedsDisplay() } }
    @IBInspectable var trackBorderHighlightColor : UIColor? { didSet { trackLayer.setNeedsDisplay() } }
    @IBInspectable var thumbColor                : UIColor? { didSet { thumbLayer.setNeedsDisplay() } }
    @IBInspectable var thumbBorderColor          : UIColor? { didSet { thumbLayer.setNeedsDisplay() } }
    @IBInspectable var thumbShadowColor          : UIColor? { didSet { thumbLayer.setNeedsDisplay() } }
    
    @IBInspectable var trackHeight      : CGFloat = 8 { didSet { trackLayer.setNeedsDisplay() } }
    @IBInspectable var trackBorderWidth : CGFloat = 2 { didSet { trackLayer.setNeedsDisplay() } }
    @IBInspectable var thumbBorderWidth : CGFloat = 3 { didSet { thumbLayer.setNeedsDisplay() } }
    
    @IBInspectable var minValue : CGFloat = 1  { didSet { updateLayerFrames() } }
    @IBInspectable var maxValue : CGFloat = 20 { didSet { updateLayerFrames() } }
    @IBInspectable var value    : CGFloat = 4  { didSet { updateLayerFrames() } }
    @IBInspectable var step     : CGFloat = 1
    
    var thumbCenterPoint: CGPoint { return thumbLayer.position }
    
    // MARK: - Private properties
    
    private let trackLayer = SliderTrackLayer()
    private let thumbLayer = SliderThumbLayer()
    
    private var previousLocation = CGPoint()
    
    private var initialized: Bool = false
    
    // MARK: - Override properties
    
    override var frame: CGRect { didSet { updateLayerFrames() } }
    
    // MARK: - Override methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Public methods
    
    func position(for value: CGFloat) -> CGFloat {
        
        let ratio = (round(value) - minValue) / (maxValue - minValue)
        
        return (bounds.width - bounds.height) * ratio + bounds.height / 2
    }
    
    func updateLayerFrames() {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = CGRect(x: 0, y: (bounds.height - trackHeight) / 2, width: bounds.width, height: trackHeight)
        
        thumbLayer.frame = CGRect(x: position(for: value) - bounds.height / 2, y: 0, width: bounds.height, height: bounds.height)
        
        trackLayer.setNeedsDisplay()
        thumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    // MARK: - UIControl methods
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        previousLocation = touch.location(in: self)
        
        if thumbLayer.frame.contains(previousLocation) {
            thumbLayer.highlighted = true
        }
        
        return thumbLayer.highlighted
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        
        let location      = touch.location(in: self)
        let deltaLocation = location.x - previousLocation.x
        let deltaValue    = (maxValue - minValue) * deltaLocation / (bounds.width - bounds.height)
        
        if abs(deltaValue) >= step {
            
            previousLocation = location
            
            if thumbLayer.highlighted {
                
                value += deltaValue
                value = min(max(value, minValue), maxValue)
                
                sendActions(for: .valueChanged)
            }
        }
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        thumbLayer.highlighted = false
    }
    
    // MARK: - Private methods
    
    private func setup() {
        
        if !initialized {
            
            initialized = true
            
            trackLayer.slider        = self
            trackLayer.contentsScale = UIScreen.main.scale
            
            thumbLayer.slider        = self
            thumbLayer.contentsScale = UIScreen.main.scale
            
            layer.addSublayer(trackLayer)
            layer.addSublayer(thumbLayer)
        }
    }
}

@IBDesignable
class SliderTrackLayer: CALayer {
    
    weak var slider: Slider?
    
    override func draw(in ctx: CGContext) {
        
        if let slider = slider {
            
            let trackInner          = bounds.insetBy(dx: slider.trackBorderWidth / 2, dy: slider.trackBorderWidth / 2)
            let trackInnerHighlight = CGRect(origin: trackInner.origin, size: CGSize(width: slider.position(for: slider.value), height: trackInner.height))
            
            CALayer.fill(rect: trackInner, in: ctx, color: slider.trackColor ?? .white)
            CALayer.fill(rect: trackInnerHighlight, in: ctx, color: slider.trackHighlightColor ?? .white)
            
            CALayer.stroke(rect: trackInner, in: ctx, lineWidth: slider.trackBorderWidth, color: slider.trackBorderColor ?? .white)
            CALayer.stroke(rect: trackInnerHighlight, in: ctx, lineWidth: slider.trackBorderWidth, color: slider.trackBorderHighlightColor ?? .white)
        }
    }
}

@IBDesignable
class SliderThumbLayer: CALayer {
    
    weak var slider: Slider?
    
    var highlighted: Bool = false { didSet { setNeedsDisplay() } }
    
    override func draw(in ctx: CGContext) {
        
        if let slider = slider {
            
            let thumbRect = bounds.insetBy(dx: 3, dy: 3)
            
            ctx.setShadow(offset: CGSize.zero, blur: 3, color: slider.thumbShadowColor?.cgColor ?? UIColor.black.cgColor)
            
            CALayer.fill(rect: thumbRect, in: ctx, color: slider.thumbColor ?? .blue)
            
            CALayer.stroke(rect: thumbRect, in: ctx, lineWidth: slider.thumbBorderWidth, color: slider.thumbBorderColor ?? .white)
            
            if highlighted {
                
            }
        }
    }
}
