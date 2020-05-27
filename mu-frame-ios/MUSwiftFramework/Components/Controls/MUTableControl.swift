//
//  MUTableControl.swift
//
//  Created by Dmitry Smirnov on 01/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUTableControl

class MUTableControl: NSObject {
    
    // MARK: - Event
    
    enum Event {
        
        case move, insert, delete, update
    }
    
    // MARK: - Public properties
    
    weak var controller: MUListController?
    
    weak var delegate: MUListControlDelegate?
    
    weak var tableView: UITableView?
    
    var hasSections: Bool = false
    
    var isAnimated: Bool = true
    
    var animationStyle: UITableView.RowAnimation = .fade
    
    var objects: [MUModel] = [] { didSet { updateObjects() } }
    
    // MARK: - Private properties
    
    private var sections: [String] = []
    
    private var groupedObjects: [[MUModel]] = []
    
    private var oldSections: [String] = []
    
    private var oldGroupedObjects: [[MUModel]] = []
    
    private var reservePositionsArray: [Int: String] = [:]
    
    // MARK: - Public methods
    
    func setup(with controller: MUListController) {
        
        tableView = controller.tableView
        
        tableView?.delegate = self
        
        tableView?.dataSource = self
        
        delegate = controller
        
        self.controller = controller
    }
    
    private func getIndexPath(row: Int?, section: Int? = nil) -> IndexPath {
        
        return IndexPath(row: row ?? 0, section: section ?? 0)
    }
    
    func getCell(for object: MUModel?) -> UITableViewCell? {
        
        guard let object = object, let visibleCells = tableView?.visibleCells else { return nil }
        
        for cell in visibleCells {
            
            guard let cell = cell as? MUTableCell, let cellObject = cell.object else {
                
                continue
            }
            
            if cellObject == object {
                
                return cell
            }
        }
        
        return nil
    }
    
    func getIndex(for targetObject: MUModel, in objects: [MUModel]? = nil) -> Int? {
        
        for (index,object) in (objects ?? self.objects).enumerated() {
            
            if object.primaryKey == targetObject.primaryKey {
                
                return index
            }
        }
        
        return nil
    }
    
    func getIndexPath(for targetObject: MUModel, in objects: [[MUModel]]? = nil) -> IndexPath? {
        
        for (section,objects) in (objects ?? groupedObjects).enumerated() {
            
            for (row,object) in objects.enumerated() {
                
                if object.primaryKey == targetObject.primaryKey {
                    
                    return IndexPath(row: row, section: section)
                }
            }
        }
        
        return nil
    }
    
    func didSelectRow(cell: MUTableCell, at index: IndexPath) {
        
    }
    
    func getSection(for object: MUModel) -> String {
        
        return delegate?.getSection(for: object) ?? ""
    }
    
    func reloadObjects(animated: Bool = true) {
        
        if animated {
            
            updateObjects()
        } else {
            tableView?.reloadData()
        }
    }
    
    func updateObjects() {
        
        oldSections = self.sections
        
        oldGroupedObjects = self.groupedObjects
        
        groupObjects()
        
        delegate?.objectDidChanged(with: objects)
    }
    
    func reservePosition(at position: Int, forCell cellIdentifier: String, update: Bool = false) {
        
        reservePositionsArray[position] = cellIdentifier
        
        if update {
            
            updateObjects()
        }
    }
    
    func removeReserve(at position: Int) {
        
        reservePositionsArray.removeValue(forKey: position)
        
        updateObjects()
    }
    
    // MARK: - Private methods
    
    private func updateSections(with oldSections: [String]) {
        
        var sectionsToDelete: [String] = oldSections
        
        for (newIndex,newSection) in sections.enumerated() {
            
            guard let index = oldSections.index(of: newSection) else {
                
                changeSection(at: newIndex, for: .insert)
                
                continue
            }
            
            if index != newIndex {
                
                changeSection(at: newIndex, for: .move)
            }
            
            if let deleteIndex = sectionsToDelete.index(of: newSection) {
                
                sectionsToDelete.remove(at: deleteIndex)
            }
        }
        
        for section in sectionsToDelete {
            
            guard let index = oldSections.index(of: section)  else { continue }
            
            changeSection(at: index, for: .delete)
        }
    }
    
