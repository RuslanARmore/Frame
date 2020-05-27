//
//  MUViewController.swift
//
//  Created by Dmitry Smirnov on 26.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUViewController

class MUViewController: UIViewController {
    
    class var storyboardName: String { return "" }
    
    class var storyboardIdentifier: String { return String(describing: self) }
    
    // MARK: - Public properties
    
    @IBOutlet weak var keyboardContainer: UIView? { didSet { keyboardControl.containerView = keyboardContainer } }
    
    var isVisible: Bool { return view.isVisible }
    
    var isFirstAppear: Bool = true
    
    var interactivePopGestureEnabled: Bool { return true }
    
    // MARK: - Controls
    
    var keyboardControl = MUKeyboardControl()
    
    var indicatorControl = MUActivityIndicatorControl()
    
    var popupControl = MUPopupControl()
    
    // MARK: - Private properties
    
    private var isNotificationSubscribed: Bool = false
    
    private static var viewControllersArray: [String: MUViewControllerContainer] = [:]
    
    // MARK: Override methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        keyboardControl.setup(with: self)
        
        popupControl.setup(with: self)
        
        subscribeOnCustomNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        navigationController?.delegate = nil
        
        updateViewControllersArray()
        
        configureInteractivePopGestureRecognizer()
        
        subscribeOnNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        isFirstAppear = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        unsubscribeFromNotifications()
    }
    
    func subscribeOnNotifications() {
        
        guard isVisible, isNotificationSubscribed == false else { return }
        
        isNotificationSubscribed = true
        
        keyboardControl.subscribeOnNotifications()
        
        subscribeOnErrorNotifications()
        
        subscribeOnAppNotifications()
    }
    
    func unsubscribeFromNotifications() {
        
        isNotificationSubscribed = false
        
        keyboardControl.unsubscribeOnNotifications()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func subscribeOnCustomNotifications() {
        
    }
    
    func appDidBecomeActive() {
        
    }
    
    func appWillResignActive() {
        
    }
    
    func appErrorDidBecome(error: Error) {
        
        hideActivityIndicator()
    }
    
    // MARK: - Public methods
    
    func close(animated: Bool = true, toRoot: Bool = false, popOnly: Bool = false, completion: (() -> Void)? = nil) {
        
        if let presentingMUViewController = presentingViewController, popOnly == false {
            
            presentingMUViewController.dismiss(animated: animated)
            
            completion?()
        }
            
        else if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            
            if toRoot {
                
                navigationController.popToRootViewController(animated: animated, completion: completion)
            } else {
                navigationController.popViewController(animated: animated, completion: completion)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func configureInteractivePopGestureRecognizer() {
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func updateViewControllersArray() {
        
        MUViewController.viewControllersArray[className] = MUViewControllerContainer(with: self)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MUViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return interactivePopGestureEnabled
    }
}

// MARK: - Errors

extension MUViewController {
    
    func subscribeOnErrorNotifications() {
        
        AppError.recipient = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(appErrorNotification), name: .appErrorDidCome, object: nil)
    }
    
    // MARK: - Private methods
    
    @objc private func appErrorNotification(notification: Notification) {
        
        guard let notification = notification.userInfo?["notification"] as? MUErrorNotification else {
            
            return AppError.unknownError.post()
        }
        
        guard notification.recipient == self else {
            
            return
        }
        
        Log.error("error: \(notification)")
        
        appErrorDidBecome(error: notification.error)
    }
}

// MARK: - Popup

extension MUViewController {
    
    func showPopup(
        
        title       : String,
        message     : String? = nil,
        buttonTitle : String = "OK",
        action      : (() -> Void)? = nil
    ) {
        
        popupControl.showPopup(
            
            title       : title,
            message     : message,
            buttonTitle : buttonTitle,
            action      : action
        )
    }

    func showDialogAlert(

        title             : String,
        message           : String? = nil,
        leftButtonTitle   : String = "Cancel",
        rightButtonTitle  : String = "OK",
        leftButtonStyle   : UIAlertAction.Style = .cancel,
        rightButtonStyle  : UIAlertAction.Style = .default,
        leftButtonAction  : (() -> Void)? = nil,
        rightButtonAction : @escaping (() -> Void)
    ) {

        popupControl.showDialogAlert(

            title             : title,
            message           : message,
            leftButtonTitle   : leftButtonTitle,
            rightButtonTitle  : rightButtonTitle,
            leftButtonStyle   : leftButtonStyle,
            rightButtonStyle  : rightButtonStyle,
            leftButtonAction  : leftButtonAction,
            rightButtonAction : rightButtonAction
        )
    }
    
    func showToast(
        
        title    : String,
        message  : String? = nil,
        duration : TimeInterval = 3
    ) {
        
        popupControl.showToast(
            
            title    : title,
            message  : message,
            duration : duration
        )
    }
    
    func show(
        
        customView                : MUCustomView,
        position                  : MUPopupControl.Position = .center,
        animationType             : MUPopupControl.AnimationType = .fade,
        backgroundColorStyle      : MUPopupControl.BackgroundColorStyle = .dark,
        duration                  : TimeInterval = .infinity,
        isClosedOnBackgroundTouch : Bool = true,
        isClosedOnSwipe           : Bool = true,
        isShadowEnabled           : Bool = true
    ) {
        
        popupControl.show(
            
            customView                : customView,
            position                  : position,
            animationType             : animationType,
            backgroundColorStyle      : backgroundColorStyle,
            duration                  : duration,
            isClosedOnBackgroundTouch : isClosedOnBackgroundTouch,
            isClosedOnSwipe           : isClosedOnSwipe,
            isShadowEnabled           : isShadowEnabled
        )
    }
    
    func show(
        
        controller                : MUViewController,
        position                  : MUPopupControl.Position = .bottom,
        animationType             : MUPopupControl.AnimationType = .translation,
        backgroundColorStyle      : MUPopupControl.BackgroundColorStyle = .dark,
        duration                  : TimeInterval = .infinity,
        isClosedOnBackgroundTouch : Bool = true,
        isClosedOnSwipe           : Bool = false,
        isShadowEnabled           : Bool = true,
        widthRatio                : CGFloat = 1.0,
        heightRatio               : CGFloat = 0.6
    ) {
        
        popupControl.show(
            
            controller                : controller,
            position                  : position,
            animationType             : animationType,
            backgroundColorStyle      : backgroundColorStyle,
            duration                  : duration,
            isClosedOnBackgroundTouch : isClosedOnBackgroundTouch,
            isClosedOnSwipe           : isClosedOnSwipe,
            isShadowEnabled           : isShadowEnabled,
            widthRatio                : widthRatio,
            heightRatio               : heightRatio
        )
    }
    
    func dismissPopup() {
        
        popupControl.dismiss()
    }
}

// MARK: - Instantiate and Presenting

extension MUViewController {
    
    static func find<T: MUViewController>() -> T? {
        
        return MUViewController.viewControllersArray["\(T.self)"]?.controller as? T
    }
    
    static func getInstantiate<T: MUViewController>() -> T? {
        
        guard storyboardName != "" else {
            
            Log.error("error: storyboardName not specified for \(T.self)")
            
            return nil
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as? T
    }
    
    static func push<T: MUViewController>(
        
        to controller  : UIViewController?,
        at index       : Int?            = nil,
        animated       : Bool            = true,
        pushCompletion : (() -> Void)?   = nil,
        setup          : ((T) -> Void)?  = nil)
    {
        
        guard let instantiate: T = getInstantiate() as? T  else {
            
            return Log.error("failed to create instantiate for \(T.self)")
        }
        
        setup?(instantiate)
        
        let navigationController = controller as? UINavigationController ?? controller?.navigationController
        
        if let index = index {
            
            navigationController?.insert(controller: instantiate, at: index)
        } else {
            navigationController?.pushViewController(instantiate, animated: animated)
        }
    }
    
    static func present<T: MUViewController>(
        
        in controller : UIViewController?,
        asRoot        : Bool                       = false,
        animated      : Bool                       = true,
        style         : UIModalPresentationStyle?  = nil,
        setup         : ((T) -> Void)?             = nil
        
        ) {
        
        guard let instantiate: T    = getInstantiate() as? T else {
            
            return
        }
        
        setup?(instantiate)
        
        if let style = style {
            
            instantiate.modalPresentationStyle = style
        }
        
        if asRoot {
            
            controller?.present(createNavigationController(with: instantiate), animated: animated, completion: {})
        } else {
            controller?.present(instantiate, animated: animated, completion: {})
        }
    }
    
    func insert<T: MUViewController>(
        
        controller screen     : T.Type,
        into insertTargetView : UIView?         = nil,
        to appendTargetView   : UIView?         = nil,
        setup                 : ((T) -> Void)?  = nil
    ) {
        
        guard let instantiate: T = screen.getInstantiate() as? T else {
            
            return
        }
        
        setup?(instantiate)
        
        addChild(instantiate)
        
        instantiate.didMove(toParent: self)
        
        if let appendTargetView = appendTargetView {
            
            instantiate.view.frame = appendTargetView.frame
            
            view.insertSubview(instantiate.view, aboveSubview: appendTargetView)
            
            bringToTopNavigationBar()
            
        } else {
            
            (insertTargetView ?? view).addSubview(instantiate.view)
        }
        
        instantiate.view.appendConstraints(to: insertTargetView ?? view)
    }
    
    func bringToTopNavigationBar() {
        
//        for subview in view.subviews {
//            
//            guard let navigationBar = subview as? NavigationBarView else { continue }
//            
//            if let last = view.subviews.last, last != navigationBar {
//                
//                view.addSubview(navigationBar)
//            }
//        }
    }
    
    func insert(controller instantiate: MUViewController, into insertTargetView: UIView? = nil) {
        
        addChild(instantiate)
        
        instantiate.didMove(toParent: self)
        
        (insertTargetView ?? view).addSubview(instantiate.view)
        
        instantiate.view.appendConstraints(to: insertTargetView ?? view)
    }
    
    static func createNavigationController(with controller: MUViewController) -> UINavigationController {
        
        let navigationController = UINavigationController(rootViewController: controller)
        
        navigationController.isNavigationBarHidden = true
        
        return navigationController
    }
}

// MARK: - Activity indicator

extension MUViewController {
    
    func showActivityIndicator(on view: UIView? = nil, delay: TimeInterval = 0.6) {
        
        indicatorControl.showIndicator(above: view ?? self.view, delay: delay)
    }
    
    func hideActivityIndicator() {
        
        indicatorControl.hideIndicator()
    }
}

// MARK: - App

extension MUViewController {
    
    @objc private func appNotification(notification: Notification) {
        
        switch notification.name {
            
        case .appDidBecomeActive: appDidBecomeActive()
        case .appWillResignActive: appWillResignActive()
        default: break
        }
    }
    
    private func subscribeOnAppNotifications() {
        
        NotificationCenter.addObserver(self, selector: #selector(appNotification), name: .appDidBecomeActive)
        NotificationCenter.addObserver(self, selector: #selector(appNotification), name: .appWillResignActive)
    }
}

// MARK: - Notification

extension Notification.Name {
    
    static let appDidBecomeActive     = Notification.Name("appDidBecomeActive")
    static let appWillResignActive    = Notification.Name("appWillResignActive")
    static let appDidEnterBackground  = Notification.Name("appDidEnterBackground")
    static let appWillEnterBackground = Notification.Name("appWillEnterBackground")
}

// MARK: - MUViewControllerContainer

class MUViewControllerContainer {
    
    weak var controller: MUViewController?
    
    convenience init(with controller: MUViewController) {
        
        self.init()
        
        self.controller = controller
    }
}
