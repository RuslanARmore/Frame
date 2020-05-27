//
//  UIScrollView.swift

//
//  Created by Dmitry Smirnov on 22.05.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    // MARK: - Public methods
    
    func scrollToBottom(animated: Bool = true) {
        
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
        
        setContentOffset(bottomOffset, animated: animated)
    }
}
