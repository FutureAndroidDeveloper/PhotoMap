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
import SkyFloatingLabelTextField

class AddCategoryViewController: UIViewController, StoryboardInitializable {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ruCategoryTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var engCategoryTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var hexColorTextField: SkyFloatingLabelTextField!
    
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
//        setPreview()
        
        // DONT WORK
        navigationController?.navigationBar.topItem?.backBarButtonItem?.rx.tap.asControlEvent()
            .bind(to: viewModel.goBack)
            .disposed(by: bag)
        
        engCategoryTextField.rx
            .controlEvent(.editingDidEnd)
            .withLatestFrom(engCategoryTextField.rx.text)
            .bind(to: viewModel.engCategoryEditingDidEnd)
            .disposed(by: bag)
        
        engCategoryTextField.rx.text
            .bind(to: viewModel.engCategory)
            .disposed(by: bag)
        
        ruCategoryTextField.rx
            .controlEvent(.editingDidEnd)
            .withLatestFrom(ruCategoryTextField.rx.text)
            .bind(to: viewModel.ruCategoryEditingDidEnd)
            .disposed(by: bag)
        
        ruCategoryTextField.rx.text
            .bind(to: viewModel.ruCategory)
            .disposed(by: bag)
        
        colorPicker.hexLabel.rx.observe(String.self, "text")
            .compactMap { $0 }
            .map { String($0.dropFirst()) }
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.hexColorTextField.errorMessage = nil
            })
            .bind(to: hexColorTextField.rx.text)
            .disposed(by: bag)

        hexColorTextField.rx.controlEvent(.editingDidEnd)
            .withLatestFrom(hexColorTextField.rx.text)
            .bind(to: viewModel.hexColor)
            .disposed(by: bag)
        
        hexColorTextField.rx.text
            .compactMap { $0 }
            .filter { $0.count > 6 }
            .map { String($0.prefix(6)) }
            .bind(to: hexColorTextField.rx.text)
            .disposed(by: bag)
        
        viewModel.newColor
            .subscribe(onNext: { [weak self] color in
                guard let self = self else { return }
                self.colorPicker.adjustToColor(color)
                self.hexColorTextField.errorMessage = nil
            })
            .disposed(by: bag)
        
        viewModel.hexError
            .subscribe(onNext: { [weak self] errorMessage in
                guard let self = self else { return }
                self.hexColorTextField.errorMessage = errorMessage
            })
            .disposed(by: bag)
        
        viewModel.engCategoryError
            .subscribe(onNext: { [weak self] errorMessage in
                guard let self = self else { return }
                self.engCategoryTextField.errorMessage = errorMessage
            })
            .disposed(by: bag)
        
        viewModel.engProvenText
            .bind(to: engCategoryTextField.rx.text)
            .disposed(by: bag)
        
        viewModel.ruProvenText
            .bind(to: ruCategoryTextField.rx.text)
            .disposed(by: bag)
        
        viewModel.ruCategoryError
            .subscribe(onNext: { [weak self] errorMessage in
                guard let self = self else { return }
                self.ruCategoryTextField.errorMessage = errorMessage
            })
            .disposed(by: bag)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass {
            configureView(for: traitCollection)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setPreview()
    }
    
    private func setPreview() {
        print(colorPicker.addButton.frame)
        print(colorPicker.addButton.bounds)
        
//        let view = UIView(frame: colorPicker.addButton.bounds)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .black
//        
//        colorPicker.addSubview(view)
//        
//        let aa = CGPoint(x: colorPicker.center.x + colorPicker.addButton.center.x / 4.5, y: colorPicker.center.y + colorPicker.addButton.center.y / 4.5)
//        
//        view.center = aa
        
        
        
//        colorPicker.handleView.isHidden = true
    }
    
    private func setupView() {
        addButton = UIBarButtonItem(title: "Add New Category", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = addButton
        addButton.isEnabled = false
        containerView.backgroundColor = UIColor.clear
//        hexColorLabel.textAlignment = .center
        setupColorPicker()
    }
    
    private func setupColorPicker() {
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        colorPicker.delegate = self
        colorPicker.stroke = 3
        containerView.addSubview(colorPicker)
        resizeColorPicker(to: .width, with: 0.9)
        
        NSLayoutConstraint.activate([
            colorPicker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            colorPicker.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
        colorPicker.layout()
    }
    
    private func configureView(for traitCollection: UITraitCollection) {
        NSLayoutConstraint.deactivate([colorPickerHeightConstraint, colorPickerWidthConstraint])
        colorPicker.removeConstraints([colorPickerHeightConstraint, colorPickerWidthConstraint])
        switch traitCollection.verticalSizeClass {
        case .compact:
            resizeColorPicker(to: .height, with: 0.8)
        default:
            resizeColorPicker(to: .width, with: 0.9)
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
