//
//  PostViewController.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/5/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class PostViewController: UIViewController, StoryboardInitializable {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: PostView!
    
    var viewModel: PostViewModel!
    private let bag = DisposeBag()
    private let categoryTapGesture = UITapGestureRecognizer()
    private let imageTapGesture = UITapGestureRecognizer()
    private let pickerView = UIPickerView()
    private let searchBar = UISearchBar()
    private var selectedCategory: Category!
    
    private var adapter = PickerViewViewAdapter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        searchBar.rx.text
            .bind(to: viewModel.searchText)
            .disposed(by: bag)
        
        pickerView.rx.modelSelected(Category.self)
            .compactMap { $0.first }
            .subscribe(onNext: { [weak self] category in
                guard let self = self else { return }
                self.contentView.categoryLabel.text = category.description.uppercased()
                self.contentView.categoryMarkerView.color = UIColor(hex: category.hexColor)!
                self.selectedCategory = category
            })
            .disposed(by: bag)
        
        contentView.cancelButton.rx.tap
            .bind(to: viewModel.cancel)
            .disposed(by: bag)
        
        contentView.doneButton.rx.tap
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.contentView.categoryLabel.text ==
                    R.string.localizable.pickCategory().uppercased()
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showCategoryError()
            })
            .disposed(by: bag)
        
        contentView.doneButton.rx.tap
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return !(self.contentView.categoryLabel.text ==
                    R.string.localizable.pickCategory().uppercased())
            }
            .flatMap { [weak self] _ -> Observable<PostAnnotation> in
                guard let self = self else { fatalError("Post View Controller") }
                return self.createPost()
            }
            .bind(to: viewModel.done)
            .disposed(by: bag)

        categoryTapGesture.rx.event
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showCategoryPicker()
            })
            .disposed(by: bag)

        imageTapGesture.rx.event
            .flatMap { [weak self] _ -> Observable<PostAnnotation> in
                guard let self = self else { fatalError("Post View Controller") }
                return self.createPost()
            }
            .bind(to: viewModel.fullPhotoTapped)
            .disposed(by: bag)
        
        viewModel.date
            .bind(to: contentView.dateLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.categories
            .flatMap { Observable.just([$0]) }
            .bind(to: pickerView.rx.items(adapter: adapter))
            .disposed(by: bag)
        
        viewModel.filteredCategories
            .map { [$0] }
            .subscribe(onNext: { [weak self] filteredCategories in
                guard let self = self else { return }
                self.adapter.update(self.pickerView, items: filteredCategories)
            })
            .disposed(by: bag)
        
        viewModel.postImage
            .bind(to: contentView.photoImageView.rx.image)
            .disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        moveIn()
    }
    
    func showCategoryPicker() {
        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 250, height: 200)
        searchBar.frame = CGRect(x: 0, y: 0, width: 250, height: 50)
        pickerView.frame = CGRect(x: 0, y: 40, width: 250, height: 200)
        viewController.view.addSubview(pickerView)
        viewController.view.addSubview(searchBar)
        
        let categoryAlert = UIAlertController(title: R.string.localizable.chooseCategory(),
                                                message: nil,
                                                preferredStyle: UIAlertController.Style.alert)
        
        categoryAlert.setValue(viewController, forKey: "contentViewController")
        categoryAlert.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let selectedRow = self.pickerView.selectedRow(inComponent: 0)
            self.pickerView.delegate?.pickerView?(self.pickerView, didSelectRow: selectedRow, inComponent: 0)
        }))
        
        present(categoryAlert, animated: true)
        searchBar.placeholder = R.string.localizable.category()
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundColor = UIColor.clear
        searchBar.isTranslucent = true
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    }
    
    private func setupView() {
        scrollView.layer.cornerRadius = 10
        contentView.layer.cornerRadius = 10
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        contentView.categoryStackView.addGestureRecognizer(categoryTapGesture)
        contentView.photoImageView.addGestureRecognizer(imageTapGesture)
    }
    
    private func createPost() -> Observable<PostAnnotation> {
        return Observable.create { [weak self] observer  in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            self.viewModel.timestamp
                .map { [weak self] timestamp -> PostAnnotation in
                    guard let self = self else { fatalError("Post View Controller. createPost()") }
                    return PostAnnotation(image: self.contentView.photoImageView.image!,
                                          date: timestamp,
                                          hexColor: self.selectedCategory.hexColor,
                                          category: self.selectedCategory.engName.uppercased(),
                                          postDescription: self.contentView.textView.text,
                                          userId: (UIApplication.shared.delegate as! AppDelegate).user.id)
                }
                .subscribe(onNext: { post in
                    observer.onNext(post)
                    observer.onCompleted()
                }, onError: { error in
                    observer.onError(error)
                })
                .disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    
    private func showCategoryError() {
        let alert = UIAlertController(title: R.string.localizable.categoryErrorTitle(),
                                      message: R.string.localizable.categoryErrorMessage(),
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: R.string.localizable.ok(), style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func moveIn() {
        scrollView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        scrollView.alpha = 0
        UIView.animate(withDuration: 0.5) { [weak self] () -> Void in
            guard let self = self else { return }
            self.scrollView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.scrollView.alpha = 1
        }
    }
    
     func moveOut() -> Observable<Void> {
        return Observable.create { observer  in
            UIView.animate(withDuration: 0.4, animations: { [weak self] () -> Void in
                guard let self = self else { return }
                self.scrollView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.scrollView.alpha = 0
                }, completion: { [weak self]  _ in
                    guard let self = self else {
                        observer.onNext(Void())
                        observer.onCompleted()
                        return
                    }
                    self.removeFromParent()
                    self.view.removeFromSuperview()
                    observer.onNext(Void())
                    observer.onCompleted()
            })
            return Disposables.create()
        }
    }
}