    private func updateGroupedObjects(with oldGroupedObjects: [[MUModel]]) {
        
        var objectsToDelete: [[MUModel]] = oldGroupedObjects
        
        for (newSection,newObjects) in groupedObjects.enumerated() {
            
            for (newRow,newObject) in newObjects.enumerated() {
                
                let newIndexPath = IndexPath(row: newRow, section: newSection)
                
                guard let oldIndexPath = getIndexPath(for: newObject, in: oldGroupedObjects) else {
                    
                    changeRow(at: newIndexPath, for: .insert)
                    
                    continue
                }
                
                if oldIndexPath == newIndexPath {
                    
                    if delegate?.isObjectChanged(for: newObject) ?? false {
                        
                        changeRow(from: oldIndexPath, at: newIndexPath, for: .update)
                    } else {
                        updateRow(at: oldIndexPath, with: newObject)
                    }
                }
                
                if oldIndexPath != newIndexPath {
                    
                    changeRow(from: oldIndexPath, at: newIndexPath, for: .move)
                    
                    updateRow(at: oldIndexPath, with: newObject)
                }
                
                if let indexPath = getIndexPath(for: newObject, in: objectsToDelete) {
                    
                    objectsToDelete[indexPath.section].remove(at: indexPath.row)
                }
            }
        }
        
        for (_,objects) in objectsToDelete.enumerated() {
            
            for (_,object) in objects.enumerated() {
                
                if let indexPath = getIndexPath(for: object, in: oldGroupedObjects) {
                    
                    changeRow(from: indexPath, for: .delete)
                }
            }
        }
    }
    
    private func changeRow(from oldIndex: IndexPath? = nil, at index: IndexPath? = nil, for type: Event) {
        
        switch type {
        case .insert : tableView?.insertRows(at: [index!], with: animationStyle)
        case .update : tableView?.reloadRows(at: [oldIndex!], with: animationStyle)
        case .delete : tableView?.deleteRows(at: [oldIndex!], with: animationStyle)
        case .move   : tableView?.moveRow(at: oldIndex!, to: index!)
        }
    }
    
    private func changeSection(at index: Int, for type: Event) {
        
        switch type {
        case .insert : tableView?.insertSections([index], with: .top)
        case .delete : tableView?.deleteSections([index], with: .top)
        case .update : tableView?.reloadSections([index], with: .none)
        default      : break
        }
    }
    
    private func updateRow(at indexPath: IndexPath, with newObject: MUModel) {
        
        (tableView?.cellForRow(at: indexPath) as? MUTableCell)?.setup(with: newObject)
    }
    
    private func checkAreDuplicateKeysExist(objects: [MUModel]) -> Bool {
        
        let objects = objects.enumerated()
        
        for (index,object) in objects {
            
            for (secondIndex, secondObject) in objects {
                
                if object.primaryKey == secondObject.primaryKey && index != secondIndex {
                    
                    Log.error("error: objects has duplicate primary keys = \(object.primaryKey) at \(index)")
                    
                    return true
                }
            }
        }
        
        return false
    }
    
    private func groupObjects() {
        
        if hasSections {
            
            groupObjectsWithSections()
            
        } else {
            
            groupedObjects = [objects]
            
            sections = [""]
        }
        
        addReserveCells()
        
        updateTable(animated: isAnimated)
    }
    
    private func groupObjectsWithSections() {
        
        var groupedObjects: [[MUModel]] = []
        
        var sections: [String] = []
        
        for object in objects {
            
            let section = getSection(for: object)
            
            if !sections.contains(section) {
                
                sections.append(section)
                
                groupedObjects.append([object])
                
                continue
            }
            
            groupedObjects[sections.index(of: section)!].append(object)
        }
        
        self.sections = sections
        
        self.groupedObjects = groupedObjects
    }
    
