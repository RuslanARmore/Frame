//
//  UIWebView.swift

//
//  Created by Dmitry Smirnov on 30.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

@IBDesignable
extension UIWebView {
    
    // MARK :- Public properties
    
    @IBInspectable var clear: Bool {
        set { isOpaque = !newValue  }
        get { return !isOpaque }
    }
    
    @IBInspectable var hasIndicator: Bool {
        
        set { delegate = self }
        get { return false }
    }
    
    @IBInspectable var showIndicator: Bool {
        
        set { setIndicatorVisibility(is: newValue) }
        get { return false }
    }
    
    // MARK: - Private methods
    
    private func setIndicatorVisibility(is isVisible: Bool) {
        
        hideActivityIndicator()
        
        if isVisible {
            
            showActivityIndicator()
        }
    }
    
    private func showActivityIndicator() {
        
        let indicator = UIActivityIndicatorView()
        
        indicator.startAnimating()
        
        self.addSubview(indicator)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        indicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func hideActivityIndicator() {
        
        for view in subviews {
            
            if let indicator = view as? UIActivityIndicatorView {
                
                indicator.removeFromSuperview()
            }
        }
    }
}

// MARK: - UIWebViewDelegate

extension UIWebView: UIWebViewDelegate {
    
    public func webViewDidStartLoad(_ webView: UIWebView) {
        
        showIndicator = true
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        
        showIndicator = false
        
        delegate = nil
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        showIndicator = false
    }
}
