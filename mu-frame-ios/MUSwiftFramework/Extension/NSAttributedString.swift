//
//  NSAttributedString.swift

//
//  Created by Dmitry Smirnov on 26.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

extension NSAttributedString {
    
    func addAttribute(name: NSAttributedString.Key, value: Any, strings: [String] = []) -> NSMutableAttributedString {
        
        let attrs = NSMutableAttributedString(attributedString: self)
        
        if strings.count > 0 {
            
            let ranges = getRanges(of: strings, in: self.string)
            
            ranges.forEach { attrs.addAttribute(name, value: value, range: $0) }
            
        } else {
            
            attrs.addAttribute(name, value: value, range: NSRange(location: 0, length: attrs.length))
        }
        
        return attrs
    }
    
    // MARK: - Private methods
    
    private func getRanges(of occurrencies: [String], in text: String) -> [NSRange] {
        
        var ranges: [NSRange] = []
        
        for occurrence in occurrencies {
            
            var position = text.startIndex
            
            while let range = text.range(of: occurrence, range: position..<text.endIndex) {
                
                let location = text.distance(from: text.startIndex, to: range.lowerBound)
                
                ranges.append(NSRange(location: location, length: occurrence.count))
                
                let offset = occurrence.distance(from: occurrence.startIndex, to: occurrence.endIndex) - 1
                
                guard let after = text.index(range.lowerBound, offsetBy: offset, limitedBy: text.endIndex) else { break }
                
                position = text.index(after: after)
            }
        }
        
        return ranges
    }
}
