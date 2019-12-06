//
//  File.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/6/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class PickerViewViewAdapter
    : NSObject
    , UIPickerViewDataSource
    , UIPickerViewDelegate
    , RxPickerViewDataSourceType
    , SectionedViewDataSourceType {
    typealias Element = [[CustomStringConvertible]]
    private var items: [[CustomStringConvertible]] = []
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        _ = try? model(at: IndexPath(row: row, section: component))
    }
    
    func model(at indexPath: IndexPath) throws -> Any {
        return items[indexPath.section][indexPath.row] as! PhotoCategory
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let parentView = UIView()
        let label = UILabel(frame: CGRect(x: 50, y: 10, width: 150, height: 50))
        label.numberOfLines = 2

        let categoryView = CategoryMarker(frame: CGRect(x: -10, y: 10, width: 50, height: 50))
        categoryView.color = UIColor(hex: (items[component][row] as! PhotoCategory).hexColor)!
        label.text = (items[component][row] as! PhotoCategory).description.uppercased()
        
        parentView.addSubview(label)
        parentView.addSubview(categoryView)
        return parentView
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 180
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 70
    }
    
    func pickerView(_ pickerView: UIPickerView, observedEvent: Event<Element>) {
        Binder(self) { (adapter, items) in
            adapter.items = items
            pickerView.reloadAllComponents()
        }.on(observedEvent)
    }
    
    func update(_ pickerView: UIPickerView, items: [[CustomStringConvertible]]) {
        self.items = items
        pickerView.reloadAllComponents()
    }
}
