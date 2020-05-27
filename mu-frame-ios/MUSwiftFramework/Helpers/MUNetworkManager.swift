//
//  MUNetworkManager.swift
//
//  Created by Dmitry Smirnov on 1/02/2019.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireNetworkActivityIndicator

// MARK: - MUNetworkError

enum MUNetworkError: Error {
    
    case connectionError
    case serverError
    case unknownError
    case parsingError
    case httpError(Int)
}

// MARK: - MUNetworkConfiguration

private struct MUNetworkConfiguration {
    
    static let timeoutForRequestInSecods: TimeInterval = 15
    
    static let timeoutForResourceInSecods: TimeInterval = 300
}

// MARK: - MUNetworkManager

class MUNetworkManager: NSObject {
    
    var serverUrl: String?
    
    // MARK: - Private properties
    
    private let sessionManager: Alamofire.SessionManager!
    
    private let reachabilityManager = Alamofire.NetworkReachabilityManager()!
    
    private var numberOfRequests = 0
    
    // MARK: - Override methods
    
    override init() {
        
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = MUNetworkConfiguration.timeoutForRequestInSecods
        
        configuration.timeoutIntervalForResource = MUNetworkConfiguration.timeoutForResourceInSecods
        
        sessionManager = Alamofire.SessionManager(configuration: configuration)
        
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        super.init()
    }
    
    convenience init(serverUrl: String) {
        
        self.init()
        
        self.serverUrl = serverUrl
    }
    
    // MARK: - Public methods
    
    func request (
        
        url        : String,
        method     : MUNetworkHttpMethod,
        parameters : [String: Any]? = nil,
        body       : Any? = nil,
        encoding   : MUNetworkEncoding = .url,
        headers    : [String: String] = [:],
        queue      : DispatchQueue?  = nil,
        success    : @escaping (Any) -> Void,
        failure    : @escaping (MUNetworkError?,Any?) -> Void
    )
    
    {
        
        let requestId = getRequestId()
        
        guard let serverUrl = serverUrl else {
            
            failure(MUNetworkError.serverError, nil)
            
            return Log.error("error: server url is nil")
        }
        
        let requestUrl = serverUrl + url
        
        logRequest(
            
            url        : requestUrl,
            method     : method,
            headers    : headers,
            parameters : parameters,
            body       : body,
            requestId  : requestId
        )
        
        guard let method: HTTPMethod = HTTPMethod.init(rawValue: method.rawValue) else { return }
        
        sessionManager
            
            .request(
            
                requestUrl,
                method     : method,
                parameters : parameters,
                encoding   : convertEncoding(with: encoding, body: body),
                headers    : headers
            )
            
            .responseJSON(queue: queue) { [weak self] (responseObject) -> Void in
                
                self?.responseHandler(
                    
                    requestUrl     : requestUrl,
                    requestId      : requestId,
                    responseObject : responseObject,
                    success        : success,
                    failure        : failure
                )
            }
    }
    
