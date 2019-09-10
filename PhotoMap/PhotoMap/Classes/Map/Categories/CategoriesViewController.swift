//
//  CategoriesViewController.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/28/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CategoriesViewController: UIViewController, StoryboardInitializable {

    @IBOutlet weak var categoriesStackView: UIStackView!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    
    var viewModel: CategoriesViewModel!
    private let bag = DisposeBag()
    private var doneButton: UIBarButtonItem!
    private let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
  
        viewModel.categories.takeLast(1)
            .subscribe(onNext: { [weak self] categories in
                guard let self = self else { return }
                self.setupCategories(categories: categories)
                self.configureCategoriesState()
            })
            .disposed(by: bag)
        
        doneButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                let categories = self.categoriesStackView.subviews
                    .compactMap { $0 as? CheckBox }
                    .filter { !$0.isChecked }
                    .map { $0.categoryLabel.text!.localizedKey() }
                self.defaults.set(categories, forKey: "savedCategories")
            })
            .bind(to: viewModel.done)
            .disposed(by: bag)
    }

    private func setupCategories(categories: [String]) {
        let colors: [UIColor] = [#colorLiteral(red: 0.2117647059, green: 0.5568627451, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3411764706, green: 0.5568627451, blue: 0.09411764706, alpha: 1), #colorLiteral(red: 0.9568627451, green: 0.6470588235, blue: 0.137254902, alpha: 1)]
        
        for index in 0..<categories.count {
            let checkBox = CheckBox()
            checkBox.color = colors[index]
            checkBox.categoryLabel.text = NSLocalizedString(categories[index], comment: "").uppercased()
            checkBox.categoryLabel.font = UIFont.systemFont(ofSize: checkBox.checkButton.bounds.width / 1.8, weight: .light)
            categoriesStackView.addArrangedSubview(checkBox)
        }
        stackViewHeightConstraint.constant = CGFloat(categoriesStackView.subviews.count) *
            (categoriesStackView.subviews.first! as! CheckBox).height
        view.layoutIfNeeded()
    }
    
    private func configureCategoriesState() {
        let uncheckedCategories = defaults.object(forKey: "savedCategories") as? [String] ?? []
        categoriesStackView.subviews
            .compactMap { $0 as? CheckBox }
            .filter { uncheckedCategories.contains($0.categoryLabel.text!.localizedKey()) }
            .forEach { $0.checkButton.backgroundColor = .white }
    }
    
    private func setupView() {
        navigationController?.navigationBar.topItem?.title = R.string.localizable.categories()
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.rightBarButtonItem = doneButton
        let defaultTintColor = navigationController!.navigationBar.tintColor!
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: defaultTintColor]
    }
}


extension String {
    /// Get key for localized string value
    func localizedKey() -> String {
        var resultKey = ""
        let stringsPath = Bundle.main.path(forResource: "Localizable", ofType: "strings")
        let dictionary = NSDictionary(contentsOfFile: stringsPath!) as! [String: String]
        
        dictionary.forEach({ key, value in
            if value == self.lowercased() {
                resultKey = key
            }
        })
        return resultKey
    }}
