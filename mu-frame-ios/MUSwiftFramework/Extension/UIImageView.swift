//
//  UIImageView.swift

//
//  Created by Dmitry Smirnov on 28.06.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func addBlur() {
        
        guard let image = image else { return }
        
        let imageToBlur = CIImage(image: image)
        
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        
        blurfilter?.setValue(imageToBlur, forKey: "inputImage")
        
        guard let resultImage = blurfilter?.value(forKey: "outputImage") as? CIImage else { return }
        
        let blurredImage = UIImage(ciImage: resultImage)
        
        self.image = blurredImage
        
        self.contentMode = .center
    }
}
