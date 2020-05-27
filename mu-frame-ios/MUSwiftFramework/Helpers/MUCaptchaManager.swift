//
//  MUCaptchaManager.swift
//
//  Created by Dmitry Smirnov on 1/02/2019.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit
import ReCaptcha

// MARK: - MUCaptchaManager

class MUCaptchaManager {
    
    static let shared = MUCaptchaManager()
    
    // MARK: - Private properties
    
    private var recaptcha = try? ReCaptcha()
    
    private static let webViewTag = 666
    
    // MARK: - Public methods
    
    func configure(on view: UIView) {
        
        recaptcha?.configureWebView { webView in
            
            webView.frame = view.bounds
            webView.tag = MUCaptchaManager.webViewTag
        }
    }
    
    func validate(on view: UIView, success: ((String) -> Void)? = nil, failure: (() -> Void)? = nil) {
        
        resetRecaptcha()
        
        recaptcha?.validate(on: view) { result in
            
            do {
                
                let captcha = try result.dematerialize()
                
                success?(captcha)
                
            } catch {
                
                failure?()
            }
            
            view.subviews.first(where: { $0.tag == MUCaptchaManager.webViewTag })?.removeFromSuperview()
        }
    }
    
    // MARK: - Private methods
    
    private func resetRecaptcha() {
        
        recaptcha?.reset()
    }
}
