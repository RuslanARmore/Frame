//
//  ApiCore.swift
//
//  Created by Dmitry Smirnov on 22.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

// MARK: - MURemoteDataManagerDelegate

protocol MURemoteDataManagerDelegate: class {
    
    func remoteDataManagerDidFailure(error: Error)
    func remoteDataManagerDidTryAgainWithSuccess(result: Any)
}

// MARK: - MUTransferError

enum MUTransferError: Error {
    
    case parsingError
    case unknownError
}

// MARK: - MUDataTransferManager

class MUDataTransferManager: NSObject {
    
    // MARK: - Public properties
    
    weak var delegate: MURemoteDataManagerDelegate?
    
    var networkManager: MUNetworkManager?
    
    var token: String?
    
    // MARK: - Private properties
    
    private var failureRequests: [MUNetworkRequest] = []
    
    // MARK: - Public
    
    func getObjects<T: MUCodable>(
        
        from url      : String,
        method        : MUNetworkHttpMethod? = nil,
        to            : T.Type,
        params        : [String: Any]? = nil,
        body          : Any? = nil,
        encoding      : MUNetworkEncoding = .url,
        beforeParsing : ((Any) -> Any)? = nil,
        success       : (([T]) -> Void)? = nil,
        failure       : ((Error?) -> Void)? = nil
        
    ) {
        
        request(url: url, method: method, parameters: params, body: body, encoding: encoding, success: { result in
            
            var result: Any = result
            
            if let beforeParsing = beforeParsing {
                
                result = beforeParsing(result)
            }
            
            var items: [T]? = nil
            
            DispatchQueue.global().async { [weak self] in
                
                let data = self?.prepareData(data: result, to: T.self)
                
                DispatchQueue.main.async {
                    
                    if let dataError = data as? Error {
                        
                        self?.returnError(with: dataError, failure: failure)
                        
                        return
                    }
                    
                    if let item = data as? T {
                        
                        items = [item]
                    }
                        
                    else if let data = data as? [T] {
                        
                        items = data
                    }
                    
                    let objects = items ?? []
                    
                    success?(objects)
                }
            }
            
        }, failure: { [weak self] (error) in
            
            self?.returnError(with: error, failure: failure)
        })
    }
    
    func getObject<T: MUCodable>(
        
        from url      : String,
        method        : MUNetworkHttpMethod? = nil,
        to            : T.Type,
        params        : [String: Any]? = nil,
        body          : Any? = nil,
        encoding      : MUNetworkEncoding = .url,
        beforeParsing : ((Any) -> Any)? = nil,
        success       : ((T) -> Void)? = nil,
        failure       : ((Error?) -> Void)? = nil
        
    ) {
        
        getObjects(
            
            from          : url,
            method        : method,
            to            : T.self,
            params        : params,
            body          : body,
            encoding      : encoding,
            beforeParsing : beforeParsing,
            
            success : { objects in
            
                guard let object = objects.first else { return }
                
                success?(object)                
            },
            
            failure : failure
        )
    }
    
    func getValue(
        
        from url : String,
        method   : MUNetworkHttpMethod? = nil,
        params   : [String: Any]? = nil,
        body     : Any? = nil,
        success  : ((String) -> Void)? = nil,
        failure  : ((Error?) -> Void)? = nil
        
    ) {
        
        request(url: url, method: method, parameters: params, body: body, success: { [weak self] (data) in
            
            guard let valueString = data as? String else {
                
                self?.returnError(with: MUTransferError.parsingError, failure: failure)
                
                return
            }
            
            success?(valueString)
            
        }, failure: failure)
    }
    
    func request(
        
        url        : String,
        method     : MUNetworkHttpMethod? = nil,
        parameters : [String: Any]? = nil,
        body       : Any? = nil,
        encoding   : MUNetworkEncoding = .url,
        success    : ((Any) -> Void)? = nil,
        failure    : ((Error?) -> Void)? = nil
        
    ) {
        
        if checkHasTestResponse() {
            
            return simulateFirstResponseWithDelay(success: success, failure: failure)
        }
        
        let defaultMethod: MUNetworkHttpMethod = parameters == nil ? .get : .post
        
        let request = MUNetworkRequest(
            
            url     : url,
            method  : method ?? defaultMethod,
            params  : parameters,
            body    : body,
            success : success,
            failure : failure
        )
        
        let recipient = MUErrorManager.recipient
        
        networkManager?.request(
            
            url        : url,
            method     : method ?? defaultMethod,
            parameters : parameters,
            body       : body,
            encoding   : encoding,
            headers    : getHeaders(),
            success    : { [weak self] (result) in
                
                self?.removeSameFailureRequest(with: request)
            
                self?.handlerResponse(result: result, success: success, failure: failure)
            
            }, failure: { [weak self] (error,result) in
                
                switch error {
                case .connectionError?, .serverError? : self?.addFailureRequest(with: request)
                default                               : break
                }
                
                self?.handleFailure(result: result, error: error, recipient: recipient, completion: failure)
            }
        )
    }
    
