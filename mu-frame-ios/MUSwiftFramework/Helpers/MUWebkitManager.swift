//
//  MUWebkitManager.swift
//
//  Created by Dmitry Smirnov on 1/02/2019.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit
import WebKit

class MUWebkitManager: NSObject {
    
    // MARK: - Private properties
    
    private weak var webView: WKWebView?
    
    private var initializeHandler: (() -> Void)? = nil
    
    private var completionHandler: (([String: Any]?, Error?) -> Void)? = nil
    
    private static let handlerName = "handler"
    
    private static let timeoutInSeconds: Int = 15
    
    // MARK: - Public methods
    
    func runScript(
        
        htmlFile   : String,
        scripts    : [String] = [],
        source     : String,
        completion : (([String : Any]?, Error?) -> Void)? = nil)
    {
        
        setup(htmlFile: htmlFile, scripts: scripts) { [weak self] in
            
            self?.executeScript(source: source, completion: completion)
        }
    }
    
    func reset() {
        
        self.completionHandler = nil
        
        self.webView?.removeFromSuperview()
        
        self.webView = nil
    }
    
    // MARK: - Private methods
    
    private func setup(htmlFile: String, scripts: [String] = [], completion: (() -> Void)? = nil) {
        
        Log.details("\(htmlFile)")
        
        guard webView == nil else {
            
            prepareWebView()
            
            completion?()            
            return
        }
        
        prepareWebView()
        
        initializeHandler = completion
        
        loadHtml(file: htmlFile)
        
        loadScripts(files: scripts)
    }
    
    private func prepareWebView() {
        
        guard let controller = UIApplication.presentedViewController() else {
            
            Log.error("error: could not find presented vc")
            return
        }
        
        let webView = self.webView ?? WKWebView(frame: controller.view.frame, configuration: getConfiguration())
        
        webView.removeFromSuperview()
        
        webView.alpha = 0
        
        controller.view.addSubview(webView)
        
        self.webView = webView
    }
    
    private func getConfiguration() -> WKWebViewConfiguration {
        
        let contentController = WKUserContentController()
        contentController.add(self, name: MUWebkitManager.handlerName)
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        return config
    }
    
    private func loadScript(file: String) {
        
        let path = FileManager.getPathFromBundle(to: file)
        let data = try? String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
        
        addScript(source: data ?? "")
    }
    
    private func loadScripts(files: [String]) {
        
        for file in files {
            
            loadScript(file: file)
        }
    }
    
    private func loadHtml(file: String) {
        
        let path = Bundle.main.path(forResource: file, ofType: "html")!
        let url  = URL(fileURLWithPath: path)
        
        webView?.load(URLRequest(url: url))
    }
    
    private func addScript(source: String) {
        
        let userScript = WKUserScript(
            
            source           : source,
            injectionTime    : .atDocumentEnd,
            forMainFrameOnly : true
        )
        
        webView?.configuration.userContentController.addUserScript(userScript)
    }
    
    private func executeScript(source: String, completion: (([String: Any]?, Error?) -> Void)? = nil) {
        
        Log.details("\(source)")
       
        self.completionHandler = completion
        
        webView?.evaluateJavaScript(source, completionHandler: { (response, error) in
            
            if let error = error {
                
                Log.error("\(error)")
//                completion?(nil, Error.unknownError)
                
                return
            }
        })
    }
    
    fileprivate func responseHandler(with message: WKScriptMessage) {
        
        if let initializeHandler = initializeHandler {
            
            initializeHandler()
            
            self.initializeHandler = nil
            
            return
        }
        
        parse(message: message)
    }
    
    private func parse(message: WKScriptMessage) {
        
        guard
            
            let responseData = (message.body as? String)?.data(using: .utf8),
            let result = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
            
        else {
                
//            completionHandler?(["error": message.body], Error.parsingError)
            return
        }
        
        completionHandler?(result, nil)
    }
}

// MARK: - WKScriptMessageHandler

extension MUWebkitManager: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard message.name == MUWebkitManager.handlerName else { return }
        
        Log.details("\(message.body)")
        
        responseHandler(with: message)
    }
}