    private func addReserveCells() {
        
        if reservePositionsArray.count > 0 && groupedObjects.count > 0 {
            
            for (position,_) in reservePositionsArray {
                
                if position < groupedObjects[0].count {
                    
                    let emptyModel = MUModel()
                    
                    emptyModel.defaultKey = "reserve_cell_at_\(position)"
                    
                    groupedObjects[0].insert(emptyModel, at: position)
                }
            }
        }
    }
    
    private func checkAreAnimationAvailable() -> Bool {
        
        return animationStyle != .none && checkAreDuplicateKeysExist(objects: objects) == false
    }
    
    private func updateTable(animated: Bool) {
        
        guard animated, checkAreAnimationAvailable() else {
            
            tableView?.reloadData()
            
            return
        }
        
        for section in oldGroupedObjects {
            
            if checkAreDuplicateKeysExist(objects: section) {
                
                tableView?.reloadData()
                
                return
            }
        }
        
        let color = tableView?.separatorColor
        
        tableView?.separatorColor = .clear
        
        tableView?.beginUpdates()
        
        updateSections(with: oldSections)
        
        updateGroupedObjects(with: oldGroupedObjects)
        
        tableView?.endUpdates()
        
        tableView?.separatorColor = color
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MUTableControl: UITableViewDelegate, UITableViewDataSource {
    
    func tableViewCell(for object: MUModel, at indexPath: IndexPath) -> MUTableCell? {
        
        let cellIdentifier = delegate?.cellIdentifier(for: object, at: indexPath) ?? "Cell"
        
        return tableView?.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MUTableCell
    }
    
    func tableViewCellSetup(cell: MUTableCell, indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = delegate?.tableView?(tableView, cellForRowAt: indexPath) {
            
            return cell
        }
        
        if let cellIdentifier = reservePositionsArray[indexPath.row] {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            (cell as? MUTableCell)?.setup(sender: controller)
            
            return cell
        }
        
        let object = groupedObjects[indexPath.section][indexPath.row]
        
        guard let cell = tableViewCell(for: object, at: indexPath) else {
            
            Log.error("error: could not create cell")
            
            return UITableViewCell()
        }
        
        cell.backgroundColor = .clear
        
        tableViewCellSetup(cell: cell, indexPath: indexPath)
        
        cell.setup(with: object, sender: controller)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return delegate?.tableView?(tableView, numberOfRowsInSection: section) ?? groupedObjects.count > 0 ? groupedObjects[section].count : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard hasSections else { return nil }
        
        let cell = tableView.dequeueReusableCell(
            
            withIdentifier : "Section",
            for            : IndexPath(row: 0, section: 0)
        )
        
        (cell as? MUTableSection)?.setup(with: sections[section])
        
        return cell.subviews[0]
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return hasSections ? UITableView.automaticDimension : 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return hasSections ? UITableView.automaticDimension : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return delegate?.tableView?(tableView, heightForRowAt: indexPath) ?? tableView.rowHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return groupedObjects.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let didSelect = delegate?.tableView(_:didSelectRowAt:) {
            
            didSelect(tableView, indexPath)
            
        } else {
            
            guard let cell = tableView.cellForRow(at: indexPath) as? MUTableCell else {
                
                return Log.error("error: could not find cell for indexPath \(indexPath)")
            }
            
            guard let object = cell.object else {
                
                return Log.error("error: cell object is nil")
            }
            
            delegate?.cellDidSelected(for: object)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension MUTableControl: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        delegate?.scrollDidScroll(scrollView)
    }
}

// MARK: - MUTableCell

class MUTableCell: UITableViewCell {
    
    var object: MUModel?
    
    func setup(with object: MUModel, sender: Any? = nil) {
        
        self.object = object
    }
    
    func setup(sender: Any? = nil) {
        
    }
}

// MARK: - MUTableSection

class MUTableSection: UITableViewCell {
    
    func setup(with section: String) {
        
    }
}
