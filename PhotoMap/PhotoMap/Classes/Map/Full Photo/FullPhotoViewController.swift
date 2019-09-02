//
//  FullPhotoViewController.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/9/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ImageScrollView

class FullPhotoViewController: UIViewController, StoryboardInitializable {
    
    @IBOutlet weak var imageScrollView: ImageScrollView!
    
    // MARK: - Properties
    private var headerHeight: NSLayoutConstraint!
    private var headerTop: NSLayoutConstraint!
    private var headerLeading: NSLayoutConstraint!
    
    private var footerBot: NSLayoutConstraint!
    private var footerHeight: NSLayoutConstraint!
    
    private let headerView = UIView()
    private let footerView = FooterView()
    private let tapGesture = UITapGestureRecognizer()
    private let doubleTapGesture = UITapGestureRecognizer()
    
    var viewModel: FullPhotoViewModel!
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addFooter()
        addHeaderView()
        imageScrollView.setup()
        
        tapGesture.rx.event
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.navigationItem.hidesBackButton {
                    self.show()
                } else {
                    self.hide()
                }
            })
            .disposed(by: bag)

        let post = viewModel.post.share(replay: 1)
        
        post
            .map { $0.postDescription }
            .bind(to: footerView.descriptionLabel.rx.text)
            .disposed(by: bag)
        
        post
            .compactMap { $0.image }
            .subscribe(onNext: { [weak self] image in
                guard let self = self else { return }
                self.imageScrollView.display(image: image)
            })
            .disposed(by: bag)
        
        viewModel.longDate
            .bind(to: footerView.dateLabel.rx.text)
            .disposed(by: bag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.backTapped.onNext(Void())
        headerLeading.constant = 0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let navigationController = navigationController else { return }
        headerHeight.constant = navigationController.navigationBar.frame.size.height * 2 + 20
        footerView.layoutSubviews()
        footerView.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.layer.shadowPath = UIBezierPath(rect: headerView.bounds).cgPath
        footerHeight.constant = 8 + footerView.descriptionLabel.bounds.size.height + 16 + footerView.dateLabel.bounds.size.height + 16
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        // Transparent navigation bar
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        tapGesture.require(toFail: doubleTapGesture)
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(doubleTapGesture)
    }
    
    private func hide() {
        headerTop.constant = -headerHeight.constant
        navigationItem.hidesBackButton = true
        footerBot.constant = footerHeight.constant
        
        UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
            self.headerView.alpha = 0
            self.view.backgroundColor = .black
            }.startAnimation()
    }
    
    private func show() {
        headerTop.constant = -25
        navigationItem.hidesBackButton = false
        footerBot.constant = 0
        
        UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
            self.headerView.alpha = 1
            self.view.backgroundColor = .white
            }.startAnimation()
    }
    
    private func addHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        headerHeight = headerView.heightAnchor.constraint(equalToConstant: 44 * 2)
        headerTop = headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: -25)
        headerLeading = headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -25.0)
        
        NSLayoutConstraint.activate([
            headerLeading,
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 25.0),
            headerTop,
            headerHeight
            ])
        
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOpacity = 0.6
        headerView.layer.shadowOffset = .zero
        headerView.layer.shadowRadius = 8
        
        headerView.layer.shadowPath = UIBezierPath(rect: headerView.bounds).cgPath
        headerView.layer.shouldRasterize = true
        headerView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func addFooter() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footerView)
        
        footerBot = footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        footerHeight = footerView.heightAnchor.constraint(equalToConstant: 8 + footerView.descriptionLabel.bounds.size.height + 16 + footerView.dateLabel.bounds.size.height + 16)
        
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerBot,
            footerHeight
            ])
    }
}
