//
//  BehaviorController.swift
//  MUSwiftFramework
//
//  Created by Dmitry Smirnov on 04/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

typealias BehaviorOptions = [BehaviorOption]

// MARK: - BehaviorPreset

struct BehaviorPreset {
    
    static let dataOnly: BehaviorOptions = [
        
        BehaviorOption.loadFromCacheOnLoad,
        BehaviorOption.requestDataOnLoad,
        BehaviorOption.cacheOnDataUpdated
    ]
    
    static let defaultTab: BehaviorOptions = [
        
        BehaviorOption.loadFromCacheOnLoad,
        BehaviorOption.requestDataOnLoad,
        BehaviorOption.cacheOnDataUpdated,
        BehaviorOption.showErrorInAlert,
        BehaviorOption.showEmptyStateIfNoDataAndNoError
    ]
}

// MARK: - BehaviorOption

enum BehaviorOption: String {
    
    case requestTokenIfDidExpired
    case makeLogoutIfUpdateTokenDidFailure
    
    case requestDataOnLoad
    case updateDataOnReturn
    case repeatRequestOnErrorAfterDelay
    case repeatRequestOnErrorUntilSuccess
    
    case loadFromCacheOnLoad
    case cacheOnDataUpdated
    
    case doNotShowErrorInAlertOnPagination
    case doNotShowErrorInAlertOnAppear
    
    case showErrorScreenIfNoConnect
    case showErrorScreenfNoAuthorized
    case showErrorScreenIfNoData
    
    case showEmptyStateIfNoDataAndNoError
    case showConnectionErrorInAlert
    case showServerErrorInAlert
    case showErrorInAlert
    
    case changeColumnsOnLandscape
}

// MARK: - BehaviorController

class BehaviorController: MUBehaviorController {
    
    // MARK: - Behavior properties
    
    var isPresented: Bool = false { didSet { if isPresented { doOnPresented() } } }
    
    var isReturning: Bool = false { didSet { doOnReturning() } }
    
    var isLandscape: Bool = false { didSet { doOnLandscape() } }
    
    var isDataRequested: Bool = false { didSet { doOnDataRequested() } }
    
    var isDataUpdated: Bool = false { didSet { doOnDataChanged() } }
    
    var isCacheLoaded: Bool = false
    
    var isNoData: Bool = false
    
    var lastError: Error? { didSet { doOnLastError() } }
    
    weak var controller: MUViewController!
    
    // MARK: - Public methods
    
    convenience init(with controller: MUViewController, options: BehaviorOptions) {
        
        self.init()
        
        self.controller = controller
        
        self.behaviorManager.options = options.map( { $0.rawValue } )
    }
    
    // MARK: - Private methods
    
    private func doOnPresented() {
        
        requestTokenIfDidExpired()
        
        makeLogoutIfUpdateTokenDidFailure()
        
        loadFromCacheOnLoad()
        
        requestDataOnLoad()
    }
    
    private func doOnReturning() {
        
        updateDataOnReturn()
    }
    
    private func doOnLandscape() {
        
        changeColumnsOnLandscape()
    }
    
    private func doOnDataRequested() {
        
        repeatRequestOnErrorAfterDelay()
        
        repeatRequestOnErrorUntilSuccess()
        
        doNotShowErrorInAlertOnPagination()
        
        doNotShowErrorInAlertOnAppear()
        
        showErrorScreenIfNoConnect()
        
        showErrorScreenfNoAuthorized()
        
        showErrorScreenIfNoData()
        
        showServerErrorInAlert()
        
        showConnectionErrorInAlert()
    }
    
    private func doOnDataChanged() {
        
        cacheOnDataUpdated()
        
        showEmptyStateIfNoDataAndNoError()
    }
    
    private func doOnLastError() {
        
        showDataFromCacheIfNoConnect()
        
        showErrorInAlert()
    }
    
    private func requestTokenIfDidExpired() {
        
        guard check(behavior: BehaviorOption.requestTokenIfDidExpired.rawValue) else { return }
    }
    
    private func makeLogoutIfUpdateTokenDidFailure() {
        
        guard check(behavior: BehaviorOption.makeLogoutIfUpdateTokenDidFailure.rawValue) else { return }
        
    }
    
    private func requestDataOnLoad() {
        
        guard check(behavior: BehaviorOption.requestDataOnLoad.rawValue) else { return }
        
        (controller as? MUListController)?.requestObjects(withIndicator: true)
    }
    
    private func repeatRequestOnErrorAfterDelay() {
        
        guard check(behavior: BehaviorOption.repeatRequestOnErrorAfterDelay.rawValue) else { return }
        
    }
    
    private func repeatRequestOnErrorUntilSuccess() {
        
        guard check(behavior: BehaviorOption.repeatRequestOnErrorUntilSuccess.rawValue) else { return }
        
    }
    
    private func updateDataOnReturn() {
        
        guard check(behavior: BehaviorOption.updateDataOnReturn.rawValue) else { return }
        
    }
    
    private func loadFromCacheOnLoad() {
        
        guard check(behavior: BehaviorOption.loadFromCacheOnLoad.rawValue) else { return }
        
        (controller as? ListController)?.cacheControl?.load()
        
        isCacheLoaded = true
    }
    
    private func cacheOnDataUpdated() {
        
        guard check(behavior: BehaviorOption.cacheOnDataUpdated.rawValue) else { return }
        
        guard isCacheLoaded else { return }
        
        (controller as? ListController)?.cacheControl?.save()
    }
    
    private func doNotShowErrorInAlertOnPagination() {
        
    }
    
    private func doNotShowErrorInAlertOnAppear() {
        
    }
    
    private func showDataFromCacheIfNoConnect() {
        
    }
    
    private func showErrorScreenIfNoConnect() {
        
    }
    
    private func showErrorScreenfNoAuthorized() {
        
    }
    
    private func showErrorScreenIfNoData() {
        
    }
    
    private func showEmptyStateIfNoDataAndNoError() {
        
        guard check(behavior: BehaviorOption.showEmptyStateIfNoDataAndNoError.rawValue) else { return }
        
        (controller as? MUListController)?.emptyStateControl.isHidden = !isNoData
    }
    
    private func showConnectionErrorInAlert() {
        
    }
    
    private func showServerErrorInAlert() {
        
    }
    
    private func showErrorInAlert() {
        
        guard check(behavior: BehaviorOption.showErrorInAlert.rawValue) else { return }
        
        controller.showPopup(title: "Error!", message: "Don't worry. This is demo error.")
    }
    
    private func changeColumnsOnLandscape() {
        
    }
}
