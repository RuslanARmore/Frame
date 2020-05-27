//
//  MUCustomView.swift

//
//  Created by Dmitry Smirnov on 26.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUCustomView

@IBDesignable
class MUCustomView: View {
    
    var view: UIView?
    
    @IBInspectable var clearBackground: Bool = false
    
    // MARK: - Override properties
    
    override var isHidden: Bool { didSet { setConstraintIfNeeded() } }
    
    var hasConstraints: Bool { return true }
    
    // MARK: - Private properties
    
    static private var nibCache: [String: UINib] = [:]
    
    private var initSetupTriggered: Bool = false
    
    private var initConstraintTriggered: Bool = false
    
    // MARK: - Override methods
    
    init(fromCodeWithFrame frame: CGRect) {
        
        super.init(frame: frame)
        
        checkViewFromNib()
        
        initSetupIfNeeded()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        checkViewFromNib()
        
        initSetupIfNeeded()
    }
    
    override func prepareForInterfaceBuilder() {
        
        super.prepareForInterfaceBuilder()
        
        initSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        checkViewFromNib()
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        initSetupIfNeeded()
    }
    
    // MARK: - Public methods
    
    func initSetupIfNeeded() {
        
        if !initSetupTriggered { initSetup() }
    }
    
    func initSetup() {
        
        initSetupTriggered = true
        
        updateClearBackground()
    }
    
    private func setConstraintIfNeeded() {
        
        guard isHidden == false, initConstraintTriggered == false, let view = view else {
            
            return
        }
        
        guard hasConstraints else {
            
            insertSubview(view, at: 0)
            
            return
        }
        
        alpha = isHidden ? 0 : 1
        
        initConstraintTriggered = true
        
        insertSubview(view, at: 0)
        
        view.appendConstraints(to: self)
    }
    
    private func checkViewFromNib() {
        
        if let viewFromNib = loadViewFromNib() {
            
            view = viewFromNib
            
            setConstraintIfNeeded()
            
        } else {
            
            view = self
        }
    }
    
    private func loadViewFromNib() -> UIView? {
        
        let nibName: String = String(describing: type(of: self))
        
        var nib: UINib? = MUCustomView.nibCache[nibName]
        
        if nib == nil {
            
            nib = UINib(nibName: nibName, bundle: Bundle(for: MUCustomView.self))
            
            MUCustomView.nibCache[nibName] = nib
        }
        
        return nib!.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    private func updateClearBackground() {
        
        backgroundColor = .clear
        
        if clearBackground {
            
            view?.backgroundColor = .clear
        }
    }
}
