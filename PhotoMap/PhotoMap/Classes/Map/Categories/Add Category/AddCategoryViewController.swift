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
    @IBOutlet weak var categoryMarkerPreview: CategoryMarker!
    
    var viewModel: AddCategoryViewModel!
    private let bag = DisposeBag()
    private let colorPicker = ChromaColorPicker()
    private var addButton: UIBarButtonItem!
    private var colorPickerWidthConstraint: NSLayoutConstraint!
    private var colorPickerHeightConstraint: NSLayoutConstraint!
    private var centerYConstraint: NSLayoutConstraint!
    private var centerXConstraint: NSLayoutConstraint!
    private var colorPickerleadingConstraint: NSLayoutConstraint!
    private let spinner = UIActivityIndicatorView(style: .gray)
    private var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.engCategoryTextField.endEditing(true)
                self.engCategoryTextField.resignFirstResponder()
                self.ruCategoryTextField.endEditing(true)
                self.ruCategoryTextField.resignFirstResponder()
                self.hexColorTextField.endEditing(true)
                self.hexColorTextField.resignFirstResponder()
            })
            .disposed(by: bag)
        
        engCategoryTextField.rx
            .controlEvent(.editingDidEnd)
            .withLatestFrom(engCategoryTextField.rx.text)
            .bind(to: viewModel.engCategoryEditingDidEnd)
            .disposed(by: bag)
        
        engCategoryTextField.rx.text
            .compactMap { $0 }
            .filter { $0.count > 20 }
            .map { String($0.prefix(20)) }
            .bind(to: engCategoryTextField.rx.text)
            .disposed(by: bag)
        
        engCategoryTextField.rx.text
            .compactMap { $0 }
            .filter { $0.count <= 20 }
            .bind(to: viewModel.engCategory)
            .disposed(by: bag)
        
        ruCategoryTextField.rx
            .controlEvent(.editingDidEnd)
            .withLatestFrom(ruCategoryTextField.rx.text)
            .bind(to: viewModel.ruCategoryEditingDidEnd)
            .disposed(by: bag)
        
        ruCategoryTextField.rx.text
            .compactMap { $0 }
            .filter { $0.count > 20 }
            .map { String($0.prefix(20)) }
            .bind(to: ruCategoryTextField.rx.text)
            .disposed(by: bag)
        
        ruCategoryTextField.rx.text
            .compactMap { $0 }
            .filter { $0.count <= 20 }
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
        
        colorPicker.hexLabel.rx.observe(String.self, "text")
            .compactMap { $0 }
            .map { UIColor(hex: $0) }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] color in
                guard let self = self else { return }
                self.categoryMarkerPreview.color = color
            })
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
        
        addButton.rx.tap
            .map { [weak self] _ -> Category? in
                guard let self = self else { return nil }
                return Category(hexColor: self.colorPicker.hexLabel.text!,
                         engName: self.engCategoryTextField.text!,
                         ruName: self.ruCategoryTextField.text!)
            }
            .bind(to: viewModel.addNewCategory)
            .disposed(by: bag)
        
        viewModel.isLoading
            .map { !$0 }
            .bind(to: spinner.rx.isHidden)
            .disposed(by: bag)
        
        viewModel.isLoading
            .bind(to: spinner.rx.isAnimating)
            .disposed(by: bag)
        
        viewModel.showError
            .subscribe(onNext: { [weak self] errorMessage in
                guard let self = self else { return }
                self.showFirebaseError(errorMessage)
            })
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

        Observable.combineLatest(engCategoryTextField.rx.controlEvent(.editingDidEnd).withLatestFrom(engCategoryTextField.rx.text.orEmpty),
                                 ruCategoryTextField.rx.controlEvent(.editingDidEnd).withLatestFrom(ruCategoryTextField.rx.text.orEmpty),
                                 hexColorTextField.rx.text.orEmpty)
            .filter { !($0.0.isEmpty || $0.1.isEmpty || $0.2.isEmpty) }
            .filter { [weak self] _ -> Bool in
                guard let self = self else { return false }
                if self.engCategoryTextField.errorMessage != nil ||
                    self.ruCategoryTextField.errorMessage != nil ||
                    self.hexColorTextField.errorMessage != nil {
                    return false
                }
                return true
            }
            .map { _ in true }
            .bind(to: addButton.rx.isEnabled)
            .disposed(by: bag)
        
        Observable.merge([viewModel.engCategoryError, viewModel.ruCategoryError, viewModel.hexError])
            .compactMap { $0 }
            .map { _ in false }
            .bind(to: addButton.rx.isEnabled)
            .disposed(by: bag)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass {
            configureView(for: traitCollection)
        }
    }
    
    private func setupView() {
        tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)
        addButton = UIBarButtonItem(title: "Add New Category", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = addButton
        addButton.isEnabled = false
        containerView.backgroundColor = .clear
        categoryMarkerPreview.backgroundColor = .clear
        view.addSubview(spinner)
        spinner.center = view.center
        setupColorPicker()
    }
    
    private func setupColorPicker() {
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        colorPicker.delegate = self
        colorPicker.stroke = 3
        colorPicker.addButton.isHidden = true
        colorPicker.handleLine.isHidden = true
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
    
    private func showFirebaseError(_ error: String) {
        let alert = UIAlertController(title: "Firebase Category Error", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: R.string.localizable.ok(), style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension AddCategoryViewController: ChromaColorPickerDelegate {
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        print(color)
    }
}
