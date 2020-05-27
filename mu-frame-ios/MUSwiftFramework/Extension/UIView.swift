//
//  Lotteries.swift

//
//  Created by Dmitry Smirnov on 26.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
extension UIView {
    
    // MARK :- Public properties
    
    @IBInspectable var cornerRadius: CGFloat {
        
        set { layer.cornerRadius = newValue  }
        get { return layer.cornerRadius }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        
        set { layer.borderWidth = newValue }
        get { return layer.borderWidth }
    }
    
    @IBInspectable var borderColor: UIColor? {
        
        set { layer.borderColor = newValue?.cgColor  }
        get { return layer.borderColor != nil ? UIColor(cgColor: layer.borderColor!) : nil }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        
        set { layer.shadowOffset = newValue  }
        get { return layer.shadowOffset }
    }
    
    @IBInspectable var shadowOpacity: Float {
        
        set { layer.shadowOpacity = newValue }
        get { return layer.shadowOpacity }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        
        set { layer.shadowRadius = newValue }
        get { return layer.shadowRadius }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        
        set { layer.shadowColor = newValue?.cgColor }
        get { return layer.shadowColor != nil ? UIColor(cgColor: layer.shadowColor!) : nil }
    }
    
    @IBInspectable var rotate: CGFloat {
        
        set { transform = CGAffineTransform(rotationAngle: newValue * .pi/180) }
        get { return 0 }
    }
    
    @IBInspectable var blur: Bool {
        
        set { addBlur(style: .dark) }
        get { return false }
    }
    
    @IBInspectable var shadow: Bool {
        
        set { updateDefaultShadow() }
        get { return false }
    }
    
    var isVisible: Bool { return checkIsVisible() }
    
    var blurSelf: Bool {
        
        set { addBlur(style: .dark, toTop: true) }
        get { return false }
    }
    
    var isHiddenWithAnimate: Bool {
        
        set { setIsHidden(with: newValue, animated: true) }
        get { return isHidden }
    }
    
    var globalFrame: CGRect? { return superview?.convert(frame, to: nil) }
    
    var globalTop: CGFloat { return globalFrame?.origin.y ?? 0 }
    
    var globalBottom: CGFloat { return globalFrame?.maxY ?? 0 }
    
    var globalLeft: CGFloat { return globalFrame?.origin.x ?? 0 }
    
    var globalRight: CGFloat { return globalFrame?.maxX ?? 0 }
    
    @objc var fadeAnimationDuration: TimeInterval { return 0.3 }
    
    // MARK: - Private properties
    
    static private var viewDataStorage: [String: [String: Any?]] = [:]
    
    // MARK :- Visibility
    
    func masked(corners: UIRectCorner, radius: CGFloat) {
        
        cornerRadius = 0
        
        let cornerRadii = CGSize(
            
            width  : radius,
            height : radius
        )
        
        let maskPath = UIBezierPath(
            
            roundedRect       : bounds,
            byRoundingCorners : corners,
            cornerRadii       : cornerRadii
        )
        
        let maskLayer   = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path  = maskPath.cgPath
        
        layer.mask = maskLayer
    }
    
    // MARK :- Subviews
    
    func getSubview(id: String) -> UIView? {
        
        for view in subviews {
            if view.restorationIdentifier == id {
                return view
            }
        }
        
        return nil
    }
    
    func allSubviews(view: UIView? = nil) -> [UIView] {
        
        var result: [UIView] = []
        
        for view in view == nil ? subviews : view!.subviews {
            
            for subview in view.allSubviews(view: view) {
                result.append(subview)
            }
            
            result.append(view)
        }
        
        return result
    }
    
    func rootSuperview() -> UIView {
        
        if self.superview == nil {
            
            return self
        }
        
        var view = self.superview
        
        while (view?.superview != nil) {
            
            view = view?.superview
        }
        
        return view!
    }
    
    func removeAllSubviews() {
        
        for subview in subviews {
            
            subview.removeFromSuperview()
        }
    }
    
    func setIsHidden(with isHidden: Bool, animated: Bool) {
        
        guard isHidden != self.isHidden else { return }
        
        guard animated else {
            
            self.isHidden = isHidden
            
            return
        }
        
        if self.isHidden == true && isHidden == false {
            
            self.isHidden = isHidden
        }
        
        self.alpha = isHidden ? 1 : 0
        
        UIView.animate(
            
            withDuration : fadeAnimationDuration,
            animations   : {
            
                self.alpha = isHidden ? 0 : 1
            }
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeAnimationDuration, execute: { [weak self] in
            
            self?.isHidden = isHidden
        })
    }
    
    // MARK :- Constraint
    
    func findConstraint(byId id: String) -> NSLayoutConstraint? {
        
        for constraint in constraints {
            
            if constraint.identifier == id {
                
                return constraint
            }
        }
        
        return nil
    }
    
    func findConstraint(type: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        
        if let constraint = findConstraintInSuperview(type: type) {
            
            return constraint
        }
        
        for constraint in constraints {
            
            if constraint.firstAttribute == type {
                
                return constraint
            }
        }
        
        return nil
    }
    
