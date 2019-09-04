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
    
    func model(at indexPath: IndexPath) throws -> Any {
        print(items[indexPath.section][indexPath.row])
        return items[indexPath.section][indexPath.row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let parentView = UIView()
        let label = UILabel(frame: CGRect(x: 60, y: 10, width: 150, height: 50))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 50, height:50))
        imageView.image = UIImage(named: "Categories/\(items[component][row] as! String)")
        label.text = NSLocalizedString(items[component][row] as! String, comment: "").uppercased()
        parentView.addSubview(label)
        parentView.addSubview(imageView)
        
        return parentView
        
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 150
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
}
