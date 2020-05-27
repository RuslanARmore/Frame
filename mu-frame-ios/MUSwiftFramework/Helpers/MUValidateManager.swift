//
//  MUValidateManager.swift
//
//  Created by Dmitry Smirnov on 1/02/2019.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

enum MURegexpClass: String {
    
    case numbers = "\\d"
    case floatNumbers = "\\d+(?:[.]\\d+)?"
    case lowerCase = "\\p{Ll}"
    case upperCase = "\\p{Lu}"
}

enum MUValidateRule {
    
    case required
    case email
    case numeric
    case numericFloat
    case minLength(Int)
    case maxLength(Int)
    case allowChar(String)
    case allowRegexp(String)
    case containsAtLeastOneOf([MURegexpClass])
}

class MUValidateManager: NSObject {
    
    static let shared = MUValidateManager()
    
    // MARK: - Private properties
    
    static let emailRegexp = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    // MARK: - Public methods
    
    func checkIsValid(value: String, match rules: [MUValidateRule]) -> Bool {
        
        for rule in rules {
            
            if !check(value: value, match: rule) {
                
                return false
            }
        }
        
        return true
    }
    
    func check(value: String, match rule: MUValidateRule) -> Bool {
        
        switch rule {
        case .required:
            return checkRequired(value: value)
            
        case .email:
            return checkEmail(value: value)
            
        case .numeric:
            return checkNumeric(value: value)
            
        case .numericFloat:
            return checkNumericFloat(value: value)
            
        case .minLength(let length):
            return checkMinLength(value: value, length: length)
            
        case .maxLength(let length):
            return checkMaxLength(value: value, length: length)
            
        case .allowChar(let chars):
            return checkAllowChar(value: value, chars: chars)
            
        case .allowRegexp(let regexp):
            return checkAllowRegexp(value: value, regexp: regexp)
            
        case .containsAtLeastOneOf(let regexpClasses):
            return checkContainsAtLeastOne(value: value, classes: regexpClasses)
        }
    }
    
    // MARK: - Private methods
    
    private func checkRequired(value: String) -> Bool {
        
        return value != "" && value.count > 0
    }
    
    private func checkEmail(value: String) -> Bool {
        
        return check(value: value, regexp: MUValidateManager.emailRegexp)
    }
    
    private func checkNumeric(value: String) -> Bool {
        
        return check(value: value, regexp:"[\(MURegexpClass.numbers.rawValue)]+")
    }
    
    private func checkNumericFloat(value: String) -> Bool {
        
        return check(value: value, regexp: MURegexpClass.floatNumbers.rawValue)
    }
    
    private func checkMinLength(value: String, length: Int) -> Bool {
        
        return value.count >= length
    }
    
    private func checkMaxLength(value: String, length: Int) -> Bool {
        
        return value.count <= length
    }
    
    private func checkAllowChar(value: String, chars: String) -> Bool {
        
        return check(value: value, regexp: "[\(chars)]+")
    }
    
    private func checkAllowRegexp(value: String, regexp: String) -> Bool {
        
        return check(value: value, regexp: regexp)
    }
    
    private func checkContainsAtLeastOne(value: String, classes: [MURegexpClass]) -> Bool {
        
        var regexp    = ""
        var allowChar = ""
        
        for regexpClass in classes {
            
            regexp += "(?=.*[\(regexpClass.rawValue)])"
            allowChar += "\(regexpClass.rawValue)"
        }
        
        regexp += "[\(allowChar)]+"
        
        return check(value: value, regexp: regexp)
    }
    
    private func check(value: String, regexp: String) -> Bool {
    
        return NSPredicate(format:"SELF MATCHES %@", regexp).evaluate(with: value)
    }

}
