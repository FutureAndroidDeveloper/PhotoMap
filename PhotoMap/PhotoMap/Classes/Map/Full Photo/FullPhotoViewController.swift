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

class FullPhotoViewController: UIViewController, StoryboardInitializable {
    
    var height: NSLayoutConstraint!
    var top: NSLayoutConstraint!
    var leading: NSLayoutConstraint!
    
    
    var bot: NSLayoutConstraint!
    var heightFooter: NSLayoutConstraint!
    
    let headerView = UIView()
    let footerView = FooterView()
    
    
    let tapGesture = UITapGestureRecognizer()
    var doubleTapGesture = UITapGestureRecognizer()
    
    var viewModel: FullPhotoViewModel!
    private let bag = DisposeBag()
    
    @IBOutlet weak var imageView: UIImageView!
    
//    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
//    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
//    @IBOutlet weak var imageViewTralingConstraint: NSLayoutConstraint!
//    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        // Transparent navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        height = headerView.heightAnchor.constraint(equalToConstant: 44 * 2)
        top = headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: -25)
        leading = headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -25.0)
        
        NSLayoutConstraint.activate([
            leading,
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 25.0),
            top,
            height
            ])
        
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOpacity = 0.6
        headerView.layer.shadowOffset = .zero
        headerView.layer.shadowRadius = 8
        
        headerView.layer.shadowPath = UIBezierPath(rect: headerView.bounds).cgPath
        headerView.layer.shouldRasterize = true
        headerView.layer.rasterizationScale = UIScreen.main.scale
        
        tapGesture.addTarget(self, action: #selector(tap))
        doubleTapGesture.addTarget(self, action: #selector(double))
        
        doubleTapGesture.numberOfTapsRequired = 2
        tapGesture.require(toFail: doubleTapGesture)
        
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(doubleTapGesture)
        
//        scrollView.delegate = self
        addFooter()
//        updateConstraintsForSize(view.bounds.size)
        
        
        let post = viewModel.post.share(replay: 1)
        
        post
            .map { $0.postDescription }
            .bind(to: footerView.descriptionLabel.rx.text)
            .disposed(by: bag)
        
        post
            .map { $0.image }
            .bind(to: imageView.rx.image)
            .disposed(by: bag)
        
        viewModel.longDate
            .bind(to: footerView.dateLabel.rx.text)
            .disposed(by: bag)
    }
    
    @objc func tap() {
        if navigationItem.hidesBackButton {
            display()
        } else {
            hide()
        }
    }
    
    
    @objc func double() {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Aaaaaaaaaaaaa!
        
        headerView.removeFromSuperview()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let navigationController = navigationController else { return }
        height.constant = navigationController.navigationBar.frame.size.height * 2 + 20
        //
        //        switch UIDevice.current.orientation {
        //        case .portrait:
        //            heightFooter.constant = footerView.descriptionLabel.bounds.size.height * 2 + 16 + 16 + footerView.dateLabel.bounds.size.height
        //        case .landscapeLeft, .landscapeRight:
        //            heightFooter.constant = footerView.descriptionLabel.bounds.size.height / 2 + 16 + 16 + footerView.dateLabel.bounds.size.height
        //        default:
        //            break
        //        }
        
//        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    
    // Handles a double tap by either resetting the zoom or zooming to where was tapped
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.layer.shadowPath = UIBezierPath(rect: headerView.bounds).cgPath
    }
    
    func hide() {
        top.constant = -height.constant
        navigationItem.hidesBackButton = true
        
        // hide footer
        bot.constant = heightFooter.constant
        
        UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            self.view.layoutIfNeeded()
            self.headerView.alpha = 0
            self.view.backgroundColor = .black
            }.startAnimation()
    }
    
    func display() {
        top.constant = -25
        navigationItem.hidesBackButton = false
        
        // show footer
        bot.constant = 0
        
        UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            self.view.layoutIfNeeded()
            self.headerView.alpha = 1
            self.view.backgroundColor = .white
            }.startAnimation()
    }
    
    func addFooter() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footerView)
        
        
        bot = footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        heightFooter = footerView.heightAnchor.constraint(equalToConstant: 140)
        //        heightFooter = footerView.heightAnchor.constraint(equalToConstant: footerView.descriptionLabel.bounds.size.height * 2 + 16 + 16 + footerView.dateLabel.bounds.size.height)
        
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bot,
            heightFooter
            ])
    }
    
//    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
//        let widthScale = size.width / imageView.bounds.width
//        let heightScale = size.height / imageView.bounds.height
//        let minScale = min(widthScale, heightScale)
//
//        scrollView.minimumZoomScale = minScale
//        scrollView.zoomScale = minScale
//    }
//
//    fileprivate func updateConstraintsForSize(_ size: CGSize) {
//
//        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
//        imageViewTopConstraint.constant = yOffset
//        imageViewBottomConstraint.constant = yOffset
//
//        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
//        imageViewLeadingConstraint.constant = xOffset
//        imageViewTralingConstraint.constant = xOffset
//
//
//        print("yOffset = \(yOffset)")
//        print("xOffset = \(xOffset)")
//        print("")
//
//        view.layoutIfNeeded()
//    }
}
