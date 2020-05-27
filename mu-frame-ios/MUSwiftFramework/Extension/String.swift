//
//  String.swift

//
//  Created by Dmitry Smirnov on 27.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit
import PhoneNumberKit

extension String {
    
    var localize: String { return Constants.bundle.localizedString(forKey: self, value: "", table: nil) }
    
    private static let dateFormatter1 = DateFormatter()
    
    private static let dateFormatter2 = DateFormatter()
    
    private static let numberFormatter = NumberFormatter()
    
    private static let numberFormatter2 = NumberFormatter()
    
    private static let phoneNumberFormatter = PhoneNumberKit()
    
    // MARK: - Public methods
    
    func format(to: NumberFormatter.Style) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = to
        
        return formatter.string(from: NSNumber(value: Int(self) ?? 0)) ?? "0"
    }
    
    static func format(
        
        time  : TimeInterval,
        style : DateComponentsFormatter.UnitsStyle = .positional,
        pad   : DateComponentsFormatter.ZeroFormattingBehavior = .pad,
        units : [NSCalendar.Unit] = [.hour, .minute, .second]
        
    ) -> String {
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: time) ?? ""
    }
    
    static func format(date: Date?, style: [DateFormatter.Style]) -> String {
        
        guard let date = date else { return "" }
        
        let dateFormatter = String.dateFormatter1
        dateFormatter.dateStyle = style[0]
        dateFormatter.timeStyle = style[1]
        
        return dateFormatter.string(from: date)
    }
    
    static func format(date: Date?, format: String = "d MMM, HH:mm", timeZone: TimeZone? = nil, serverFormat: Bool = false) -> String {
        
        guard let date = date else { return "" }
        
        let dateFormatter = String.dateFormatter2
        
        var format = format
        
        dateFormatter.locale = Locale.current
        
        if let formatter = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current), formatter.contains("a"), !serverFormat {
            
            format = format.replacingOccurrences(of: "HH", with: "h")
            
            if !format.contains("a") {
                
                format.append(" a")
            }
        }
        
        dateFormatter.dateFormat = format
        
        if let timeZone = timeZone {
            
            dateFormatter.timeZone = timeZone
        }
        
        return dateFormatter.string(from: date)
    }
    
    static func format(price: Double, local: String = "en_US_POSIX") -> String? {
        
        let formatter         = numberFormatter2
        formatter.locale      = Locale(identifier : local)
        formatter.numberStyle = .currency
        
        return formatter.string(from: NSNumber(value: price))
    }
    
    static func format(eth value: Double, minMantissa: Int = 0, maxMantissa: Int = 4) -> String {
        
        numberFormatter.minimumFractionDigits = minMantissa
        numberFormatter.maximumFractionDigits = maxMantissa
        numberFormatter.minimumIntegerDigits  = 1
        
        numberFormatter.decimalSeparator = "."
        
        if value > 0 && value <= 0.01 {
            
            return String(format: "%@ FINNEY", numberFormatter.string(from: NSNumber(value: value * 1000)) ?? "0")
        } else {
            return String(format: "%@ ETH", numberFormatter.string(from: NSNumber(value: value)) ?? "0")
        }
    }
    
    static func format(number value: Double, minMantissa: Int = 0, maxMantissa: Int = 4) -> String {
        
        numberFormatter.minimumFractionDigits = minMantissa
        numberFormatter.maximumFractionDigits = maxMantissa
        numberFormatter.minimumIntegerDigits  = 1
        
        numberFormatter.decimalSeparator = "."
        
        return numberFormatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
    static func format(phone: String) -> String {
        
        return PartialFormatter().formatPartial(phone)
    }
    
    static func format(phone: String, to type: PhoneNumberFormat) -> String? {
        
        guard let phoneNumber = try? phoneNumberFormatter.parse(phone) else { return nil }
        
        return phoneNumberFormatter.format(phoneNumber, toType: type)
    }
    
    static var currentPhoneCoutryCode: String {
        
        return PhoneNumberKit().countryCode(for: Locale.current.languageCode ?? "")?.description ?? ""
    }
    
    static func randomStringFrom(array: [String], lowercased: Bool = false) -> String {
        
        let randomIndex = Int.rand(min: 0, max: array.count - 1)
        
        let randomLetter = array[randomIndex]
        
        return lowercased == true ? randomLetter.lowercased() : randomLetter
    }
    
    func toDictionary() -> [String: Any]? {
        
        guard let data = self.data(using: .utf8) else { return nil }
        
        do {
            
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
        } catch let error {
            
            Log.error("error: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func convertToDictionaty() -> [String: Any]? {
        
        guard
            
            let data = data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else { return nil }
        
        return json as? [String: Any]
    }    
    
    func replace(pattern: String, with replaceString: String = "") -> String {
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive) else {
            
            return self
        }
        
        let range = NSMakeRange(0, count)
        
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceString)
    }
}
