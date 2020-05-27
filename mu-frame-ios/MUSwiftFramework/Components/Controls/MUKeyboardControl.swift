//
//  MUKeyboardControl.swift

//
//  Created by Dmitry Smirnov on 01/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUKeyboardControl

class MUKeyboardControl: NSObject {
    
    // MARK: - Public properties
    
    weak var targetView: UIView?
    
    weak var containerView: UIView?
    
    // MARK: - Private properties
    
    private var safeAreaBottomInset: CGFloat { return getBottomInset() }
    
    // MARK: - Public methods
    
    func setup(with controller: MUViewController) {
        
        targetView = controller.view
    }
    
    func subscribeOnNotifications() {
        
        NotificationCenter.addObserver(self, selector: #selector(notificationKeyboard), name: UIResponder.keyboardWillShowNotification)
        NotificationCenter.addObserver(self, selector: #selector(notificationKeyboard), name: UIResponder.keyboardDidShowNotification)
        NotificationCenter.addObserver(self, selector: #selector(notificationKeyboard), name: UIResponder.keyboardWillHideNotification)
        NotificationCenter.addObserver(self, selector: #selector(notificationKeyboard), name: UIResponder.keyboardDidHideNotification)
    }
    
    func unsubscribeOnNotifications() {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private methods
    
    @objc private func notificationKeyboard(notification: Notification) {
        
        guard
            
            containerView != nil,
            
            let targetView = targetView,
            
            let userInfo = notification.userInfo,
            
            let endFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            
            let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            
            else {
                
                return
        }
        
        let endFrame = targetView.convert(endFrameValue.cgRectValue, from: targetView.window)
        
        let animationCurve = UIView.AnimationOptions(rawValue: UInt(curveValue.uint32Value << 16))
        
        let options: UIView.AnimationOptions = [.beginFromCurrentState, animationCurve]
        
        switch notification.name {
            
        case UIResponder.keyboardWillShowNotification : keyboardWillShow(with: endFrame, duration: duration, options: options)
        case UIResponder.keyboardDidShowNotification  : keyboardDidShow(with: endFrame)
        case UIResponder.keyboardWillHideNotification : keyboardWillHide(with: endFrame, duration: duration, options: options)
        case UIResponder.keyboardDidHideNotification  : keyboardDidHide(with : endFrame)
        default                                       : break
        }
    }
    
    @objc private func keyboardWillShow(with frame: CGRect, duration: TimeInterval, options: UIView.AnimationOptions) {
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            
            self.containerView?.setConstraint(type: .bottom, value: frame.height - self.safeAreaBottomInset)
        })
    }
    
    @objc private func keyboardDidShow(with frame: CGRect) {
        
        containerView?.setConstraint(type: .bottom, value: frame.height - self.safeAreaBottomInset)
    }
    
    @objc private func keyboardWillHide(with frame: CGRect, duration: TimeInterval, options: UIView.AnimationOptions) {
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            
            self.containerView?.setConstraint(type: .bottom, value: 0)
        })
    }
    
    @objc private func keyboardDidHide(with frame: CGRect) {
        
        containerView?.setConstraint(type: .bottom, value: 0)
    }
    
    private func getBottomInset() -> CGFloat {
        
        var bottomInset: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            
            bottomInset = targetView?.safeAreaInsets.bottom ?? 0
        }
        
        return bottomInset
    }
}