    func cancelAllRequests() {
        
        sessionManager.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach      { $0.cancel() }
            downloadData.forEach    { $0.cancel() }
        }
    }
    
    // MARK: - Private methods
    
    private func responseHandler(
        
        requestUrl     : String,
        requestId      : Int,
        responseObject : DataResponse<Any>,
        success        : @escaping (Any) -> Void,
        failure        : @escaping (MUNetworkError?,Any?) -> Void
    ) {
        
        logResponse(with: responseObject, requestId: requestId)
        
        if responseObject.response?.statusCode == nil, let error = responseObject.result.error as NSError? {
            
            switch error.code {
            case -999         : return
            case -1009, -1005 : failure(MUNetworkError.connectionError, nil)
            default           : failure(MUNetworkError.serverError, nil)
            }
            
            Log.error("\n[\(requestId)] Handle error:\n\(responseObject.result.error! as NSError)\n")
            
            return
        }
        
        guard let statusCode = responseObject.response?.statusCode else {
            
            return failure(MUNetworkError.unknownError, nil)
        }
        
        guard statusCode == 200 else {
            
            switch statusCode {
            case -1009, -1004, -1001 : failure(MUNetworkError.connectionError, nil)
            case 500,501,502,503,504 : failure(MUNetworkError.serverError, responseObject.result.value)
            default                  : failure(MUNetworkError.httpError(statusCode), responseObject.result.value)
            }
            
            return
        }
        
        success(responseObject.result.value ?? [])
    }
    
    // MARK: - Log methods
    
    private func logRequest(url: String, method: MUNetworkHttpMethod, headers: [String: String], parameters: [String: Any]? = nil, body: Any? = nil, requestId: Int) {
        
        let bodyDict: [String: Any?] = [getTypeName(of: body) : body]
        
        let logDictionary: NSDictionary = [
            
            "Headers"    : headers as NSDictionary? ?? "Empty",
            "Query"      : parameters as NSDictionary? ?? "Empty",
            "Body"       : bodyDict 
        ]
        
        Log.event("\n[\(requestId)] (\(method)) \(url)\nRequest:\n\(logDictionary)\n")
    }
    
    private func getTypeName(of params: Any?) -> String {
        
        guard let params = params else {
            
            return "Nil"
        }
        
        if let _ = params as? [String: Any] {
            
            return "Object"
            
        } else if let _ = params as? [Any] {
            
            return "Array"
            
        } else {
            
            return "Value"
        }
    }
    
    private func logResponse(with responseObject: DataResponse<Any>, requestId: Int) {
        
        let body = responseObject.result.value as? NSDictionary ?? responseObject.result.value as? NSArray
        
        let logDictionary = [
            
            "Headers" : responseObject.response?.allHeaderFields as Any,
            "_Body"   : body ?? responseObject.result.value ?? ""
        ]
        
        let statusCode = responseObject.response?.statusCode ?? -1
        
        Log.event("\n[\(requestId)] Response (code: \(statusCode)):\n\(logDictionary)\n")
    }
    
    private func logError(with responseObject: DataResponse<Any>, requestId: Int) {
        
        let responseDictionary = [
            
            "Headers" : responseObject.response?.allHeaderFields as Any,
            "_Data"   : String(data: responseObject.data ?? Data(), encoding: .utf8) ?? "empty"
        ]
        
        Log.event("\n[\(requestId)] Handle error response:\n\(responseDictionary)\n")
    }
    
    private func getRequestId() -> Int {
        
        numberOfRequests += 1
        
        return numberOfRequests
    }
    
    private func filterParams(with params: Any) -> [String: Any]? {
        
        return params as? [String: Any]
    }
    
    private func convertEncoding(with encoding: MUNetworkEncoding, body: Any? = nil) -> ParameterEncoding {
        
        var result: ParameterEncoding = encoding == .url ? URLEncoding.default : JSONEncoding.default
        
        if let body = body as? [Any] {
            
            result = JSONStringEncoding(with: body)
            
        } else if let body = body {
            
            result = JSONStringEncoding(with: body)
        }
        
        return result
    }
}

// MARK: - MUNetworkManager

extension MUNetworkManager {
    
    static let toArray = "_toArray"
}

// MARK: - MUNetworkRequest

struct MUNetworkRequest {
    
    var url     : String
    var method  : MUNetworkHttpMethod
    var params  : [String: Any]? = nil
    var body    : Any? = nil
    var success : ((Any) -> Void)? = nil
    var failure : ((Error?) -> Void)? = nil
}

// MARK: - MUNetworkManager

extension MUNetworkManager {
    
    static var isConnected: Bool { return NetworkReachabilityManager()!.isReachable }
}

// MARK: - ApiCoreRequestEncoding

enum MUNetworkHttpMethod: String {
    
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

// MARK: - MUNetworkEncoding

enum MUNetworkEncoding {
    
    case url, json
}

// MARK: - ParameterEncoding

struct JSONStringEncoding: ParameterEncoding {
    
    // MARK: - Private properties
    
    private let value: Any
    
    // MARK: - Public methods
    
    init(with value: Any) {
        
        self.value = value
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        
        var urlRequest = try URLEncoding().encode(urlRequest, with: parameters)
        
        if let value = value as? String {
            
            urlRequest.httpBody = "\"\(value)\"".data(using: .utf8, allowLossyConversion: false)
            
        } else if let value = value as? Int {
            
            urlRequest.httpBody = "\"\(value)\"".data(using: .utf8, allowLossyConversion: false)
            
        } else {
            
            let data = try? JSONSerialization.data(withJSONObject: value, options: [])
            
            urlRequest.httpBody = data            
        }
        
        if urlRequest.httpBody != nil {
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return urlRequest
    }
}
