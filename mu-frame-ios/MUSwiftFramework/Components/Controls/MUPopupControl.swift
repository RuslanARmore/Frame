//
//  MUPopupControl.swift
//  MUSwiftFramework
//
//  Created by Ilya B Macmini on 22.05.2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//
// Pods: SwiftEntryKit

import UIKit
import SwiftEntryKit

// MARK: - MUPopupControl

class MUPopupControl {

    // MARK: - AnimationType
    
    enum AnimationType {
        
        case none
        case translation
        case fade
        case scale
    }
    
    // MARK: - Position
    
    enum Position {
        
        case top
        case center
        case bottom
    }
    
    enum BackgroundColorStyle {
        
        case light
        case dark
        case extraDark
    }

    // MARK: - Public properties
    
    weak var controller: MUViewController?
    
    // MARK: - Public methods
    
    func setup(with controller: MUViewController) {
        
        self.controller = controller
    }
    
    func showPopup(
        
        title       : String,
        message     : String?,
        buttonTitle : String,
        action      : (() -> Void)?
    ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(title: buttonTitle, handler : action)
        
        controller?.present(alert, animated: true, completion: nil)
    }

    func showDialogAlert(
        
        title             : String,
        message           : String?,
        leftButtonTitle   : String,
        rightButtonTitle  : String,
        leftButtonStyle   : UIAlertAction.Style,
        rightButtonStyle  : UIAlertAction.Style,
        leftButtonAction  : (() -> Void)?,
        rightButtonAction : (() -> Void)?
    ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(title: leftButtonTitle, style: leftButtonStyle, handler: leftButtonAction)
        alert.addAction(title: rightButtonTitle, style: rightButtonStyle, handler: rightButtonAction)
        
        controller?.present(alert, animated: true, completion: nil)
    }
    
    func showToast(
        
        title    : String,
        message  : String?,
        duration : TimeInterval
    ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        controller?.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            
            alert.dismiss(animated: true)
        }
    }
    
    func show(
        
        customView                : MUCustomView,
        position                  : Position,
        animationType             : AnimationType,
        backgroundColorStyle      : BackgroundColorStyle,
        duration                  : TimeInterval,
        isClosedOnBackgroundTouch : Bool,
        isClosedOnSwipe           : Bool,
        isShadowEnabled           : Bool
    ) {
        
        var attributes = getAttributes(position: position)

        attributes.positionConstraints.size = .init(
            
            width  : .constant(value: customView.bounds.width),
            height : .constant(value: customView.bounds.height)
        )
        
        let animations = getAnimations(type: animationType)
        attributes.entranceAnimation = animations.entrance
        attributes.exitAnimation = animations.exit
        
        attributes.displayDuration = duration
        
        attributes.screenInteraction = isClosedOnBackgroundTouch ? .dismiss : .absorbTouches
        attributes.entryInteraction = .forward
        
        attributes.scroll = isClosedOnSwipe ? .enabled(swipeable: true, pullbackAnimation: .jolt) : .disabled
        
        attributes.screenBackground = getBackgroundColor(style: backgroundColorStyle)
        attributes.shadow = isShadowEnabled ? .active(with: .init(color: .black, opacity: 0.3, radius: 8)) : .none
        
        SwiftEntryKit.display(entry: customView, using: attributes)
    }
    
    func show(
        
        controller                : MUViewController,
        position                  : Position,
        animationType             : AnimationType,
        backgroundColorStyle      : BackgroundColorStyle,
        duration                  : TimeInterval,
        isClosedOnBackgroundTouch : Bool,
        isClosedOnSwipe           : Bool,
        isShadowEnabled           : Bool,
        widthRatio                : CGFloat,
        heightRatio               : CGFloat
    ) {
        
        var attributes = getAttributes(position: position)
        
        attributes.positionConstraints.size = .init(
            
            width  : .ratio(value: widthRatio),
            height : .ratio(value: heightRatio)
        )
        
        attributes.positionConstraints.verticalOffset = 0
        attributes.positionConstraints.safeArea = .overridden
    
        attributes.screenInteraction = isClosedOnBackgroundTouch ? .dismiss : .absorbTouches
        attributes.entryInteraction = .forward
        
        attributes.scroll = isClosedOnSwipe ? .edgeCrossingDisabled(swipeable: true) : .disabled
        
        let animations = getAnimations(type: animationType)
        attributes.entranceAnimation = animations.entrance
        attributes.exitAnimation = animations.exit
        
        attributes.screenBackground = getBackgroundColor(style: backgroundColorStyle)
        attributes.shadow = isShadowEnabled ? .active(with: .init(color: .black, opacity: 0.3, radius: 6)) : .none
        
        attributes.displayDuration = duration
        
        SwiftEntryKit.display(entry: controller, using: attributes)
    }
    
    func dismiss() {
        
        SwiftEntryKit.dismiss()
    }
    
    // MARK: - Private methods
    
    private func getAttributes(position: Position) -> EKAttributes {
        
        switch position {
        
        case .top    : return EKAttributes.topFloat
        case .center : return EKAttributes.centerFloat
        case .bottom : return EKAttributes.bottomFloat
        }
    }
    
    private func getAnimations(type: AnimationType) -> (entrance: EKAttributes.Animation, exit: EKAttributes.Animation){
        
        switch type {
            
        case .none:
            
            return (EKAttributes.Animation.none, EKAttributes.Animation.none)
            
        case .translation:
            
            let entranceTranslate = EKAttributes.Animation(translate: .init(duration: 0.3))
            let exitTranslate = EKAttributes.Animation(translate: .init(duration: 0.2))
            return (entranceTranslate, exitTranslate)
            
        case .fade:
            
            let entranceFade = EKAttributes.Animation(fade: .init(from: 0, to: 1, duration: 0.3))
            let exitFade = EKAttributes.Animation(fade: .init(from: 1, to: 0, duration: 0.2))
            return (entranceFade, exitFade)
            
        case .scale:
            
            let entranceScale = EKAttributes.Animation(scale:EKAttributes.Animation.RangeAnimation(from: 0.1, to: 1, duration: 0.3))
            let exitScale = EKAttributes.Animation(scale: EKAttributes.Animation.RangeAnimation(from: 1, to: 0.1, duration: 0.2))
            return (entranceScale, exitScale)
        }
    }
    
    private func getBackgroundColor(style: BackgroundColorStyle) -> EKAttributes.BackgroundStyle {
        
        switch style {
            
        case .light     : return EKAttributes.BackgroundStyle.color(color: UIColor.lightGray.withAlphaComponent(0.1))
        case .dark      : return EKAttributes.BackgroundStyle.color(color: UIColor.darkGray.withAlphaComponent(0.4))
        case .extraDark : return EKAttributes.BackgroundStyle.color(color: UIColor.black.withAlphaComponent(0.7))
        }
    }
}
