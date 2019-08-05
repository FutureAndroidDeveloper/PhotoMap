//
//  PostViewController.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/5/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit
import RxSwift

class PostViewController: UIViewController, StoryboardInitializable {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: PostView!
    
    var viewModel: PostViewModel!
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        viewModel.postImage
            .bind(to: contentView.photoImageView.rx.image)
            .disposed(by: bag)
        
        viewModel.date
            .bind(to: contentView.dateLabel.rx.text)
            .disposed(by: bag)
        
        contentView.cancelButton.rx.tap
            .bind(to: viewModel.cancel)
            .disposed(by: bag)
        
        contentView.doneButton.rx.tap
            .map { Post(image: self.contentView.photoImageView.image!, date: "Test Test") }
            .bind(to: viewModel.done)
            .disposed(by: bag)
        
        viewModel.shouldDismass
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.moveOut()
            })
            .disposed(by: bag)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        moveIn()
    }
    
    private func setupView() {
        scrollView.layer.cornerRadius = 10
        contentView.layer.cornerRadius = 10
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    
    private func moveIn() {
        scrollView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        scrollView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.scrollView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.scrollView.alpha = 1
        }
    }
    
     func moveOut() {
        UIView.animate(withDuration: 0.4, animations: {
            self.scrollView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.scrollView.alpha = 0
        }, completion: { _ in
            self.view.removeFromSuperview()
        })
    }
}
