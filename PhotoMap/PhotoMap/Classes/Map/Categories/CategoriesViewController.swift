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
import RxDataSources

class CategoriesViewController: UIViewController, StoryboardInitializable {

    @IBOutlet weak var categoriesStackView: UIStackView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectButton: UIButton!
    
    var viewModel: CategoriesViewModel!
    private let bag = DisposeBag()
    private var doneButton: UIBarButtonItem!
    private var addCategory: UIBarButtonItem!
    private let defaults = UserDefaults.standard
    private var categories: [Category]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        selectButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.selectButton.isSelected = !self.selectButton.isSelected
                self.categoriesStackView.arrangedSubviews
                    .compactMap { $0 as? CheckBox}
                    .forEach { $0.isChecked = self.selectButton.isSelected }
            })
            .disposed(by: bag)
        
        searchBar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.searchBar.endEditing(true)
            })
            .disposed(by: bag)
        
        searchBar.rx.text
            .skip(1)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.updateCategoriesState()
            })
            .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
            .compactMap { $0 }
            .bind(to: viewModel.searchText)
            .disposed(by: bag)
        
        doneButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.updateCategoriesState()
            })
            .bind(to: viewModel.done)
            .disposed(by: bag)
        
        addCategory.rx.tap
            .bind(to: viewModel.addCategory)
            .disposed(by: bag)
        
        viewModel.filteredCategories
            .subscribe(onNext: { [weak self] categories in
                guard let self = self else { return }
                self.categoriesStackView.subviews.forEach { view in
                    view.removeFromSuperview()
                }
                self.categories = categories
                self.setupCategories(categories: categories)
                self.configureCategoriesState(categories)
            })
            .disposed(by: bag)
        
        viewModel.categories
            .subscribe(onNext: { [weak self] categories in
                guard let self = self else { return }
                self.categories = categories
                self.updateCategoriesState()
                self.setupCategories(categories: categories)
                self.configureCategoriesState(categories)
            })
            .disposed(by: bag)
    }
    
    private func configureCategoriesState(_ categories: [Category]) {
        let uncheckedCategories = defaults.object(forKey: "savedCategories") as? [String] ?? []
        categoriesStackView.subviews
            .compactMap { $0 as? CheckBox}
            .filter { checkBox in                
                return categories.contains(where: { category -> Bool in
                    let checkBoxCategory = checkBox.categoryLabel.text!.lowercased()
                    return uncheckedCategories.contains(category.engName) &&
                        (category.ruName.lowercased() == checkBoxCategory ||
                            category.engName.lowercased() == checkBoxCategory)
                })
            }
            .forEach { $0.checkButton.backgroundColor = .white }
        guard let selectButtonState = (categoriesStackView.arrangedSubviews.first as? CheckBox)?.isChecked else {
            return
        }
        selectButton.isSelected = selectButtonState
    }
    
    private func setupCategories(categories: [Category]) {
        self.categoriesStackView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        for category in categories {
            let checkBox = CheckBox()
            var localizedCategoryName = String()
            
            if let language = Locale.current.languageCode {
                switch language {
                case "ru":
                    localizedCategoryName = category.ruName
                default:
                    localizedCategoryName = category.engName
                }
            }
            checkBox.delegate = self
            checkBox.color = UIColor(hex: category.hexColor)!
            checkBox.categoryName = localizedCategoryName.uppercased()
            checkBox.removeCategoryButton.isHidden = !(UIApplication.shared.delegate as! AppDelegate).isAdmin
            categoriesStackView.addArrangedSubview(checkBox)
            checkBox.heightAnchor.constraint(equalToConstant: 70).isActive = true
        }
        view.layoutIfNeeded()
    }
    
    // TODO: - To service or ViewModel?
    // I DONT USE THIS METHOD!!!!
    private func saveCategoriesState() {
        let categories = categoriesStackView.subviews
            .compactMap { $0 as? CheckBox}
            .filter { !$0.isChecked }
            .map { [weak self] checkBox -> String? in
                guard let self = self else { return nil }
                
                let categoryName = checkBox.categoryLabel.text!.uppercased()
                let category = self.categories.first { category -> Bool in
                    category.engName.uppercased() == categoryName
                        || category.ruName.uppercased() == categoryName
                }
                return category?.engName
            }
            .compactMap { $0 }
        self.defaults.set(categories, forKey: "savedCategories")
    }
    
    // TODO: - To service or ViewModel?
    private func updateCategoriesState() {
        var uncheckedCategories = defaults.object(forKey: "savedCategories") as? [String] ?? []
        let categories = categoriesStackView.subviews
            .compactMap { $0 as? CheckBox}
            .filter { !$0.isChecked }
            .map { [weak self] checkBox -> String? in
                guard let self = self else { return nil }
                
                let categoryName = checkBox.categoryLabel.text!.uppercased()
                let category = self.categories.first { category -> Bool in
                    category.engName.uppercased() == categoryName
                        || category.ruName.uppercased() == categoryName
                }
                return category?.engName
            }
            .compactMap { $0 }
        
        let checkedCategories = categoriesStackView.subviews
            .compactMap { $0 as? CheckBox}
            .filter { $0.isChecked }
            .map { [weak self] checkBox -> String? in
                guard let self = self else { return nil }
                
                let categoryName = checkBox.categoryLabel.text!.uppercased()
                let category = self.categories.first { category -> Bool in
                    category.engName.uppercased() == categoryName
                        || category.ruName.uppercased() == categoryName
                }
                return category?.engName
            }
            .compactMap { $0 }
        
        categories.forEach { category in
            if !uncheckedCategories.contains(category) {
                uncheckedCategories.append(category)
            }
        }
    
        checkedCategories.forEach { category in
            if uncheckedCategories.contains(category) {
                let index = uncheckedCategories.firstIndex(of: category)!
                uncheckedCategories.remove(at: index)
            }
        }
        self.defaults.set(uncheckedCategories, forKey: "savedCategories")
    }
    
    private func setupView() {
        navigationController?.navigationBar.topItem?.title = R.string.localizable.categories()
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        addCategory = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.rightBarButtonItem = doneButton
        let defaultTintColor = navigationController!.navigationBar.tintColor!
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: defaultTintColor]
        
        selectButton.setImage(R.image.selectAll(), for: .normal)
        selectButton.setImage(R.image.deselectAll(), for: .selected)
        setupAdminView()
    }
    
    private func setupAdminView() {
        guard let isAdmin = (UIApplication.shared.delegate as? AppDelegate)?.isAdmin else { return }
        let adminItem = isAdmin ? addCategory : nil
        navigationController?.navigationBar.topItem?.leftBarButtonItem = adminItem
    }
}

