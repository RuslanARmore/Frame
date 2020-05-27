//
//  MUPaginationControl.swift
//
//  Created by Dmitry Smirnov on 01/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUPaginationControlDelegate

protocol MUPaginationControlDelegate: class {
    
    func paginationControlDidRequestMore(page: Int)
}

// MARK: - MUPaginationControl

class MUPaginationControl: NSObject {
    
    // MARK: - Public properties
    
    weak var delegate: MUPaginationControlDelegate?
    
    weak var targetView: UIScrollView?
    
    weak var tableControl: MUTableControl?
    
    var page = 1 { didSet { tryRequestMore() } }
    
    var lastPage: Int?
    
    var isLoading: Bool = false
    
    var isLightIndicator: Bool = false
    
    // MARK: - Private properties
    
    private var isTableControlAnimated: Bool = false
    
    private var initialInsetBottom: CGFloat = 0
    
    private var lastVerticalOffset: CGFloat = 0
    
    private var bottomActivityIndicator: MUBottomActivityIndicator?
    
    private var timer: Timer?
    
    // MARK: - Public methods
    
    func setup(with controller: MUListController) {
        
        guard controller.hasPagination else { return }
        
        delegate = controller
        
        targetView = controller.tableView ?? controller.collectionView
        
        tableControl = controller.tableControl
        
        isTableControlAnimated = tableControl?.isAnimated ?? false
    }
    
    func reset() {
        
        page = 1
    }
    
    func cancelLastPage() {
        
        if let lastPage = lastPage {
            
            page = lastPage
            
            self.lastPage = nil
        }
    }
    
    func stopAnimation() {
        
        isLoading = false
        
        tableControl?.isAnimated = isTableControlAnimated
        
        removeActivityIndicator()
    }
    
    func startAnimation() {
        
        isLoading = true
        
        tableControl?.isAnimated = false
        
        createActivityIndicator()
    }
    
    func requestMore() {
        
        delegate?.paginationControlDidRequestMore(page: page)
    }
    
    func scroll(with scrollView: UIScrollView) {
        
        let isScrollDown = lastVerticalOffset < scrollView.contentOffset.y

        lastVerticalOffset = scrollView.contentOffset.y
        
        if isScrollDown && checkNextPage(with: scrollView) {

            lastPage = page

            page += 1

            startAnimation()
        }
        
        bottomActivityIndicator?.updateHeight(with: scrollView)
    }
    
    // MARK: - Pagination
    
    private func tryRequestMore() {
        
        guard page > 1, let lastPage = lastPage, lastPage < page else { return }
        
        delegate?.paginationControlDidRequestMore(page: page)
    }
    
    fileprivate func checkNextPage(with scrollView: UIScrollView, triggerArea: CGFloat = 60) -> Bool {
        
        guard isLoading == false else { return false }
        
        return scrollView.getOffsetFromBottom() < triggerArea
    }
    
    private func createActivityIndicator(withDelay delay: TimeInterval) {
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(createActivityIndicator(_:)), userInfo: nil, repeats: false)
    }
    
    @objc private func createActivityIndicator(_ timer: Timer? = nil) {
        
        guard let targetView = targetView, self.bottomActivityIndicator == nil else { return }
        
        removeActivityIndicator()
        
        let bottomIndicator = MUBottomActivityIndicator()
        
        bottomIndicator.append(to: targetView, lightStyle: isLightIndicator)
        
        self.bottomActivityIndicator = bottomIndicator
        
        initialInsetBottom = targetView.contentInset.bottom
        
        targetView.contentInset.bottom = MUBottomActivityIndicator.bottomInset
        
        timer?.invalidate()
    }
    
    private func removeActivityIndicator() {
        
        timer?.invalidate()
        
        bottomActivityIndicator?.containerView?.removeFromSuperview()
        
        bottomActivityIndicator = nil
        
        targetView?.contentInset.bottom = initialInsetBottom
    }
}

// MARK: - UIScrollView

extension UIScrollView {
    
    func getOffsetFromBottom() -> CGFloat {
        
        return contentSize.height - contentOffset.y - frame.height
    }
}

// MARK: - MUBottomActivityIndicator

class MUBottomActivityIndicator {
    
    // MARK: - Public properties
    
    static let bottomInset: CGFloat = 60
    
    static let animationDuration: TimeInterval = 0.3
    
    weak var containerView: UIView?
    
    // MARK: - Public methods
    
    func append(to view: UIView, lightStyle: Bool) {
        
        guard let superview = view.superview, self.containerView == nil else { return }
        
        let indicator = UIActivityIndicatorView()
        
        if lightStyle {
            
            indicator.style = .white
        } else {
            indicator.style = .gray
        }
        
        indicator.startAnimating()
        
        let containerView = UIView()
        
        containerView.clipsToBounds = true
        
        view.superview?.insertSubview(containerView, aboveSubview: view)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        
        if #available(iOS 11.0, *) {
            
            containerView.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            containerView.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        }
        
        containerView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        
        containerView.addSubview(indicator)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        indicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        
        indicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
        
        self.containerView = containerView
    }
    
    func updateHeight(with scrollView: UIScrollView) {
        
        let offsetFromBottom = scrollView.getOffsetFromBottom()
        
        guard offsetFromBottom <= 0 else { return }
        
        containerView?.setConstraint(type: .height, value: abs(offsetFromBottom))
    }
}
