//
//  DemoListItemController.swift
//  MUSwiftFramework
//
//  Created by Dmitry Smirnov on 23/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - DemoListItemController

class DemoListItemController: ViewController {
    
    class override var storyboardName: String { return "DemoList" }
    
    // MARK: - Private methods
    
    @IBAction private func showQRCodeScreen(_ sender: UIButton) {
        
        DemoQrController.push(to: self)
    }
    
    @IBAction private func showCustomViewPopupBtnDidTouch(_ sender: UIButton) {
        
        let customView = TestCustomView(frame: CGRect(x: 100, y: 100, width: 200, height: 200))

        customView.butonAction = { [weak self] in self?.dismissPopup() }
        
        show(
            
            customView                : customView,
            position                  : .center,
            animationType             : .fade,
            backgroundColorStyle      : .dark,
            duration                  : .infinity,
            isClosedOnBackgroundTouch : true,
            isClosedOnSwipe           : true,
            isShadowEnabled           : true
        )
    }
    
    @IBAction private func showCustomVCPopupBtnDidTouch(_ sender: UIButton) {
        
        guard let controller = DemoFormController.getInstantiate() else { return }
        
        // For testing purposes only (not to edit original DemoFormController).
        // In real project - configure UI in storyboard.
        controller.view.cornerRadius = 15
        controller.view.clipsToBounds = true
        
        if #available(iOS 11.0, *) {
            controller.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        show(
            
            controller                : controller,
            position                  : .bottom,
            animationType             : .translation,
            backgroundColorStyle      : .light,
            duration                  : .infinity,
            isClosedOnBackgroundTouch : true,
            isClosedOnSwipe           : true,
            isShadowEnabled           : false,
            widthRatio                : 1,
            heightRatio               : 0.5
        )
    }
}
