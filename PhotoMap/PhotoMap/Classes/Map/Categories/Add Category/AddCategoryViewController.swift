//
//  AddCategoryViewController.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 9/12/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit
import ChromaColorPicker
import RxSwift
import RxCocoa

class AddCategoryViewController: UIViewController, StoryboardInitializable {
    
    var viewModel: AddCategoryViewModel!
    private let bag = DisposeBag()
    private let colorPicker = ChromaColorPicker()
    private var addButton: UIBarButtonItem!
    private var colorPickerWidthConstraint: NSLayoutConstraint!
    private var colorPickerHeightConstraint: NSLayoutConstraint!
    private var centerYConstraint: NSLayoutConstraint!
    private var centerXConstraint: NSLayoutConstraint!
    private var colorPickerleadingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        // DONT WORK
        navigationController?.navigationBar.topItem?.backBarButtonItem?.rx.tap.asControlEvent()
            .bind(to: viewModel.goBack)
            .disposed(by: bag)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass {
            configureView(for: traitCollection)
        }
    }
    
    private func setupView() {
        addButton = UIBarButtonItem(title: "Add New Category", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = addButton
        addButton.isEnabled = false
        setupColorPicker()
    }
    
    private func setupColorPicker() {
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        colorPicker.delegate = self
        colorPicker.stroke = 3
        view.addSubview(colorPicker)
        resizeColorPicker(to: .width, with: 1)
        
        centerXConstraint = NSLayoutConstraint(item: colorPicker, attribute: .centerX, relatedBy: .equal,
                                               toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        centerYConstraint = NSLayoutConstraint(item: colorPicker, attribute: .centerY, relatedBy: .equal,
                                               toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        colorPickerleadingConstraint = NSLayoutConstraint(item: colorPicker, attribute: .leading, relatedBy: .equal,
                                                          toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([
            centerXConstraint,
            centerYConstraint
            ])
        colorPicker.layout()
    }
    
    private func configureView(for traitCollection: UITraitCollection) {
        NSLayoutConstraint.deactivate([colorPickerHeightConstraint, colorPickerWidthConstraint,
                                       centerYConstraint, centerXConstraint, colorPickerleadingConstraint])
        colorPicker.removeConstraints([colorPickerHeightConstraint, colorPickerWidthConstraint,
                                       centerYConstraint, centerXConstraint, colorPickerleadingConstraint])
        switch traitCollection.verticalSizeClass {
        case .compact:
            resizeColorPicker(to: .height, with: 0.8)
            NSLayoutConstraint.activate([
                centerYConstraint,
                colorPickerleadingConstraint
                ])
        default:
            resizeColorPicker(to: .width, with: 0.9)
            NSLayoutConstraint.activate([
                centerXConstraint,
                centerYConstraint
                ])
        }
    }
    
    private func resizeColorPicker(to attribute: NSLayoutConstraint.Attribute, with multiplier: CGFloat) {
        colorPickerWidthConstraint = NSLayoutConstraint(item: colorPicker, attribute: .width, relatedBy: .equal,
                                                        toItem: view, attribute: attribute, multiplier: multiplier, constant: 0)
        colorPickerHeightConstraint = NSLayoutConstraint(item: colorPicker, attribute: .height, relatedBy: .equal,
                                                         toItem: view, attribute: attribute, multiplier: multiplier, constant: 0)
        NSLayoutConstraint.activate([
            colorPickerWidthConstraint,
            colorPickerHeightConstraint
        ])
    }
}

extension AddCategoryViewController: ChromaColorPickerDelegate {
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        print(color)
    }
}
