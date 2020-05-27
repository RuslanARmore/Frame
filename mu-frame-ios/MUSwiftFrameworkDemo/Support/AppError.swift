//
//  AppError.swift

//
//  Created by Dmitry Smirnov on 22.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

// MARK: - AppError

enum AppError: Error {
    
    case unknownError
    case parsingError
    case connectionError
    case serverError
    case serverErrorWithError(String)
    case methodNotFound
    case validationError
    case unauthorized
    case wrongCredentials
    case wrongParameters
    case wrongHttpMethod
    case tokenRequired
    case tokenExpired
    case accessDenied
    case updateDeviceToken
    case requestLimit
}

// MARK: - MUErrorManager

extension AppError {
    
    // MARK: - Public properties
    
    static var recipient: NSObject? { didSet { MUErrorManager.recipient = recipient } }
    
    // MARK: - Public methods
    
    static func post(with error: AppError, for recipient: NSObject? = nil) {
        
        MUErrorManager.post(with: error, for: recipient)
    }
    
    func post(for recipient: NSObject? = nil) {
        
        MUErrorManager.post(with: self, for: recipient)
    }
}

// MARK: - ApiError

extension AppError {
    
    static func convertNetworkError(error: MUNetworkError) -> AppError {
        
        switch error {
            
            case .connectionError         : return AppError.connectionError
            case .serverError             : return AppError.serverError
            case .parsingError            : return AppError.parsingError
            case .unknownError            : return AppError.unknownError
            case .httpError(let httpCode) : return AppError.convertCodeError(with: httpCode)
        }
    }
    
    static func convertCodeError(with code: Int) -> AppError {

        switch code {

            case 400: return AppError.wrongParameters
            case 401: return AppError.unauthorized
            case 404: return AppError.methodNotFound
            case 405: return AppError.wrongHttpMethod
            case 422: return AppError.wrongParameters
            case 429: return AppError.requestLimit

            default: break
        }
        
        return AppError.unknownError
    }
}
