//
//  MUQrCodeManager.swift
//
//  Created by Dmitry Smirnov on 1/02/2019.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - MUQrCodeManager

class MUQrCodeManager {
    
    // MARK: - Public methods
    
    class func generateQRCode(from string: String, size: CGSize) -> UIImage? {
        
        let data = string.data(using: String.Encoding.ascii)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
            
        filter.setValue(data, forKey: "inputMessage")
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let scaleX = size.width / outputImage.extent.size.width
        
        let scaleY = size.height / outputImage.extent.size.height
        
        let scale = max(scaleX, scaleY).rounded()
        
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        
        return UIImage(ciImage: outputImage.transformed(by: transform))
    }
    
    class func read(
        
        for controller  : UIViewController,
        descriptionText : String? = nil,
        completion      : @escaping (String?) -> Void
    ) {
        
        guard let readerController = MUQrCodeController.getInstantiate() as? MUQrCodeController else {
            
            Log.error("failed to create instantiate for \(MUQrCodeController.self)")
            
            completion(nil)
            
            return
        }
        
        readerController.descriptionText = descriptionText
        
        readerController.completionBlock = { (result: String?) in
            
            completion(result)
        }
        
        controller.present(readerController, animated: true, completion: nil)
    }
}