    func findConstraintInSuperview(type: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        
        if let superview = superview {
            
            for constraint in superview.constraints {
                
                let isFirstItemIsSelf = (constraint.firstItem as? UIView) == self
                
                let isSecondItemIsSelf = (constraint.secondItem as? UIView) == self
                
                let isConstraintAssociatedWithSelf = (isFirstItemIsSelf || isSecondItemIsSelf)
                
                if constraint.firstAttribute == type && isConstraintAssociatedWithSelf {
                    
                    return constraint
                }
            }
        }
        
        return nil
    }
    
    func setConstraint(type: NSLayoutConstraint.Attribute, value: CGFloat) {
        
        if let constraint = findConstraint(type: type) {
            
            constraint.constant = value
            
        } else {
            
            switch type {
                
            case .width  : widthAnchor.constraint(equalToConstant  : value)
            case .height : heightAnchor.constraint(equalToConstant : value)
            default      : break
            }
        }
        
        superview?.layoutIfNeeded()
    }
    
    func appendConstraints(to view: UIView, withSafeArea isWithSafeArea: Bool = false) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if isWithSafeArea, #available(iOS 11.0, *) {
            
            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            
        } else {
            
            topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
    }
    
    func append(toLeft view: UIView, rightOf rightView: UIView? = nil, margin: CGFloat = 0) {
        
        view.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        if let rightView = rightView {
            
            leadingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: margin).isActive = true
        } else {
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin).isActive = true
        }
    }
    
    func createViewAndAppend(withSafeArea isWithSafeArea: Bool = false) -> UIView {
        
        let newView = UIView(frame: frame)
        
        addSubview(newView)
        
        newView.appendConstraints(to: self, withSafeArea: isWithSafeArea)
        
        return newView
    }
    
    func createContainer(width: CGFloat? = nil, height: CGFloat? = nil) {
        
        let containerView = UIView()
        
        containerView.addSubview(self)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.appendConstraints(to: containerView)
        
        if let width = width {
            
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    // MARK: - Data
    
    func setViewData(key: String, value: Any?) {
        
        let id = String(ObjectIdentifier(self).hashValue)
        
        if var dict = UIView.viewDataStorage[id] {
            
            dict[key] = value
            
            UIView.viewDataStorage[id] = dict
            
        } else {
            
            UIView.viewDataStorage[id] = [key: value]
        }
    }
    
    func viewData(key: String) -> Any? {
        
        let id = String(ObjectIdentifier(self).hashValue)
        
        return UIView.viewDataStorage[id]?[key] ?? nil
    }
    
    // MARK :- Effects
    
    @discardableResult
    func addBlur(style: UIBlurEffect.Style, toTop: Bool = false) -> UIView {
        
        let blurEffect     = UIBlurEffect(style : style)
        let blurEffectView = UIVisualEffectView(effect : blurEffect)
        
        blurEffectView.frame            = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if toTop {
            
            addSubview(blurEffectView)
        } else {
            insertSubview(blurEffectView, at: 0)
        }
        
        return blurEffectView
    }
    
    func addBlur(radius: CGFloat) -> UIView {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1.0)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        let blur = CIFilter(name: "CIGaussianBlur")!
        
        blur.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        blur.setValue(radius, forKey: kCIInputRadiusKey)
        
        let result  = blur.value(forKey: kCIOutputImageKey) as! CIImage?
        let cgImage = CIContext(options: nil).createCGImage(result!, from: bounds)
        
        let imageView = UIImageView(frame: bounds)
        
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.image            = cgImage != nil ? UIImage(cgImage: cgImage!) : nil
        imageView.backgroundColor  = .clear
        
        addSubview(imageView)
        
        return imageView
    }
    
    func fadeOut(withDuration duration: TimeInterval? = nil) {
        
        UIView.animate(
            
            withDuration : duration ?? fadeAnimationDuration,
            animations   : { self.alpha = 0 },
            completion   : { [weak self] success in self?.removeFromSuperview() }
        )
    }
    
    // MARK: - Utils
    
    func makeScreenshot() -> UIImage? {
        
        UIGraphicsBeginImageContext(frame.size)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        layer.render(in: context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func addFadeOutGradient(to toView: UIView, under underView: UIView) {
        
        let y = convert(CGPoint(x: 0, y: underView.frame.maxY), to: toView).y
        
        let startLocation = y / toView.frame.height
        let endLocation   = startLocation + underView.frame.height / toView.frame.height
        
        let gradient = CAGradientLayer()
        
        gradient.frame     = toView.bounds
        gradient.colors    = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [startLocation, endLocation] as [NSNumber]
        
        toView.layer.mask = gradient
    }
    
    // MARK :- Private methods
    
    private func updateDefaultShadow() {
    
        let defaultShadowRadius : CGFloat = 2
        let defaultShadowColor  : UIColor = UIColor.black.withAlphaComponent(0.4)
    
        shadowRadius = defaultShadowRadius
        shadowColor  = defaultShadowColor
        shadowOffset = CGSize(width : 0, height : defaultShadowRadius)
    }
    
    private func checkIsVisible() -> Bool {
        
        guard isHidden == false && alpha > 0 else {
            
            return false
        }
        
        guard self.superview?.isVisible ?? true else {
            
            return false
        }
        
        return true
    }
}