    func getHeaders() -> [String: String] {
        
        var headers: [String: String] = [:]
        
        if let token = token {
            
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
    
    func tryAgainFailureRequests() {
        
        guard failureRequests.count > 0 else {
            
            delegate?.remoteDataManagerDidFailure(error: MUTransferError.unknownError)
            
            return
        }
        
        let requests = failureRequests
        
        failureRequests.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) { [weak self] in
            
            for failRequest in requests {
                
                self?.request(
                    
                    url        : failRequest.url,
                    method     : failRequest.method,
                    parameters : failRequest.params,
                    
                    success    : { [weak self] (result) in
                        
                        failRequest.success?(result)
                        
                        self?.delegate?.remoteDataManagerDidTryAgainWithSuccess(result: failRequest)
                    },
                    
                    failure    : failRequest.failure
                )
            }
        }
    }
    
    func handlerResponse(
        
        result    : Any,
        recipient : NSObject? = nil,
        success   : ((Any) -> Void)?     = nil,
        failure   : ((Error?) -> Void)?  = nil
        
    ) {

        success?(result)
    }
    
    func handleFailure(result: Any?, error: MUNetworkError?, recipient: NSObject?, completion : ((Error?) -> Void)? = nil) {
        
        returnError(with: error, recipient: recipient, failure: completion)
    }
    
    func prepareData<Object: MUCodable>(data: Any, to: Object.Type) -> Any? {
        
        if let item = data as? [String: Any] {

            guard let object = MUSerializationManager.decode(item: item, to: Object.self) else {
                
                return MUTransferError.parsingError
            }

            return object
        }

        if let items = data as? [[String: Any]] {

            var resultArray: [Any] = []

            for item in items {

                guard let object = MUSerializationManager.decode(item: item, to: Object.self) else {
                    
                    return MUTransferError.parsingError
                }

                resultArray.append(object)
            }

            return resultArray
        }

        if let items = data as? [String: [String: Any]] {

            var resultArray: [Any] = []

            for (_, item) in items {

                guard let object = MUSerializationManager.decode(item: item, to: Object.self) else {
                    
                    return MUTransferError.parsingError
                }

                resultArray.append(object)
            }

            return resultArray
        }

        return nil
    }
    
    func cancelAllRequests() {
        
        networkManager?.cancelAllRequests()
    }
    
    func returnError(with error: Error?, recipient: NSObject? = nil, failure: ((Error?) -> Void)? = nil) {
        
        if let failure = failure {
            
            return failure(error)
        }
        
        MUErrorManager.post(with: error ?? MUTransferError.unknownError, for: recipient)
    }
    
    // MARK: - Private
    
    private func addFailureRequest(with request: MUNetworkRequest) {
        
        failureRequests.append(request)
    }
    
    private func removeSameFailureRequest(with request: MUNetworkRequest) {
        
        if let index = failureRequests.index(where: { $0.method == request.method } )  {
            
            failureRequests.remove(at: index)
        }
    }
}

// MARK: - Test

extension MUDataTransferManager {
    
    // MARK: - Response
    
    struct Response {
        
        let error: Error?
        
        let data: Any?
        
        let delay: TimeInterval
    }
    
    // MARK: - Private properties
    
    static private var responseArray: [Response] = []
    
    // MARK: - Public methods
    
    static func addResponse(withError error: Error?, delay: TimeInterval = 0) {
        
        responseArray.append(Response(error: error, data: nil, delay: delay))
    }
    
    static func addResponse(with data: Any, delay: TimeInterval = 0) {
        
        responseArray.append(Response(error: nil, data: data, delay: delay))
    }
    
    func checkHasTestResponse() -> Bool {
        
        return MUDataTransferManager.responseArray.count > 0
    }
    
    func simulateFirstResponseWithDelay(success: ((Any) -> Void)? = nil, failure: ((Error?) -> Void)? = nil) {
        
        guard let response = MUDataTransferManager.responseArray.first else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + response.delay) { [weak self] in
            
            self?.simulateFirstResponse(success: success, failure: failure)
        }
    }
    
    func simulateFirstResponse(success: ((Any) -> Void)? = nil, failure: ((Error?) -> Void)? = nil) {
        
        guard let response = MUDataTransferManager.responseArray.first else { return }
        
        MUDataTransferManager.responseArray.remove(at: 0)
        
        if let error = response.error {
            
            handleFailure(
                
                result     : nil,
                error      : error as? MUNetworkError,
                recipient  : MUErrorManager.recipient,
                completion : failure
            )
            
        } else if let data = response.data {
            
            handlerResponse(result: data, success: success, failure: failure)
        }
    }
}
