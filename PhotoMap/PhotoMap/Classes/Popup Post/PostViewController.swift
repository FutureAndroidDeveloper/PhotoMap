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

class PostViewController: UIViewController, StoryboardInitializable {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: PostView!
    
    var viewModel: PostViewModel!
    private let bag = DisposeBag()
    private let tapGesture = UITapGestureRecognizer()
    private let pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        // TODO: - Replace in setupBind() method
        viewModel.postImage
            .bind(to: contentView.photoImageView.rx.image)
            .disposed(by: bag)
        
        pickerView.rx.modelSelected(String.self)
            .compactMap { $0.first }
            .subscribe(onNext: { [weak self] category in
                guard let self = self else { return }
                self.contentView.categoryLabel.text = category.uppercased()
                self.contentView.categoryImageView.image = UIImage(named: category)
            })
            .disposed(by: bag)
        
        viewModel.date
            .bind(to: contentView.dateLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.categories
            .flatMap { Observable.just([$0]) }
            .bind(to: pickerView.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: bag)
        
        contentView.cancelButton.rx.tap
            .bind(to: viewModel.cancel)
            .disposed(by: bag)
        
        contentView.doneButton.rx.tap
            // TODO: - Send a Post after filling in the necessary information.
            // TODO: - Keyboard management
            // TODO: - Size Classes
            .flatMap { self.viewModel.timestamp }
            .map { PostAnnotation(image: self.contentView.photoImageView.image!,
                        date: $0,
                        category: self.contentView.categoryLabel.text!,
                        postDescription: self.contentView.textView.text) }
            .bind(to: viewModel.done)
            .disposed(by: bag)
        
        viewModel.shouldDismass
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.moveOut()
            })
            .disposed(by: bag)
        
        tapGesture.rx.event
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showCategoryPicker()
            })
            .disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        moveIn()
    }
    
    func showCategoryPicker() {
        let viewController = UIViewController()
        
        // TODO: - Make snape to screen?
        viewController.preferredContentSize = CGSize(width: 250, height: 150)
        pickerView.frame = CGRect(x: 0, y: -20, width: 250, height: 180)
        viewController.view.addSubview(pickerView)
        
        let editRadiusAlert = UIAlertController(title: "Choose A Photo Category", message: "", preferredStyle: UIAlertController.Style.alert)
        editRadiusAlert.setValue(viewController, forKey: "contentViewController")
        editRadiusAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(editRadiusAlert, animated: true)
    }
    
    private func setupView() {
        scrollView.layer.cornerRadius = 10
        contentView.layer.cornerRadius = 10
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        contentView.categoryStackView.addGestureRecognizer(tapGesture)
    }
    
    private func moveIn() {
        scrollView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        scrollView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.scrollView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.scrollView.alpha = 1
        }
    }
    
     private func moveOut() {
        UIView.animate(withDuration: 0.4, animations: {
            self.scrollView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.scrollView.alpha = 0
        }, completion: { [weak self]  _ in
            guard let self = self else { return }
            self.removeFromParent()
            self.view.removeFromSuperview()
        })
    }
}
