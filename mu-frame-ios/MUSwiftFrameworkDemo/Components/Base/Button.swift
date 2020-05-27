//
//  Button.swift

//
//  Created by Dmitry Smirnov on 26.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

@IBDesignable
class Button: UIButton {
    
    @IBInspectable var normalColor: UIColor? { didSet { backgroundColor = normalColor } }
    
    @IBInspectable var highlightedColor: UIColor?
    
    @IBInspectable var selectedColor: UIColor?
    
    @IBInspectable var disabledColor: UIColor?
    
    @IBInspectable var isRounded: Bool = false { didSet { updateRounded() } }
    
    @IBInspectable var newTintColor: UIColor? { didSet { updateTintColor() } }
    
    @IBInspectable var alwaysTemplate: Bool = false { didSet { updateRenderingMode() } }
    
    @IBInspectable var showActivity: Bool = false { didSet { updateShowActivity() } }
    
    @IBInspectable var isTruncatingTail: Bool = false
    
    var isActivityWithBlockUI: Bool = true
    
    // MARK: - Override properties
    
    override var isHighlighted: Bool { didSet { updateHighlighted() } }
    
    override var isSelected: Bool { didSet { updateSelected() } }
    
    override var isEnabled: Bool { didSet { updateEnabled() } }
    
    // MARK: - Private properties
    
    private var isLocalized: Bool = false
    
    private weak var activityIndicator: UIActivityIndicatorView?
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateRounded()
        
        localizedAttributedTitles()
        
        isLocalized = true
        
        updateTruncatingTail()
    }
    
    func setParagraphLineBreakMode(with lineBreakMode: NSLineBreakMode, state: UIControl.State) {
        
        guard var attributedTitle = attributedTitle(for: state) else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineBreakMode = lineBreakMode
        
        attributedTitle = attributedTitle.addAttribute(name: .paragraphStyle, value: paragraphStyle)
        
        setAttributedTitle(attributedTitle, for: state)
    }
    
    // MARK: - Private methods
    
    private func updateTruncatingTail() {
        
        guard isTruncatingTail else { return }

        setParagraphLineBreakMode(with: .byTruncatingTail, state: .normal)

        setParagraphLineBreakMode(with: .byTruncatingTail, state: .highlighted)

        setParagraphLineBreakMode(with: .byTruncatingTail, state: .selected)

        setParagraphLineBreakMode(with: .byTruncatingTail, state: .disabled)
        
        titleLabel?.lineBreakMode = .byTruncatingTail
    }
    
    private func localizedTitle() {        
        
        guard isLocalized == false else { return }
        
        if let normalTitle = title(for: .normal), normalTitle != "" {
            
            setTitle(normalTitle.localize, for: .normal)
        }
        
        if let selectedTitle = title(for: .selected), selectedTitle != "" {
            
            setTitle(selectedTitle.localize, for: .selected)
        }
        
        if let highlightedTitle = title(for: .highlighted), highlightedTitle != "" {
            
            setTitle(highlightedTitle.localize, for: .highlighted)
        }
        
        if let disabledTitle = title(for: .disabled), disabledTitle != "" {
            
            setTitle(disabledTitle.localize, for: .disabled)
        }
    }
    
    private func localizedAttributedTitles() {
        
        guard isLocalized == false else { return }
        
        if let normalTitle = attributedTitle(for: .normal), normalTitle.string != "" {
            
            setAttributedTitle(text: normalTitle.string.localize, for: .normal)
        }
        
        if let selectedTitle = attributedTitle(for: .selected), selectedTitle.string != "" {
            
            setAttributedTitle(text: selectedTitle.string.localize, for: .selected)
        }
        
        if let highlightedTitle = attributedTitle(for: .highlighted), highlightedTitle.string != "" {
            
            setAttributedTitle(text: highlightedTitle.string.localize, for: .highlighted)
        }
        
        if let disabledTitle = attributedTitle(for: .disabled), disabledTitle.string != "" {
            
            setAttributedTitle(text: disabledTitle.string.localize, for: .disabled)
        }
    }
    
    private func updateRounded() {
        
        if isRounded {
            
            cornerRadius = bounds.height / 2
        }
    }
    
    private func updateHighlighted() {
        
        guard isEnabled, !isSelected, let highlightedColor = self.highlightedColor ?? getBackgroundColor()?.highlightedColor() else {
            
            return
        }
        
        backgroundColor = isHighlighted ? highlightedColor : normalColor
    }
    
    private func updateSelected() {
        
        guard isEnabled, let selectedColor = self.selectedColor else {
            
            return
        }
        
        backgroundColor = isSelected ? selectedColor : normalColor
    }
    
    private func updateEnabled() {
        
        guard let disabledColor = self.disabledColor ?? getBackgroundColor()?.disableColor() else {
            
            return
        }
        
        backgroundColor = isEnabled ? normalColor : disabledColor
    }
    
    private func updateTintColor() {
        
        guard let newTintColor = newTintColor else {
            
            return
        }
        
        self.tintColor = newTintColor
    }
    
    private func updateRenderingMode() {
        
        let image = self.image(for: .normal)?.withRenderingMode(alwaysTemplate ? .alwaysTemplate : .automatic)
        
        self.setImage(image, for: .normal)
    }
    
    private func updateShowActivity() {
        
        if showActivity {
            
            addActivityIndicator()
            
            titleLabel?.alpha = 0
            
            imageView?.layer.transform = CATransform3DMakeScale(0, 0, 0)
            
            isEnabled = false
            
        } else {
            
            removeActivityIndicator()
            
            titleLabel?.alpha = 1
            
            imageView?.layer.transform = CATransform3DIdentity
            
            isEnabled = true
        }
    }
    
    private func addActivityIndicator() {
        
        guard self.activityIndicator == nil else { return }
        
        let activityIndicator = UIActivityIndicatorView(style: .white)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.startAnimating()
        
        addSubview(activityIndicator)
        
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        self.activityIndicator = activityIndicator
    }
    
    private func removeActivityIndicator() {
        
        activityIndicator?.removeFromSuperview()
        
        activityIndicator = nil
    }
    
    private func getBackgroundColor() -> UIColor? {
        
        if let normalColor = normalColor {
            
            return normalColor
        }
        
        if let backgroundColor = backgroundColor {
            
            self.normalColor = backgroundColor
            
            return normalColor
        }
        
        return nil
    }
}
