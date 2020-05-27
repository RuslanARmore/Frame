//
//  MUActivityIndicatorControl.swift
//
//  Created by Dmitry Smirnov on 01/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUActivityIndicatorControl

class MUActivityIndicatorControl: NSObject {
    
    // MARK: - Style
    
    enum Style {
        
        case lightLarge
        case light
        case dark
    }
    
    // MARK: - Public properties
    
    var style: Style = .lightLarge { didSet { updateStyle() } }
    
    var defaultDelay: TimeInterval = 0.6
    
    weak var view: UIView?
    
    weak var indicatorContainer: UIView?
    
    // MARK: - Private methods
    
    private weak var indicator: UIActivityIndicatorView?
    
    // MARK: - Public methods
    
    func showIndicator(above view: UIView, delay: TimeInterval? = nil) {
        
        let delay = delay ?? defaultDelay
        
        guard self.indicatorContainer == nil else {
            
            return
        }
        
        let indicatorContainer = UIView()
        
        view.addSubview(indicatorContainer)
        
        indicatorContainer.appendConstraints(to: view)
        
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        
        indicatorContainer.addSubview(indicator)
        
        indicator.startAnimating()
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: indicatorContainer.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: indicatorContainer.centerYAnchor).isActive = true
        
        self.indicatorContainer = indicatorContainer
        
        self.indicator = indicator
        
        updateStyle()
        
        if delay > 0 {
            
            self.indicatorContainer?.alpha = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { [weak self] in
                
                self?.indicatorContainer?.alpha = 1
            })
        }
    }
    
    func hideIndicator() {
        
        guard let indicatorContainer = indicatorContainer else {
            
            return
        }
        
        indicatorContainer.removeFromSuperview()
        
        self.indicatorContainer = nil
    }
    
    // MARK: - Private methods
    
    private func updateStyle() {
        
        switch style {
        case .lightLarge : indicator?.style = .whiteLarge
        case .light      : indicator?.style = .white
        case .dark       : indicator?.style = .gray
        }
        
        updateBackgroundColor()
    }
    
    private func updateBackgroundColor() {
        
        switch style {
        case .lightLarge : indicatorContainer?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        case .light      : indicatorContainer?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        case .dark       : indicatorContainer?.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        }
    }
}
