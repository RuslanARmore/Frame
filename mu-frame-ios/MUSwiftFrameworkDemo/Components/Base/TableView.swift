//
//  TableView.swift

//
//  Created by Dmitry Smirnov on 07.05.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

@IBDesignable
class TableView: UITableView {
    
    @IBInspectable var normalColor: UIColor = .clear
    
    @IBInspectable var selectedColor: UIColor = .clear
    
    @IBInspectable var highlightedColor: UIColor = .clear
}

// MARK: - TableViewCell

class TableViewCell: UITableViewCell {
    
    override var isSelected: Bool { didSet { updateSelected() } }
    
    override var isHighlighted: Bool { didSet { updateHighlighted() } }
    
    // MARK: - Private methods
    
    private func updateSelected() {
        
        backgroundColor = isSelected ? getParentTableView().selectedColor : getParentTableView().normalColor
    }
    
    private func updateHighlighted() {
        
        backgroundColor = isHighlighted ? getParentTableView().highlightedColor : getParentTableView().normalColor
    }
    
    private func getParentTableView() -> TableView {
        
        return superview!.superview as! TableView
    }
}