extension CategoriesViewController: CheckBoxDelegate {
    func removeCategoryTapped(with color: UIColor, name: String) {
        confirmСategoryDeletion()
            .filter { $0 }
            .map { _ in name }
            .bind(to: viewModel.removeCategory)
            .disposed(by: bag)
    }
    
    private func confirmСategoryDeletion() -> Observable<Bool> {
        return Observable.create { [weak self] observer  in
            guard let self = self else { return Disposables.create() }
            let removeAllert = UIAlertController(title: R.string.localizable.removeCategoryTitle(),
                                                 message: R.string.localizable.removeCategoryMessage(),
                                                 preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: R.string.localizable.cancel(),
                                             style: .cancel,handler: { _ in
                                                observer.onNext(false)
            })
            let removeAction = UIAlertAction(title: R.string.localizable.removeAction(),
                                             style: .destructive, handler: { _ in
                                                observer.onNext(true)
            })
            removeAllert.addAction(removeAction)
            removeAllert.addAction(cancelAction)
            self.present(removeAllert, animated: true, completion: nil)
            return Disposables.create()
        }
    }
}

extension String {
    /// Get key for localized string value
    func localizedKey() -> String {
        var resultKey = ""
        let stringsPath = Bundle.main.path(forResource: "Localizable", ofType: "strings")
        let dictionary = NSDictionary(contentsOfFile: stringsPath!) as! [String: String]
        
        dictionary.forEach { key, value in
            if value == self.lowercased() {
                resultKey = key
            }
        }
        return resultKey
    }
}
